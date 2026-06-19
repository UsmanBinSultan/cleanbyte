import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as contacts;
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sift/app/apps_manager/apps_manager_controller.dart';
import 'package:sift/app/duplicate_contacts/duplicate_contacts_controller.dart';
import 'package:sift/app/large_files/large_files_controller.dart';
import 'package:sift/app/routes/app_routes.dart';
import 'package:sift/app/whatsapp_cleaner/whatsapp_cleaner_controller.dart';
import 'package:sift/services/blur_cache.dart';

class StorageSnapshot {
  const StorageSnapshot({required this.totalBytes, required this.freeBytes});

  final int totalBytes;
  final int freeBytes;

  int get usedBytes => math.max(0, totalBytes - freeBytes);
  double get usedFraction => totalBytes <= 0 ? 0 : usedBytes / totalBytes;
}

class DashboardMetric {
  const DashboardMetric({
    required this.count,
    required this.bytes,
    this.labelOverride,
  });

  const DashboardMetric.empty() : this(count: 0, bytes: 0);

  final int count;
  final int bytes;
  final String? labelOverride;

  String get subtitle {
    if (labelOverride != null) {
      return labelOverride!.tr;
    }
    final itemLabel = count == 1 ? 'item' : 'items';
    if (bytes <= 0) {
      return '$count ${itemLabel.tr}';
    }
    return '$count ${itemLabel.tr}  ${HomeDashboardController.formatBytes(bytes)}';
  }
}

class HomeDashboardController extends GetxController {
  static HomeDashboardController instance = Get.find();
  static const _storageChannel = MethodChannel('sift/storage');
  static const _appsChannel = MethodChannel('sift/apps');
  static const int _mediaPreviewLimit = 960;

  int selectedIndex = 0;
  bool isLoadingSummary = true;
  bool isQuickCleaning = false;
  // Whether photo/media access has been granted. The dashboard shows no storage
  // or metrics until this is true.
  bool hasMediaAccess = false;
  StorageSnapshot storage = const StorageSnapshot(totalBytes: 0, freeBytes: 0);
  Map<String, DashboardMetric> metrics = <String, DashboardMetric>{};
  Set<String> loadingMetricKeys = <String>{};
  int reclaimableBytes = 0;
  int quickCleanReadyBytes = 0;
  int lastQuickCleanBytes = 0;

  static const similarPhotosKey = 'similarPhotos';
  static const largeVideosKey = 'largeVideos';
  static const screenshotsKey = 'screenshots';
  static const invisiblePhotosKey = 'invisiblePhotos';
  static const livePhotosKey = 'livePhotos';
  static const duplicatesKey = 'duplicates';
  static const blurredPhotosKey = 'blurredPhotos';
  static const largeFilesKey = 'largeFiles';
  static const duplicateContactsKey = 'duplicateContacts';
  static const aiCleanupKey = 'aiCleanup';
  static const whatsappCleanerKey = 'whatsappCleaner';
  static const appsManagerKey = 'appsManager';
  static const photoCompressorKey = 'photoCompressor';
  static const batteryManagerKey = 'batteryManager';

  @override
  void onInit() {
    super.onInit();
    refreshSummary();
  }

  void changeTab(int index) {
    selectedIndex = index;
    update();
  }

  /// Current media-permission state without prompting the user.
  Future<bool> _checkMediaAccess() async {
    try {
      final state = await PhotoManager.getPermissionState(
        requestOption: const PermissionRequestOption(),
      );
      return state.hasAccess;
    } catch (_) {
      return false;
    }
  }

  /// Prompt for media access (from the home "grant access" gate), then load.
  Future<void> requestMediaAccess() async {
    final result = await PhotoManager.requestPermissionExtend();
    hasMediaAccess = result.hasAccess;
    update();
    if (hasMediaAccess) {
      await refreshSummary();
    }
  }

  Future<void> openMediaSettings() => PhotoManager.openSetting();

