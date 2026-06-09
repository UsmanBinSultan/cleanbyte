import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sift/models/photo_category.dart';
import 'package:sift/services/photo_categorizer.dart';

class CategorizedPhoto {
  const CategorizedPhoto({required this.asset, required this.categories});

  final AssetEntity asset;
  final Set<PhotoCategory> categories;

  PhotoCategory get primaryCategory {
    for (final category in AiCategoriesController.categoryOrder) {
      if (category != PhotoCategory.all && categories.contains(category)) {
        return category;
      }
    }
    return PhotoCategory.uncategorized;
  }
}

class AiCategoriesScanCache {
  AiCategoriesScanCache._();

  static final AiCategoriesScanCache instance = AiCategoriesScanCache._();

  bool hasAccess = false;
  bool isComplete = false;
  String? errorMessage;
  int scannedCount = 0;
  int totalToScan = 0;
  List<CategorizedPhoto> photos = <CategorizedPhoto>[];

  bool get hasPhotos => isComplete && photos.isNotEmpty;

  void save({
    required bool hasAccess,
    required int scannedCount,
    required int totalToScan,
    required List<CategorizedPhoto> photos,
    String? errorMessage,
    bool isComplete = true,
  }) {
    this.hasAccess = hasAccess;
    this.scannedCount = scannedCount;
    this.totalToScan = totalToScan;
    this.photos = List<CategorizedPhoto>.from(photos);
    this.errorMessage = errorMessage;
    this.isComplete = isComplete;
  }

  void clear() {
    hasAccess = false;
    isComplete = false;
    errorMessage = null;
    scannedCount = 0;
    totalToScan = 0;
    photos = <CategorizedPhoto>[];
  }
}

class AiCategoriesController extends GetxController {
  static AiCategoriesController instance = Get.find();

  static const int _pageSize = 80;
  static const String _scanCacheFileName = 'ai_categories_scan_cache.json';
  static const categoryOrder = [
    PhotoCategory.all,
    PhotoCategory.screenshots,
    PhotoCategory.documents,
    PhotoCategory.children,
    PhotoCategory.people,
    PhotoCategory.flowers,
    PhotoCategory.eyeglasses,
    PhotoCategory.food,
    PhotoCategory.transportation,
    PhotoCategory.clothing,
    PhotoCategory.shoes,
    PhotoCategory.vehicles,
    PhotoCategory.cars,
    PhotoCategory.architecture,
    PhotoCategory.sky,
    PhotoCategory.electronics,
    PhotoCategory.sportsExercise,
    PhotoCategory.pets,
    PhotoCategory.animals,
    PhotoCategory.nature,
    PhotoCategory.uncategorized,
  ];

  final List<PhotoCategorizer> _categorizers = List.generate(
    4,
    (_) => PhotoCategorizer(),
  );

  bool isLoading = true;
  bool isScanning = false;
  bool hasAccess = false;
  String? errorMessage;
  int scannedCount = 0;
  int totalToScan = 0;
  PhotoCategory selectedCategory = PhotoCategory.all;
  List<CategorizedPhoto> photos = <CategorizedPhoto>[];

  @override
  void onInit() {
    super.onInit();
    if (!_restoreCachedScan()) {
      unawaited(_restorePersistedScanOrScan());
    }
  }

  @override
  void onClose() {
    for (final categorizer in _categorizers) {
      categorizer.dispose();
    }
    super.onClose();
  }

  double get progress => totalToScan == 0 ? 0 : scannedCount / totalToScan;

  /// Scan progress as a whole percentage, for display.
  int get progressPercent => (progress * 100).round();

  int get totalPhotos => photos.length;

  List<PhotoCategory> get visibleCategories {
    final categories = <PhotoCategory>[PhotoCategory.all];
    final detected = <PhotoCategory>[];
    for (final category in categoryOrder) {
      if (category == PhotoCategory.all) {
        continue;
      }
      if (countFor(category) > 0) {
        detected.add(category);
      }
    }
    detected.sort((a, b) {
      final countCompare = countFor(b).compareTo(countFor(a));
      if (countCompare != 0) {
        return countCompare;
      }
      return categoryOrder.indexOf(a).compareTo(categoryOrder.indexOf(b));
    });
    categories.addAll(detected);
    return categories;
  }

