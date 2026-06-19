import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sift/services/recycle_bin_service.dart';

class LargeFileItem {
  const LargeFileItem({
    required this.path,
    required this.name,
    required this.size,
    required this.modified,
    this.source = '',
  });

  final String path;
  final String name;
  final int size;
  final DateTime modified;

  /// Human label for the folder this file was found in (Downloads, WhatsApp…).
  final String source;

  String get extension {
    final dot = name.lastIndexOf('.');
    if (dot == -1 || dot == name.length - 1) {
      return 'FILE';
    }
    return name.substring(dot + 1).toUpperCase();
  }
}

class LargeFilesController extends GetxController {
  final Set<String> selectedPaths = <String>{};

  bool isLoading = true;
  bool isDeleting = false;
  bool hasAccess = false;
  String? errorMessage;
  List<LargeFileItem> files = <LargeFileItem>[];

  /// Whole-device storage stats, used by the donut card at the top of the
  /// screen. Loaded from the same native channel the home dashboard uses.
  static const _storageChannel = MethodChannel('sift/storage');
  int storageTotalBytes = 0;
  int storageFreeBytes = 0;

  int get storageUsedBytes => math.max(0, storageTotalBytes - storageFreeBytes);
  double get storageUsedFraction =>
      storageTotalBytes <= 0 ? 0 : storageUsedBytes / storageTotalBytes;
  bool get hasStorageStats => storageTotalBytes > 0;

  // --- Hub aggregates -------------------------------------------------------
  // Media library counts (cheap, via photo_manager). Real device data.
  int imageCount = 0;
  int videoCount = 0;
  int audioCount = 0;

  // Category aggregates derived from the document scan (real bytes/counts).
  int documentsCount = 0;
  int archivesCount = 0;
  int get largeFilesCount =>
      files.where((f) => f.size >= _largeFileBytes).length;

  // Per-source byte totals derived from the document scan.
  final Map<String, int> _sourceBytes = <String, int>{};
  int sourceBytes(String label) => _sourceBytes[label] ?? 0;
  int recentBytes = 0;

  static const int _maxFiles = 300;
  static const int _minBytes = 256 * 1024;
  static const int _largeFileBytes = 100 * 1000 * 1000; // 100 MB

  static const sourceDownloads = 'Downloads';
  static const sourceDocuments = 'Documents';
  static const sourceWhatsApp = 'WhatsApp';
  static const sourceCamera = 'Camera';

  int get selectedCount => selectedPaths.length;

  /// Files larger than [_largeFileBytes], biggest first — backs the
  /// "Large Files" tile and the document review page.
  List<LargeFileItem> get largeFiles =>
      files.where((f) => f.size >= _largeFileBytes).toList();

  @override
  void onInit() {
    super.onInit();
    loadFiles();
  }

  Future<void> loadFiles() async {
    isLoading = true;
    errorMessage = null;
    update();

    await _loadStorageStats();
    await _loadMediaCounts();
    hasAccess = await _requestStorageAccess();
    if (!hasAccess) {
      files = <LargeFileItem>[];
      selectedPaths.clear();
      _computeAggregates();
      isLoading = false;
      update();
      return;
    }

    try {
      files = await _scanLargeDocuments();
      selectedPaths.removeWhere(
        (path) => files.every((file) => file.path != path),
      );
    } catch (_) {
      files = <LargeFileItem>[];
      selectedPaths.clear();
      errorMessage =
          'Could not scan documents. Allow all files access and try again.';
    }
    _computeAggregates();

    isLoading = false;
    update();
  }

  bool isSelected(LargeFileItem file) => selectedPaths.contains(file.path);

  void toggleFile(LargeFileItem file) {
    if (!selectedPaths.add(file.path)) {
      selectedPaths.remove(file.path);
    }
    update();
  }

  void toggleSelectAll() {
    if (files.isEmpty) {
      return;
    }
    if (selectedPaths.length == files.length) {
      selectedPaths.clear();
    } else {
      selectedPaths
        ..clear()
        ..addAll(files.map((file) => file.path));
    }
    update();
  }

  Future<int> deleteSelected() async {
    if (selectedPaths.isEmpty || isDeleting) {
      return 0;
    }

    isDeleting = true;
    update();

    var deleted = 0;
    final paths = selectedPaths.toList(growable: false);
    for (final path in paths) {
      try {
        final file = File(path);
        if (await file.exists()) {
          // Soft-delete photos and videos into the recycle bin; other file
          // types (apk, zip, docs) are skipped and deleted as before.
          await Get.find<RecycleBinService>().backupFile(path);
          await file.delete();
          deleted++;
        }
      } catch (_) {
        // Keep going so one locked file does not block the cleanup.
      }
    }

    files = files.where((file) => !paths.contains(file.path)).toList();
    selectedPaths.clear();
    isDeleting = false;
    update();
    return deleted;
  }