  Future<void> refreshSummary() async {
    isLoadingSummary = true;
    update();

    // Show nothing until the user has granted access.
    hasMediaAccess = await _checkMediaAccess();
    if (!hasMediaAccess) {
      storage = const StorageSnapshot(totalBytes: 0, freeBytes: 0);
      metrics = <String, DashboardMetric>{};
      loadingMetricKeys = <String>{};
      reclaimableBytes = 0;
      quickCleanReadyBytes = 0;
      isLoadingSummary = false;
      update();
      return;
    }

    loadingMetricKeys = {
      similarPhotosKey,
      largeVideosKey,
      screenshotsKey,
      invisiblePhotosKey,
      livePhotosKey,
      duplicatesKey,
      blurredPhotosKey,
      largeFilesKey,
      duplicateContactsKey,
      aiCleanupKey,
      whatsappCleanerKey,
      appsManagerKey,
      photoCompressorKey,
      batteryManagerKey,
    };
    update();

    storage = await _loadStorage();
    quickCleanReadyBytes = await _quickCleanBytes();
    update();

    var media = const _MediaDashboardMetrics.empty();
    var largeFiles = const DashboardMetric.empty();
    var whatsapp = const DashboardMetric.empty();

    media = await _loadMediaMetrics();
    _setMetrics({
      similarPhotosKey: media.photos,
      largeVideosKey: media.videos,
      screenshotsKey: media.screenshots,
      invisiblePhotosKey: media.invisiblePhotos,
      livePhotosKey: media.livePhotos,
      duplicatesKey: media.duplicates,
      blurredPhotosKey: media.blurredPhotos,
      photoCompressorKey: DashboardMetric(
        count: media.photos.count,
        bytes: media.photos.bytes,
        labelOverride:
            '${media.photos.count} ${(media.photos.count == 1 ? 'photo' : 'photos').tr}  ${formatBytes(media.photos.bytes)}',
      ),
    });
    _refreshCleanupMetrics(media, largeFiles);

    largeFiles = await _loadLargeFileMetric();
    _setMetrics({largeFilesKey: largeFiles});
    _refreshCleanupMetrics(media, largeFiles);

    whatsapp = await _loadWhatsappMetric();
    _setMetrics({
      whatsappCleanerKey: DashboardMetric(
        count: whatsapp.count,
        bytes: whatsapp.bytes,
        labelOverride: '${'whatsapp'.tr}  ${formatBytes(whatsapp.bytes)}',
      ),
    });

    final apps = await _loadAppsMetric();
    _setMetrics({
      appsManagerKey: DashboardMetric(
        count: apps.count,
        bytes: apps.bytes,
        labelOverride:
            '${apps.count} ${(apps.count == 1 ? 'app' : 'apps').tr}  ${formatBytes(apps.bytes)}',
      ),
    });

    final contactsMetric = await _loadDuplicateContactMetric();
    _setMetrics({duplicateContactsKey: contactsMetric});

    _setMetrics({
      batteryManagerKey: const DashboardMetric(
        count: 0,
        bytes: 0,
        labelOverride: 'open_health',
      ),
    });
    isLoadingSummary = false;
    update();
  }

  DashboardMetric metric(String key) =>
      metrics[key] ?? const DashboardMetric.empty();

  String metricSubtitle(String key) {
    if (loadingMetricKeys.contains(key) && !metrics.containsKey(key)) {
      return 'calculating'.tr;
    }
    return metric(key).subtitle;
  }

  String get cleanupRoute {
    final candidates = <MapEntry<String, DashboardMetric>>[
      MapEntry(duplicatesKey, metric(duplicatesKey)),
      MapEntry(screenshotsKey, metric(screenshotsKey)),
      MapEntry(largeFilesKey, metric(largeFilesKey)),
      MapEntry(whatsappCleanerKey, metric(whatsappCleanerKey)),
    ]..sort((a, b) => b.value.bytes.compareTo(a.value.bytes));

    final key = candidates
        .firstWhere(
          (entry) => entry.value.count > 0 || entry.value.bytes > 0,
          orElse: () => const MapEntry(aiCleanupKey, DashboardMetric.empty()),
        )
        .key;

    switch (key) {
      case duplicatesKey:
        return AppRoutes.duplicates;
      case screenshotsKey:
        return AppRoutes.screenshots;
      case invisiblePhotosKey:
        return AppRoutes.invisiblePhotos;
      case largeFilesKey:
        return AppRoutes.largeFiles;
      case whatsappCleanerKey:
        return AppRoutes.whatsappCleaner;
      default:
        return AppRoutes.aiCategories;
    }
  }