  List<CategorizedPhoto> get filteredPhotos => photosFor(selectedCategory);

  /// Photos belonging to [category] (all photos for [PhotoCategory.all]).
  List<CategorizedPhoto> photosFor(PhotoCategory category) {
    if (category == PhotoCategory.all) {
      return photos;
    }
    return photos
        .where((photo) => photo.categories.contains(category))
        .toList(growable: false);
  }

  int countFor(PhotoCategory category) {
    if (category == PhotoCategory.all) {
      return photos.length;
    }
    return photos.where((photo) => photo.categories.contains(category)).length;
  }

  AssetEntity? thumbnailFor(PhotoCategory category) {
    final source = category == PhotoCategory.all
        ? photos
        : photos.where((photo) => photo.categories.contains(category));
    for (final photo in source) {
      return photo.asset;
    }
    return null;
  }

  void openCategory(PhotoCategory category) {
    selectedCategory = category;
    update();
  }

  Future<void> scanLibrary({bool force = false}) async {
    if (isScanning) {
      return;
    }
    if (!force && _restoreCachedScan()) {
      return;
    }

    if (force) {
      AiCategoriesScanCache.instance.clear();
      await _clearPersistedScan();
    }

    isLoading = photos.isEmpty;
    isScanning = true;
    errorMessage = null;
    scannedCount = 0;
    totalToScan = 0;
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
      photos = <CategorizedPhoto>[];
      errorMessage = 'Photo access is needed to build AI categories.';
      AiCategoriesScanCache.instance.save(
        hasAccess: false,
        scannedCount: scannedCount,
        totalToScan: totalToScan,
        photos: photos,
        errorMessage: errorMessage,
      );
      unawaited(_savePersistedScan());
      _finishScan();
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
        photos = <CategorizedPhoto>[];
        AiCategoriesScanCache.instance.save(
          hasAccess: hasAccess,
          scannedCount: scannedCount,
          totalToScan: totalToScan,
          photos: photos,
        );
        unawaited(_savePersistedScan());
        _finishScan();
        return;
      }

      final recent = paths.first;
      totalToScan = await recent.assetCountAsync;
      update();

      final categorized = <CategorizedPhoto>[];
      var start = 0;

      while (start < totalToScan) {
        final end = (start + _pageSize).clamp(0, totalToScan);
        final assets = await recent.getAssetListRange(start: start, end: end);

        for (
          var batchStart = 0;
          batchStart < assets.length;
          batchStart += _categorizers.length
        ) {
          final batch = assets
              .skip(batchStart)
              .take(_categorizers.length)
              .toList();
          final batchBaseIndex = start + batchStart;
          final results = await Future.wait(
            List.generate(batch.length, (index) async {
              final asset = batch[index];
              final categorizer =
                  _categorizers[(batchBaseIndex + index) %
                      _categorizers.length];
              final categories = await categorizer.categorize(asset);
              return CategorizedPhoto(asset: asset, categories: categories);
            }),
          );
          categorized.addAll(results);
          scannedCount += results.length;
          photos = List<CategorizedPhoto>.from(categorized);
          AiCategoriesScanCache.instance.save(
            hasAccess: hasAccess,
            scannedCount: scannedCount,
            totalToScan: totalToScan,
            photos: photos,
            isComplete: false,
          );
          update();
        }

        start = end;
      }

