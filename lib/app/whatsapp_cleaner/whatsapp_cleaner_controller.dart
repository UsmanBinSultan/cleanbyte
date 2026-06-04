import 'dart:io';

import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class WhatsappCleanerController extends GetxController {
  static WhatsappCleanerController instance = Get.find();
  static _WhatsappSummaryCache? _summaryCache;

  bool isLoadingSummary = true;
  bool hasAccess = false;
  Map<WhatsappMediaType, int> bytesByType = <WhatsappMediaType, int>{};
  Map<WhatsappMediaType, int> countByType = <WhatsappMediaType, int>{};

  int get totalBytes =>
      bytesByType.values.fold(0, (total, size) => total + size);
  int get totalCount =>
      countByType.values.fold(0, (total, count) => total + count);

  @override
  void onInit() {
    super.onInit();
    if (_restoreSummaryCache()) {
      return;
    }
    loadSummary();
  }

  Future<void> loadSummary() async {
    final showLoading = _summaryCache == null;
    if (showLoading) {
      isLoadingSummary = true;
      update();
    }

    final summaries = <WhatsappMediaType, List<WhatsappMediaItem>>{};
    var access = true;
    for (final type in WhatsappMediaType.values) {
      final controller = WhatsappMediaController(type: type);
      access = await controller.requestStorageAccessForSummary();
      if (!access) {
        break;
      }
      summaries[type] = await controller.scanWhatsappItemsForSummary();
    }

    hasAccess = access;
    bytesByType = {
      for (final entry in summaries.entries)
        entry.key: entry.value.fold(0, (total, item) => total + item.size),
    };
    countByType = {
      for (final entry in summaries.entries) entry.key: entry.value.length,
    };
    _summaryCache = _WhatsappSummaryCache(
      hasAccess: hasAccess,
      bytesByType: bytesByType,
      countByType: countByType,
    );
    isLoadingSummary = false;
    update();
  }

  bool _restoreSummaryCache() {
    final cache = _summaryCache;
    if (cache == null) {
      return false;
    }
    hasAccess = cache.hasAccess;
    bytesByType = Map<WhatsappMediaType, int>.from(cache.bytesByType);
    countByType = Map<WhatsappMediaType, int>.from(cache.countByType);
    isLoadingSummary = false;
    return true;
  }

  static void updateSummaryAfterDelete(
    WhatsappMediaType type,
    List<WhatsappMediaItem> deletedItems,
  ) {
    final cache = _summaryCache;
    if (cache == null || deletedItems.isEmpty) {
      return;
    }

    final removedBytes = deletedItems.fold<int>(
      0,
      (total, item) => total + item.size,
    );
    final bytesByType = Map<WhatsappMediaType, int>.from(cache.bytesByType);
    final countByType = Map<WhatsappMediaType, int>.from(cache.countByType);
    final nextBytes = (bytesByType[type] ?? 0) - removedBytes;
    final nextCount = (countByType[type] ?? 0) - deletedItems.length;
    bytesByType[type] = nextBytes < 0 ? 0 : nextBytes;
    countByType[type] = nextCount < 0 ? 0 : nextCount;
    _summaryCache = _WhatsappSummaryCache(
      hasAccess: cache.hasAccess,
      bytesByType: bytesByType,
      countByType: countByType,
    );
  }
}

class _WhatsappSummaryCache {
  const _WhatsappSummaryCache({
    required this.hasAccess,
    required this.bytesByType,
    required this.countByType,
  });

  final bool hasAccess;
  final Map<WhatsappMediaType, int> bytesByType;
  final Map<WhatsappMediaType, int> countByType;
}

enum WhatsappMediaType {
  images,
  videos,
  voiceNotes,
  documents;

  String get title {
    switch (this) {
      case WhatsappMediaType.images:
        return 'Images';
      case WhatsappMediaType.videos:
        return 'Videos';
      case WhatsappMediaType.voiceNotes:
        return 'Voice Notes';
      case WhatsappMediaType.documents:
        return 'Documents';
    }
  }

  bool get usesGrid =>
      this == WhatsappMediaType.images || this == WhatsappMediaType.videos;

  List<String> get folderNames {
    switch (this) {
      case WhatsappMediaType.images:
        return ['WhatsApp Images'];
      case WhatsappMediaType.videos:
        return ['WhatsApp Video'];
      case WhatsappMediaType.voiceNotes:
        return ['WhatsApp Voice Notes', 'WhatsApp Audio'];
      case WhatsappMediaType.documents:
        return ['WhatsApp Documents'];
    }
  }

  List<String> get extensions {
    switch (this) {
      case WhatsappMediaType.images:
        return ['.jpg', '.jpeg', '.png', '.webp', '.heic'];
      case WhatsappMediaType.videos:
        return ['.mp4', '.3gp', '.mkv', '.mov'];
      case WhatsappMediaType.voiceNotes:
        return ['.opus', '.m4a', '.aac', '.mp3', '.ogg', '.amr'];
      case WhatsappMediaType.documents:
        return [
          '.pdf',
          '.doc',
          '.docx',
          '.xls',
          '.xlsx',
          '.ppt',
          '.pptx',
          '.txt',
          '.zip',
          '.rar',
          '.apk',
        ];
    }
  }
}

class WhatsappMediaItem {
  const WhatsappMediaItem({
    required this.path,
    required this.name,
    required this.size,
    required this.modified,
  });

  final String path;
  final String name;
  final int size;
  final DateTime modified;

  File get file => File(path);

  String get extension {
    final dot = name.lastIndexOf('.');
    if (dot == -1 || dot == name.length - 1) {
      return 'FILE';
    }
    return name.substring(dot + 1).toUpperCase();
  }
}