  void _setMetrics(Map<String, DashboardMetric> values) {
    metrics = {...metrics, ...values};
    loadingMetricKeys.removeAll(values.keys);
    update();
  }

  void _refreshCleanupMetrics(
    _MediaDashboardMetrics media,
    DashboardMetric largeFiles,
  ) {
    // WhatsApp media is excluded here: it has its own dedicated cleaner card
    // and is not part of the on-device library scan this metric feeds into
    // (the "free up" banner and "ai cleanup" card both open the initial scan).
    final duplicateBytes = media.duplicateReclaimableBytes;
    reclaimableBytes =
        duplicateBytes + media.screenshots.bytes + largeFiles.bytes;
    _setMetrics({
      aiCleanupKey: DashboardMetric(
        count:
            media.duplicates.count +
            media.screenshots.count +
            largeFiles.count,
        bytes: reclaimableBytes,
        labelOverride: '${formatBytes(reclaimableBytes)} ${'junk'.tr}',
      ),
    });
  }

  Future<void> quickClean() async {
    if (isQuickCleaning) {
      return;
    }
    isQuickCleaning = true;
    update();

    try {
      final before = await _directoryBytes(await _quickCleanDirectories());
      for (final directory in await _quickCleanDirectories()) {
        await _deleteDirectoryContents(directory);
      }
      final after = await _directoryBytes(await _quickCleanDirectories());
      lastQuickCleanBytes = math.max(0, before - after);
      quickCleanReadyBytes = after;
      await refreshSummary();
    } finally {
      isQuickCleaning = false;
      update();
    }

    Get.snackbar(
      'Quick Clean complete'.tr,
      lastQuickCleanBytes > 0
          ? 'Freed ${formatBytes(lastQuickCleanBytes)} from app cache.'
          : 'No app cache was ready to clean.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  static String formatBytes(num bytes) {
    if (bytes <= 0) {
      return '0 MB';
    }
    const kb = 1024;
    const mb = kb * 1024;
    const gb = mb * 1024;
    if (bytes >= gb) {
      final value = bytes / gb;
      return '${value >= 10 ? value.toStringAsFixed(0) : value.toStringAsFixed(1)} GB';
    }
    if (bytes >= mb) {
      final value = bytes / mb;
      return '${value >= 10 ? value.toStringAsFixed(0) : value.toStringAsFixed(1)} MB';
    }
    return '${(bytes / kb).toStringAsFixed(1)} KB';
  }

  Future<StorageSnapshot> _loadStorage() async {
    try {
      final result = await _storageChannel.invokeMapMethod<String, dynamic>(
        'getStorageStats',
      );
      return StorageSnapshot(
        totalBytes: (result?['totalBytes'] as num?)?.toInt() ?? 0,
        freeBytes: (result?['freeBytes'] as num?)?.toInt() ?? 0,
      );
    } catch (_) {
      return const StorageSnapshot(totalBytes: 0, freeBytes: 0);
    }
  }

  Future<_MediaDashboardMetrics> _loadMediaMetrics() async {
    final imagePermission = await PhotoManager.requestPermissionExtend(
      requestOption: const PermissionRequestOption(
        androidPermission: AndroidPermission(
          type: RequestType.image,
          mediaLocation: false,
        ),
      ),
    );
    final videoPermission = await PhotoManager.requestPermissionExtend(
      requestOption: const PermissionRequestOption(
        androidPermission: AndroidPermission(
          type: RequestType.video,
          mediaLocation: false,
        ),
      ),
    );

    final imageAssets = imagePermission.hasAccess
        ? await _loadAssets(RequestType.image)
        : <AssetEntity>[];
    final videoAssets = videoPermission.hasAccess
        ? await _loadAssets(RequestType.video)
        : <AssetEntity>[];
    final screenshots = imagePermission.hasAccess
        ? await _loadScreenshotAssets()
        : <AssetEntity>[];
    final invisiblePhotos = imagePermission.hasAccess
        ? await _loadInvisiblePhotoAssets()
        : <AssetEntity>[];
    final hasFullImageAccess = imagePermission.isAuth;

    _setMetrics({
      similarPhotosKey: DashboardMetric(
        count: imageAssets.length,
        bytes: 0,
        labelOverride: hasFullImageAccess
            ? null
            : '${imageAssets.length} ${(imageAssets.length == 1 ? 'photo' : 'photos').tr}  ${'limited access'.tr}',
      ),
      largeVideosKey: DashboardMetric(count: videoAssets.length, bytes: 0),
      screenshotsKey: DashboardMetric(count: screenshots.length, bytes: 0),
      invisiblePhotosKey: DashboardMetric(
        count: invisiblePhotos.length,
        bytes: 0,
      ),
      photoCompressorKey: DashboardMetric(
        count: imageAssets.length,
        bytes: 0,
        labelOverride:
            '${imageAssets.length} ${(imageAssets.length == 1 ? 'photo' : 'photos').tr}',
      ),
    });

    final imageSizes = await _measureAssets(imageAssets);
    final videoSizes = await _measureAssets(videoAssets);
    final screenshotBytes = screenshots.fold<int>(
      0,
      (total, asset) => total + (imageSizes[asset.id] ?? 0),
    );
    final invisibleBytes = invisiblePhotos.fold<int>(
      0,
      (total, asset) => total + (imageSizes[asset.id] ?? 0),
    );
    final duplicateCandidates = imageAssets
        .take(_mediaPreviewLimit)
        .toList(growable: false);
    final duplicateStats = _duplicateStats(duplicateCandidates, imageSizes);
    final cachedBlurResults = await BlurCache.instance.validForAssetIds(
      imageAssets.map((asset) => asset.id),
    );
    final blurredCount = cachedBlurResults
        .where((result) => result.isBlurry)
        .length;

    return _MediaDashboardMetrics(
      photos: DashboardMetric(
        count: imageAssets.length,
        bytes: imageSizes.values.fold(0, (total, size) => total + size),
      ),
      videos: DashboardMetric(
        count: videoAssets.length,
        bytes: videoSizes.values.fold(0, (total, size) => total + size),
      ),
      screenshots: DashboardMetric(
        count: screenshots.length,
        bytes: screenshotBytes,
      ),
      invisiblePhotos: DashboardMetric(
        count: invisiblePhotos.length,
        bytes: invisibleBytes,
      ),
      livePhotos: const DashboardMetric(
        count: 0,
        bytes: 0,
        labelOverride: 'not_available',
      ),
      duplicates: DashboardMetric(
        count: duplicateStats.count,
        bytes: duplicateStats.bytes,
      ),
      blurredPhotos: DashboardMetric(
        count: blurredCount,
        bytes: 0,
        labelOverride: blurredCount == 0
            ? 'scan_blur'
            : '$blurredCount ${(blurredCount == 1 ? 'photo' : 'photos').tr}',
      ),
      duplicateReclaimableBytes: duplicateStats.reclaimableBytes,
    );
  }

  Future<List<AssetEntity>> _loadAssets(RequestType type) async {
    final paths = await PhotoManager.getAssetPathList(
      type: type,
      onlyAll: true,
      filterOption: FilterOptionGroup(
        imageOption: const FilterOption(needTitle: true),
        videoOption: const FilterOption(needTitle: true),
        orders: const [OrderOption(type: OrderOptionType.createDate)],
      ),
    );
    if (paths.isEmpty) {
      return <AssetEntity>[];
    }
    final count = await paths.first.assetCountAsync;
    return paths.first.getAssetListRange(start: 0, end: count);
  }

  Future<List<AssetEntity>> _loadInvisiblePhotoAssets() async {
    final paths = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: false,
      filterOption: FilterOptionGroup(
        imageOption: const FilterOption(needTitle: true),
        orders: const [OrderOption(type: OrderOptionType.createDate)],
      ),
    );
    if (paths.isEmpty) {
      return <AssetEntity>[];
    }

    final byId = <String, AssetEntity>{};
    for (final path in paths.where(
      (path) => _looksLikeInvisibleText(path.name),
    )) {
      final count = await path.assetCountAsync;
      final assets = await path.getAssetListRange(start: 0, end: count);
      for (final asset in assets) {
        byId[asset.id] = asset;
      }
    }

    if (byId.isNotEmpty) {
      return byId.values.toList(growable: false);
    }

    final allPath = paths.firstWhereOrNull((path) => path.isAll) ?? paths.first;
    final count = await allPath.assetCountAsync;
    final candidates = await allPath.getAssetListRange(start: 0, end: count);
    return candidates.where(_looksLikeInvisibleAsset).toList(growable: false);
  }