  Future<void> _loadMediaCounts() async {
    try {
      final permission = await PhotoManager.requestPermissionExtend();
      if (!permission.hasAccess) {
        imageCount = 0;
        videoCount = 0;
        audioCount = 0;
        return;
      }
      imageCount = await PhotoManager.getAssetCount(type: RequestType.image);
      videoCount = await PhotoManager.getAssetCount(type: RequestType.video);
      audioCount = await PhotoManager.getAssetCount(type: RequestType.audio);
    } catch (_) {
      imageCount = 0;
      videoCount = 0;
      audioCount = 0;
    }
  }

  /// Rolls the scanned [files] up into the category counts and per-source byte
  /// totals the hub tiles display. All numbers are real (from the scan).
  void _computeAggregates() {
    _sourceBytes.clear();
    documentsCount = 0;
    archivesCount = 0;
    recentBytes = 0;
    final recentCutoff = DateTime.now().subtract(const Duration(days: 30));

    for (final file in files) {
      if (_isArchive(file.name)) {
        archivesCount++;
      } else {
        documentsCount++;
      }
      if (file.source.isNotEmpty) {
        _sourceBytes[file.source] =
            (_sourceBytes[file.source] ?? 0) + file.size;
      }
      if (file.modified.isAfter(recentCutoff)) {
        recentBytes += file.size;
      }
    }
  }

  bool _isArchive(String name) {
    final lower = name.toLowerCase();
    const archives = ['.zip', '.rar', '.7z', '.apk'];
    return archives.any(lower.endsWith);
  }

  Future<void> _loadStorageStats() async {
    try {
      final result = await _storageChannel.invokeMapMethod<String, dynamic>(
        'getStorageStats',
      );
      storageTotalBytes = (result?['totalBytes'] as num?)?.toInt() ?? 0;
      storageFreeBytes = (result?['freeBytes'] as num?)?.toInt() ?? 0;
    } catch (_) {
      storageTotalBytes = 0;
      storageFreeBytes = 0;
    }
  }

  Future<void> openSettings() => openAppSettings();

  Future<bool> _requestStorageAccess() async {
    if (!Platform.isAndroid) {
      return true;
    }

    if (await Permission.manageExternalStorage.isGranted) {
      return true;
    }

    final manageStatus = await Permission.manageExternalStorage.request();
    if (manageStatus.isGranted) {
      return true;
    }

    final storageStatus = await Permission.storage.request();
    return storageStatus.isGranted || storageStatus.isLimited;
  }

  Future<List<LargeFileItem>> _scanLargeDocuments() async {
    final roots = await _documentRoots();
    final byPath = <String, LargeFileItem>{};

    for (final root in roots) {
      if (!await root.dir.exists()) {
        continue;
      }
      await for (final entity in root.dir.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is! File || !_looksLikeDocument(entity.path)) {
          continue;
        }
        try {
          final stat = await entity.stat();
          if (stat.size < _minBytes) {
            continue;
          }
          // First root that finds a path wins its label (roots are ordered).
          if (byPath.containsKey(entity.path)) {
            continue;
          }
          byPath[entity.path] = LargeFileItem(
            path: entity.path,
            name: entity.uri.pathSegments.isEmpty
                ? entity.path
                : entity.uri.pathSegments.last,
            size: stat.size,
            modified: stat.modified,
            source: root.label,
          );
        } catch (_) {
          // Ignore files we cannot stat.
        }
      }
    }

    final items = byPath.values.toList()
      ..sort((a, b) {
        final sizeCompare = b.size.compareTo(a.size);
        if (sizeCompare != 0) {
          return sizeCompare;
        }
        return b.modified.compareTo(a.modified);
      });
    return items.take(_maxFiles).toList();
  }

  Future<List<({String label, Directory dir})>> _documentRoots() async {
    if (Platform.isAndroid) {
      return [
        (label: sourceDownloads, dir: Directory('/storage/emulated/0/Download')),
        (
          label: sourceDocuments,
          dir: Directory('/storage/emulated/0/Documents'),
        ),
        (label: sourceCamera, dir: Directory('/storage/emulated/0/DCIM')),
        (
          label: sourceWhatsApp,
          dir: Directory('/storage/emulated/0/WhatsApp/Media/WhatsApp Documents'),
        ),
        (
          label: sourceWhatsApp,
          dir: Directory(
            '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Documents',
          ),
        ),
      ];
    }

    final docs = await getApplicationDocumentsDirectory();
    final downloads = await getDownloadsDirectory();
    return [
      (label: sourceDocuments, dir: docs),
      if (downloads != null) (label: sourceDownloads, dir: downloads),
    ];
  }

  bool _looksLikeDocument(String path) {
    final lower = path.toLowerCase();
    const extensions = [
      '.pdf',
      '.doc',
      '.docx',
      '.xls',
      '.xlsx',
      '.ppt',
      '.pptx',
      '.txt',
      '.rtf',
      '.csv',
      '.zip',
      '.rar',
      '.7z',
      '.apk',
      '.epub',
    ];
    return extensions.any(lower.endsWith);
  }
}
