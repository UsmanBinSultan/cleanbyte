import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';

enum CompressionQuality {
  high('High', '80%', 80),
  balanced('Balanced', '60%', 60),
  maxSavings('Max savings', '40%', 40);

  const CompressionQuality(this.title, this.label, this.value);

  final String title;
  final String label;
  final int value;
}

class CompressedPhoto {
  const CompressedPhoto({
    required this.id,
    required this.name,
    required this.outputPath,
    required this.originalSize,
    required this.compressedSize,
  });

  factory CompressedPhoto.fromMap(Map<dynamic, dynamic> map) {
    return CompressedPhoto(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? 'photo',
      outputPath: map['outputPath'] as String? ?? '',
      originalSize: (map['originalSize'] as num?)?.toInt() ?? 0,
      compressedSize: (map['compressedSize'] as num?)?.toInt() ?? 0,
    );
  }

  final String id;
  final String name;
  final String outputPath;
  final int originalSize;
  final int compressedSize;
}

class PhotoCompressorController extends GetxController {
  static PhotoCompressorController instance = Get.find();

  static const _channel = MethodChannel('sift/photos');
  static const int _pageSize = 80;

  bool isLoading = true;
  bool isCompressing = false;
  bool hasAccess = false;
  String? errorMessage;
  CompressionQuality quality = CompressionQuality.balanced;
  List<AssetEntity> photos = <AssetEntity>[];
  Set<String> selectedIds = <String>{};
  Map<String, int> originalSizes = <String, int>{};
  Map<String, CompressedPhoto> compressedBySource = <String, CompressedPhoto>{};
  CompressedPhoto? lastCompressedPhoto;

  @override
  void onInit() {
    super.onInit();
    loadPhotos();
  }

  int get selectedCount => selectedIds.length;

  List<AssetEntity> get selectedPhotos =>
      photos.where((photo) => selectedIds.contains(photo.id)).toList();

  int get selectedOriginalBytes {
    return selectedPhotos.fold(
      0,
      (total, photo) => total + (originalSizes[photo.id] ?? 0),
    );
  }

  int get selectedCompressedBytes {
    return selectedPhotos.fold(0, (total, photo) {
      final path = compressedBySource[photo.id]?.compressedSize;
      if (path != null) {
        return total + path;
      }
      final original = originalSizes[photo.id] ?? 0;
      return total + (original * quality.value / 100).round();
    });
  }

  int get estimatedSavings {
    final savings = selectedOriginalBytes - selectedCompressedBytes;
    return savings > 0 ? savings : 0;
  }

  Future<void> loadPhotos() async {
    isLoading = true;
    errorMessage = null;
    update();

    final permission = await PhotoManager.requestPermissionExtend(
      requestOption: const PermissionRequestOption(
        androidPermission: AndroidPermission(
          type: RequestType.image,
          mediaLocation: false,
        ),
      ),
    );
    hasAccess = permission.hasAccess;

    if (!hasAccess) {
      photos = <AssetEntity>[];
      selectedIds.clear();
      originalSizes = <String, int>{};
      isLoading = false;
      update();
      return;
    }

    try {
      final paths = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true,
        filterOption: FilterOptionGroup(
          imageOption: const FilterOption(needTitle: true),
          orders: const [OrderOption(type: OrderOptionType.createDate)],
        ),
      );

      if (paths.isEmpty) {
        photos = <AssetEntity>[];
      } else {
        final recent = paths.first;
        final count = await recent.assetCountAsync;
        photos = await recent.getAssetListRange(
          start: 0,
          end: count < _pageSize ? count : _pageSize,
        );
      }

      await _measurePhotos();
      selectedIds.removeWhere((id) => photos.every((photo) => photo.id != id));
    } catch (_) {
      errorMessage = 'Could not load photos from this device.';
      photos = <AssetEntity>[];
      selectedIds.clear();
      originalSizes = <String, int>{};
    }

    isLoading = false;
    update();
  }

  void setQuality(CompressionQuality nextQuality) {
    if (quality == nextQuality) {
      return;
    }
    quality = nextQuality;
    update();
  }

  bool isSelected(AssetEntity photo) => selectedIds.contains(photo.id);

  void togglePhoto(AssetEntity photo) {
    if (!selectedIds.add(photo.id)) {
      selectedIds.remove(photo.id);
    }
    update();
  }

  void toggleSelectAll() {
    if (photos.isEmpty) {
      return;
    }
    if (selectedIds.length == photos.length) {
      selectedIds.clear();
    } else {
      selectedIds
        ..clear()
        ..addAll(photos.map((photo) => photo.id));
    }
    update();
  }

  Future<int> compressSelected() async {
    if (selectedIds.isEmpty || isCompressing) {
      return 0;
    }

    isCompressing = true;
    errorMessage = null;
    update();

    try {
      final photosToCompress = <Map<String, dynamic>>[];
      for (final photo in selectedPhotos) {
        final bytes = await _readPhotoBytes(photo);
        if (bytes == null || bytes.isEmpty) {
          continue;
        }
        photosToCompress.add(<String, dynamic>{
          'id': photo.id,
          'name': photo.title ?? 'photo',
          'bytes': bytes,
          'originalSize': originalSizes[photo.id] ?? bytes.length,
        });
      }

      if (photosToCompress.isEmpty) {
        errorMessage = 'Selected photos could not be read from this device.';
        return 0;
      }

      final result = await _channel.invokeMethod<List<dynamic>>(
        'compressImages',
        <String, dynamic>{'photos': photosToCompress, 'quality': quality.value},
      );
      final compressed = (result ?? <dynamic>[])
          .whereType<Map<dynamic, dynamic>>()
          .map(CompressedPhoto.fromMap)
          .toList();

      for (final item in compressed) {
        if (item.id.isNotEmpty) {
          compressedBySource[item.id] = item;
        }
      }
      if (compressed.isNotEmpty) {
        lastCompressedPhoto = compressed.last;
      }

      return compressed.length;
    } on PlatformException catch (error) {
      errorMessage = error.message ?? 'Could not compress selected photos.';
      return 0;
    } catch (_) {
      errorMessage = 'Could not compress selected photos.';
      return 0;
    } finally {
      isCompressing = false;
      update();
    }
  }

  Future<void> openSettings() => PhotoManager.openSetting();

  Future<Uint8List?> _readPhotoBytes(AssetEntity photo) async {
    try {
      final file = await photo.file;
      if (file != null) {
        return file.readAsBytes();
      }
      return photo.originBytes;
    } catch (_) {
      return null;
    }
  }

  Future<void> _measurePhotos() async {
    final entries = await Future.wait(
      photos.map((photo) async {
        try {
          final file = await photo.file;
          return MapEntry(photo.id, file == null ? 0 : await file.length());
        } catch (_) {
          return MapEntry(photo.id, 0);
        }
      }),
    );
    originalSizes = Map<String, int>.fromEntries(entries);
  }
}