  Future<List<AssetEntity>> _loadScreenshotAssets() async {
    final paths = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: false,
      filterOption: FilterOptionGroup(
        imageOption: const FilterOption(needTitle: true),
        orders: const [OrderOption(type: OrderOptionType.createDate)],
      ),
    );
    if (paths.isEmpty) {
      return <AssetEntity>[];
    }

    final byId = <String, AssetEntity>{};
    for (final path in paths.where(
      (path) => _looksLikeScreenshotText(path.name),
    )) {
      final count = await path.assetCountAsync;
      final assets = await path.getAssetListRange(start: 0, end: count);
      for (final asset in assets) {
        byId[asset.id] = asset;
      }
    }
    if (byId.isNotEmpty) {
      return byId.values.toList(growable: false);
    }

    final allPath = paths.firstWhereOrNull((path) => path.isAll) ?? paths.first;
    final count = await allPath.assetCountAsync;
    final candidates = await allPath.getAssetListRange(start: 0, end: count);
    return candidates.where(_looksLikeScreenshotAsset).toList(growable: false);
  }

  Future<Map<String, int>> _measureAssets(List<AssetEntity> assets) async {
    final sizes = <String, int>{};
    const batchSize = 64;
    for (var start = 0; start < assets.length; start += batchSize) {
      final batch = assets.skip(start).take(batchSize);
      final entries = await Future.wait(
        batch.map((asset) async {
          try {
            final file = await asset.file;
            return MapEntry(asset.id, file == null ? 0 : await file.length());
          } catch (_) {
            return MapEntry(asset.id, 0);
          }
        }),
      );
      sizes.addEntries(entries);
    }
    return sizes;
  }

  bool _looksLikeScreenshotAsset(AssetEntity asset) {
    return _looksLikeScreenshotText(asset.title) ||
        _looksLikeScreenshotText(asset.relativePath);
  }

  bool _looksLikeInvisibleAsset(AssetEntity asset) {
    return _looksLikeInvisibleText(asset.title) ||
        _looksLikeInvisibleText(asset.relativePath);
  }

  bool _looksLikeInvisibleText(String? text) {
    final value = text?.toLowerCase();
    if (value == null || value.isEmpty) {
      return false;
    }
    return value.contains('hidden') ||
        value.contains('invisible') ||
        value.contains('private') ||
        value.contains('locked') ||
        value.contains('secure folder') ||
        value.contains('/.');
  }

  bool _looksLikeScreenshotText(String? text) {
    final value = text?.toLowerCase();
    if (value == null || value.isEmpty) {
      return false;
    }
    return value.contains('screenshot') ||
        value.contains('screen shot') ||
        value.contains('screen_shot') ||
        value.contains('screen-shot') ||
        value.contains('screen capture') ||
        value.contains('screencapture');
  }

  _DuplicateStats _duplicateStats(
    List<AssetEntity> assets,
    Map<String, int> sizes,
  ) {
    final groups = <String, List<int>>{};
    for (final asset in assets) {
      final size = sizes[asset.id] ?? 0;
      if (size <= 0) {
        continue;
      }
      final key = '${asset.width}x${asset.height}:$size';
      groups.putIfAbsent(key, () => <int>[]).add(size);
    }

    var count = 0;
    var bytes = 0;
    var reclaimableBytes = 0;
    for (final group in groups.values.where((group) => group.length > 1)) {
      count += group.length;
      bytes += group.fold(0, (total, size) => total + size);
      reclaimableBytes += group.skip(1).fold(0, (total, size) => total + size);
    }
    return _DuplicateStats(
      count: count,
      bytes: bytes,
      reclaimableBytes: reclaimableBytes,
    );
  }

  Future<DashboardMetric> _loadLargeFileMetric() async {
    try {
      if (!await _requestStorageAccess()) {
        return const DashboardMetric.empty();
      }
      final files = await _scanLargeFiles();
      return DashboardMetric(
        count: files.length,
        bytes: files.fold(0, (total, file) => total + file.size),
      );
    } catch (_) {
      return const DashboardMetric.empty();
    }
  }

  Future<List<LargeFileItem>> _scanLargeFiles() async {
    final roots = await _documentRoots();
    final byPath = <String, LargeFileItem>{};
    for (final root in roots) {
      if (!await root.exists()) {
        continue;
      }
      await for (final entity in root.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is! File || !_looksLikeDocument(entity.path)) {
          continue;
        }
        try {
          final stat = await entity.stat();
          if (stat.size < 256 * 1024) {
            continue;
          }
          byPath[entity.path] = LargeFileItem(
            path: entity.path,
            name: entity.uri.pathSegments.isEmpty
                ? entity.path
                : Uri.decodeComponent(entity.uri.pathSegments.last),
            size: stat.size,
            modified: stat.modified,
          );
        } catch (_) {}
      }
    }
    return byPath.values.toList();
  }

  Future<DashboardMetric> _loadWhatsappMetric() async {
    try {
      if (!await _requestStorageAccess()) {
        return const DashboardMetric.empty();
      }
      final items = <String, int>{};
      for (final type in WhatsappMediaType.values) {
        for (final root in _whatsappRoots(type)) {
          if (!await root.exists()) {
            continue;
          }
          await for (final entity in root.list(
            recursive: true,
            followLinks: false,
          )) {
            if (entity is! File || !_matchesWhatsappType(entity.path, type)) {
              continue;
            }
            try {
              items[entity.path] = (await entity.stat()).size;
            } catch (_) {}
          }
        }
      }
      return DashboardMetric(
        count: items.length,
        bytes: items.values.fold(0, (total, size) => total + size),
      );
    } catch (_) {
      return const DashboardMetric.empty();
    }
  }

  Future<DashboardMetric> _loadAppsMetric() async {
    try {
      final result = await _appsChannel.invokeMethod<List<dynamic>>(
        'getInstalledApps',
      );
      final apps = (result ?? <dynamic>[])
          .whereType<Map<dynamic, dynamic>>()
          .map(ManagedApp.fromMap)
          .where((app) => app.packageName.isNotEmpty)
          .toList();
      return DashboardMetric(
        count: apps.length,
        bytes: apps.fold(0, (total, app) => total + app.sizeBytes),
      );
    } catch (_) {
      return const DashboardMetric.empty();
    }
  }

  Future<DashboardMetric> _loadDuplicateContactMetric() async {
    try {
      final permission = await contacts.FlutterContacts.permissions.request(
        contacts.PermissionType.read,
      );
      final hasAccess =
          permission == contacts.PermissionStatus.granted ||
          permission == contacts.PermissionStatus.limited;
      if (!hasAccess) {
        return const DashboardMetric.empty();
      }
      final loaded = await contacts.FlutterContacts.getAll(
        properties: const {
          contacts.ContactProperty.name,
          contacts.ContactProperty.phone,
          contacts.ContactProperty.email,
        },
      );
      final groups = _findDuplicateContactGroups(loaded);
      final count = groups.fold(
        0,
        (total, group) => total + group.contacts.length,
      );
      return DashboardMetric(
        count: count,
        bytes: 0,
        labelOverride: '$count ${(count == 1 ? 'contact' : 'contacts').tr}',
      );
    } catch (_) {
      return const DashboardMetric.empty();
    }
  }

  List<DuplicateContactGroup> _findDuplicateContactGroups(
    List<contacts.Contact> loaded,
  ) {
    final byKey = <String, List<contacts.Contact>>{};
    final labels = <String, String>{};

    for (final contact in loaded) {
      for (final entry in _duplicateContactKeys(contact).entries) {
        byKey.putIfAbsent(entry.key, () => <contacts.Contact>[]).add(contact);
        labels.putIfAbsent(entry.key, () => entry.value);
      }
    }

    final usedIds = <String>{};
    final result = <DuplicateContactGroup>[];
    for (final entry in byKey.entries) {
      final uniqueContacts = <contacts.Contact>[];
      final localIds = <String>{};
      for (final contact in entry.value) {
        final id = contact.id;
        if (id == null || usedIds.contains(id) || !localIds.add(id)) {
          continue;
        }
        uniqueContacts.add(contact);
      }
      if (uniqueContacts.length < 2) {
        continue;
      }
      usedIds.addAll(
        uniqueContacts.map((contact) => contact.id).whereType<String>(),
      );
      result.add(
        DuplicateContactGroup(
          key: entry.key,
          label: labels[entry.key] ?? 'Matching contact details',
          contacts: uniqueContacts,
        ),
      );
    }
    return result;
  }

  Map<String, String> _duplicateContactKeys(contacts.Contact contact) {
    final keys = <String, String>{};
    for (final phone in contact.phones) {
      final normalized = _normalizePhone(
        phone.normalizedNumber ?? phone.number,
      );
      if (normalized.length >= 7) {
        keys['phone:$normalized'] = phone.number;
      }
    }
    for (final email in contact.emails) {
      final normalized = email.address.trim().toLowerCase();
      if (normalized.isNotEmpty) {
        keys['email:$normalized'] = email.address;
      }
    }
    if (keys.isEmpty) {
      final name = (contact.displayName ?? '').trim().toLowerCase();
      if (name.length >= 3) {
        keys['name:$name'] = contact.displayName ?? name;
      }
    }
    return keys;
  }

  String _normalizePhone(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.startsWith('+')) {
      return '+${digits.substring(1).replaceAll(RegExp(r'[^0-9]'), '')}';
    }
    return digits.replaceAll(RegExp(r'[^0-9]'), '');
  }

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

  Future<List<Directory>> _documentRoots() async {
    if (Platform.isAndroid) {
      return [
        Directory('/storage/emulated/0/Download'),
        Directory('/storage/emulated/0/Documents'),
        Directory('/storage/emulated/0/DCIM'),
        Directory('/storage/emulated/0/WhatsApp/Media/WhatsApp Documents'),
        Directory(
          '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Documents',
        ),
      ];
    }

    final docs = await getApplicationDocumentsDirectory();
    final downloads = await getDownloadsDirectory();
    return [docs, ?downloads];
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

  List<Directory> _whatsappRoots(WhatsappMediaType type) {
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

  bool _matchesWhatsappType(String path, WhatsappMediaType type) {
    final lower = path.toLowerCase();
    if (lower.contains('/.statuses/')) {
      return false;
    }
    return type.extensions.any(lower.endsWith);
  }

  Future<List<Directory>> _quickCleanDirectories() async {
    return [
      await getTemporaryDirectory(),
      if (await getApplicationCacheDirectory().then((dir) => dir.exists()))
        await getApplicationCacheDirectory(),
    ];
  }

  Future<int> _directoryBytes(List<Directory> directories) async {
    var total = 0;
    for (final directory in directories) {
      if (!await directory.exists()) {
        continue;
      }
      await for (final entity in directory.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is! File) {
          continue;
        }
        try {
          total += await entity.length();
        } catch (_) {}
      }
    }
    return total;
  }

  Future<int> _quickCleanBytes() async {
    return _directoryBytes(await _quickCleanDirectories());
  }

  Future<void> _deleteDirectoryContents(Directory directory) async {
    if (!await directory.exists()) {
      return;
    }
    await for (final entity in directory.list(followLinks: false)) {
      try {
        await entity.delete(recursive: true);
      } catch (_) {}
    }
  }
}