      if (!visibleCategories.contains(selectedCategory)) {
        selectedCategory = PhotoCategory.all;
      }
      AiCategoriesScanCache.instance.save(
        hasAccess: hasAccess,
        scannedCount: scannedCount,
        totalToScan: totalToScan,
        photos: photos,
      );
      unawaited(_savePersistedScan());
    } catch (_) {
      errorMessage = 'Could not categorize your photos. Please try again.';
      photos = <CategorizedPhoto>[];
      AiCategoriesScanCache.instance.save(
        hasAccess: hasAccess,
        scannedCount: scannedCount,
        totalToScan: totalToScan,
        photos: photos,
        errorMessage: errorMessage,
      );
      unawaited(_clearPersistedScan());
    } finally {
      _finishScan();
    }
  }

  Future<void> openSettings() => PhotoManager.openSetting();

  bool _restoreCachedScan() {
    final cache = AiCategoriesScanCache.instance;
    if (!cache.isComplete && !cache.hasPhotos) {
      return false;
    }
    hasAccess = cache.hasAccess;
    errorMessage = cache.errorMessage;
    scannedCount = cache.scannedCount;
    totalToScan = cache.totalToScan;
    photos = List<CategorizedPhoto>.from(cache.photos);
    isLoading = false;
    isScanning = false;
    if (!visibleCategories.contains(selectedCategory)) {
      selectedCategory = PhotoCategory.all;
    }
    update();
    return true;
  }

  void _finishScan() {
    isLoading = false;
    isScanning = false;
    update();
  }

  Future<void> _restorePersistedScanOrScan() async {
    if (await _restorePersistedScan()) {
      return;
    }
    await scanLibrary();
  }

  Future<bool> _restorePersistedScan() async {
    try {
      final file = await _scanCacheFile();
      if (!await file.exists()) {
        return false;
      }

      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map<String, dynamic>) {
        return false;
      }

      final rawPhotos = decoded['photos'];
      if (rawPhotos is! List) {
        return false;
      }

      final restoredPhotos = <CategorizedPhoto>[];
      for (final rawPhoto in rawPhotos) {
        if (rawPhoto is! Map) {
          continue;
        }
        final id = rawPhoto['id'] as String?;
        final rawCategories = rawPhoto['categories'];
        if (id == null || rawCategories is! List) {
          continue;
        }

        final asset = await AssetEntity.fromId(id);
        if (asset == null) {
          continue;
        }
        restoredPhotos.add(
          CategorizedPhoto(
            asset: asset,
            categories: rawCategories
                .whereType<String>()
                .map(_categoryFromName)
                .toSet(),
          ),
        );
      }

      hasAccess = decoded['hasAccess'] == true;
      errorMessage = decoded['errorMessage'] as String?;
      scannedCount = decoded['scannedCount'] as int? ?? restoredPhotos.length;
      totalToScan = decoded['totalToScan'] as int? ?? scannedCount;
      photos = restoredPhotos;
      isLoading = false;
      isScanning = false;

      AiCategoriesScanCache.instance.save(
        hasAccess: hasAccess,
        scannedCount: scannedCount,
        totalToScan: totalToScan,
        photos: photos,
        errorMessage: errorMessage,
      );
      if (!visibleCategories.contains(selectedCategory)) {
        selectedCategory = PhotoCategory.all;
      }
      update();
      return true;
    } catch (_) {
      await _clearPersistedScan();
      return false;
    }
  }

  Future<void> _savePersistedScan() async {
    try {
      final file = await _scanCacheFile();
      final data = <String, dynamic>{
        'hasAccess': hasAccess,
        'errorMessage': errorMessage,
        'scannedCount': scannedCount,
        'totalToScan': totalToScan,
        'savedAt': DateTime.now().toIso8601String(),
        'photos': photos
            .map(
              (photo) => <String, dynamic>{
                'id': photo.asset.id,
                'categories': photo.categories
                    .map((category) => category.name)
                    .toList(growable: false),
              },
            )
            .toList(growable: false),
      };
      await file.writeAsString(jsonEncode(data), flush: true);
    } catch (_) {
      // The in-memory cache still keeps the current session usable.
    }
  }

  Future<void> _clearPersistedScan() async {
    try {
      final file = await _scanCacheFile();
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // A stale cache should never block a fresh scan.
    }
  }

  Future<File> _scanCacheFile() async {
    final directory = await getApplicationSupportDirectory();
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return File(
      '${directory.path}${Platform.pathSeparator}$_scanCacheFileName',
    );
  }

  PhotoCategory _categoryFromName(String name) {
    for (final category in PhotoCategory.values) {
      if (category.name == name) {
        return category;
      }
    }
    return PhotoCategory.uncategorized;
  }
}