class WhatsappMediaController extends GetxController {
  static final Map<WhatsappMediaType, _WhatsappMediaCache> _cache =
      <WhatsappMediaType, _WhatsappMediaCache>{};

  WhatsappMediaController({required this.type});

  final WhatsappMediaType type;
  final Set<String> selectedPaths = <String>{};

  bool isLoading = true;
  bool isDeleting = false;
  bool hasAccess = false;
  String? errorMessage;
  List<WhatsappMediaItem> items = <WhatsappMediaItem>[];

  int get selectedCount => selectedPaths.length;
  int get totalBytes => items.fold(0, (total, item) => total + item.size);

  @override
  void onInit() {
    super.onInit();
    if (_restoreCache()) {
      return;
    }
    loadItems();
  }

  Future<void> loadItems() async {
    isLoading = items.isEmpty;
    errorMessage = null;
    update();

    hasAccess = await _requestStorageAccess();
    if (!hasAccess) {
      items = <WhatsappMediaItem>[];
      selectedPaths.clear();
      _cache[type] = _WhatsappMediaCache(
        hasAccess: hasAccess,
        items: items,
        errorMessage: null,
      );
      isLoading = false;
      update();
      return;
    }

    try {
      items = await _scanWhatsappItems();
      selectedPaths.removeWhere(
        (path) => items.every((item) => item.path != path),
      );
      _cache[type] = _WhatsappMediaCache(
        hasAccess: hasAccess,
        items: items,
        errorMessage: null,
      );
    } catch (_) {
      items = <WhatsappMediaItem>[];
      selectedPaths.clear();
      errorMessage =
          'Could not scan WhatsApp ${type.title.toLowerCase()}. Allow file access and try again.';
      _cache[type] = _WhatsappMediaCache(
        hasAccess: hasAccess,
        items: items,
        errorMessage: errorMessage,
      );
    }

    isLoading = false;
    update();
  }

  bool _restoreCache() {
    final cached = _cache[type];
    if (cached == null) {
      return false;
    }
    hasAccess = cached.hasAccess;
    items = List<WhatsappMediaItem>.from(cached.items);
    errorMessage = cached.errorMessage;
    selectedPaths.removeWhere(
      (path) => items.every((item) => item.path != path),
    );
    isLoading = false;
    return true;
  }

  bool isSelected(WhatsappMediaItem item) => selectedPaths.contains(item.path);

  void toggleItem(WhatsappMediaItem item) {
    if (!selectedPaths.add(item.path)) {
      selectedPaths.remove(item.path);
    }
    update();
  }

  void toggleSelectAll() {
    if (items.isEmpty) {
      return;
    }
    if (selectedPaths.length == items.length) {
      selectedPaths.clear();
    } else {
      selectedPaths
        ..clear()
        ..addAll(items.map((item) => item.path));
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
    final deletedItems = <WhatsappMediaItem>[];
    final paths = selectedPaths.toList(growable: false);
    for (final path in paths) {
      try {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
          deleted++;
          for (final item in items) {
            if (item.path == path) {
              deletedItems.add(item);
              break;
            }
          }
        }
      } catch (_) {
        // Keep deleting the rest if one WhatsApp file is protected.
      }
    }

    items = items.where((item) => !paths.contains(item.path)).toList();
    _cache[type] = _WhatsappMediaCache(
      hasAccess: hasAccess,
      items: items,
      errorMessage: errorMessage,
    );
    WhatsappCleanerController.updateSummaryAfterDelete(type, deletedItems);
    selectedPaths.clear();
    isDeleting = false;
    update();
    return deleted;
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

  Future<bool> requestStorageAccessForSummary() => _requestStorageAccess();

  Future<List<WhatsappMediaItem>> _scanWhatsappItems() async {
    final roots = _whatsappRoots();
    final found = <String, WhatsappMediaItem>{};

    for (final root in roots) {
      if (!await root.exists()) {
        continue;
      }
      await for (final entity in root.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is! File || !_matchesType(entity.path)) {
          continue;
        }
        try {
          final stat = await entity.stat();
          if (stat.size <= 0) {
            continue;
          }
          found[entity.path] = WhatsappMediaItem(
            path: entity.path,
            name: entity.uri.pathSegments.isEmpty
                ? entity.path
                : Uri.decodeComponent(entity.uri.pathSegments.last),
            size: stat.size,
            modified: stat.modified,
          );
        } catch (_) {
          // Ignore files that cannot be read.
        }
      }
    }

    final sorted = found.values.toList()
      ..sort((a, b) => b.modified.compareTo(a.modified));
    return sorted;
  }

  Future<List<WhatsappMediaItem>> scanWhatsappItemsForSummary() {
    return _scanWhatsappItems();
  }

  List<Directory> _whatsappRoots() {
    final bases = [
      '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media',
      '/storage/emulated/0/Android/media/com.whatsapp.w4b/WhatsApp Business/Media',
      '/storage/emulated/0/WhatsApp/Media',
      '/storage/emulated/0/WhatsApp Business/Media',
    ];

    return [
      for (final base in bases)
        for (final folder in type.folderNames) Directory('$base/$folder'),
    ];
  }

  bool _matchesType(String path) {
    final lower = path.toLowerCase();
    if (lower.contains('/.statuses/')) {
      return false;
    }
    return type.extensions.any(lower.endsWith);
  }
}

class _WhatsappMediaCache {
  const _WhatsappMediaCache({
    required this.hasAccess,
    required this.items,
    required this.errorMessage,
  });

  final bool hasAccess;
  final List<WhatsappMediaItem> items;
  final String? errorMessage;
}