class _MediaDashboardMetrics {
  const _MediaDashboardMetrics({
    required this.photos,
    required this.videos,
    required this.screenshots,
    required this.invisiblePhotos,
    required this.livePhotos,
    required this.duplicates,
    required this.blurredPhotos,
    required this.duplicateReclaimableBytes,
  });

  const _MediaDashboardMetrics.empty()
    : this(
        photos: const DashboardMetric.empty(),
        videos: const DashboardMetric.empty(),
        screenshots: const DashboardMetric.empty(),
        invisiblePhotos: const DashboardMetric.empty(),
        livePhotos: const DashboardMetric.empty(),
        duplicates: const DashboardMetric.empty(),
        blurredPhotos: const DashboardMetric.empty(),
        duplicateReclaimableBytes: 0,
      );

  final DashboardMetric photos;
  final DashboardMetric videos;
  final DashboardMetric screenshots;
  final DashboardMetric invisiblePhotos;
  final DashboardMetric livePhotos;
  final DashboardMetric duplicates;
  final DashboardMetric blurredPhotos;
  final int duplicateReclaimableBytes;
}

class _DuplicateStats {
  const _DuplicateStats({
    required this.count,
    required this.bytes,
    required this.reclaimableBytes,
  });

  final int count;
  final int bytes;
  final int reclaimableBytes;
}
