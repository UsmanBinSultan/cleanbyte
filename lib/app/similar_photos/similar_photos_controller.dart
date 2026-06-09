import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sift/core/utils/formatters.dart';
import 'package:sift/models/blur_result.dart';
import 'package:sift/services/blur_cache.dart';
import 'package:sift/services/blur_detector.dart';
import 'package:sift/services/recycle_bin_service.dart';

enum MediaCleanupMode {
  photos,
  videos,
  screenshots,
  invisible,
  duplicates,
  blurred,
  largeFiles;

  bool get isVideos => this == MediaCleanupMode.videos;
  bool get isScreenshots => this == MediaCleanupMode.screenshots;
  bool get isInvisible => this == MediaCleanupMode.invisible;
  bool get isDuplicates => this == MediaCleanupMode.duplicates;
  bool get isBlurred => this == MediaCleanupMode.blurred;
  bool get isLargeFiles => this == MediaCleanupMode.largeFiles;

  String get title {
    if (isVideos) {
      return 'large videos'.tr;
    }
    if (isScreenshots) {
      return 'screenshots'.tr;
    }
    if (isDuplicates) {
      return 'duplicates'.tr;
    }
    if (isInvisible) {
      return 'invisible photos'.tr;
    }
    if (isBlurred) {
      return 'blurred photos'.tr;
    }
    if (isLargeFiles) {
      return 'Large Files';
    }
    return 'Photos'.tr;
  }

  String get emptyTitle {
    if (isVideos) {
      return 'No videos found';
    }
    if (isScreenshots) {
      return 'No screenshots found';
    }
    if (isDuplicates) {
      return 'No duplicate photos found';
    }
    if (isInvisible) {
      return 'No invisible photos found';
    }
    if (isBlurred) {
      return 'No blurred photos found';
    }
    if (isLargeFiles) {
      return 'No media files found';
    }
    return 'No photos found';
  }

  String get emptyBody {
    if (isVideos) {
      return 'Videos from your library will appear here after permission is granted.';
    }
    if (isScreenshots) {
      return 'Screenshots from your gallery will appear here after permission is granted.';
    }
    if (isDuplicates) {
      return 'Duplicate pictures from your gallery will appear here after scanning.';
    }
    if (isInvisible) {
      return 'Hidden, private, locked, or invisible photo albums will appear here when the device exposes them.';
    }
    if (isBlurred) {
      return 'Blurry pictures will appear here after scanning your gallery.';
    }
    if (isLargeFiles) {
      return 'Large phone media files will appear here after permission is granted.';
    }
    return 'Photos from your library will appear here after permission is granted.';
  }

  RequestType get requestType => isVideos || isLargeFiles
      ? isLargeFiles
            ? RequestType.common
            : RequestType.video
      : RequestType.image;

  /// Plural noun for this mode, used in confirmation copy and empty states.
  String get mediaName {
    if (isVideos) {
      return 'videos';
    }
    if (isScreenshots) {
      return 'screenshots';
    }
    if (isDuplicates) {
      return 'duplicate photos';
    }
    if (isInvisible) {
      return 'invisible photos';
    }
    if (isLargeFiles) {
      return 'files';
    }
    return 'photos';
  }
}

class SimilarPhotosController extends GetxController {
  static SimilarPhotosController instance = Get.find();
  static final _blurredPhotosScan = _BlurredPhotosScanSnapshot();

  SimilarPhotosController({this.mode = MediaCleanupMode.photos});

  final MediaCleanupMode mode;
  final Set<String> selectedIds = <String>{};
  bool _isClosed = false;

  bool isLoading = true;
  bool isDeleting = false;
  bool hasAccess = false;
  int totalCount = 0;
  int swipeDeletedCount = 0;
  int swipeSavedBytes = 0;
  AssetEntity? reviewAsset;
  List<AssetEntity> assets = <AssetEntity>[];
  Map<String, int> assetByteSizes = <String, int>{};
  Map<String, int> duplicateGroupCounts = <String, int>{};
  Map<String, String> _assetGroupKey = <String, String>{};
  Map<String, BlurScanResult> blurResults = <String, BlurScanResult>{};
  int blurScanDone = 0;
  int blurScanTotal = 0;

  static const int _pageSize = 240;
  static const int _blurBatchSize = 6;

  @override
  void onInit() {
    super.onInit();
    loadAssets();
  }

  @override
  void onClose() {
    _isClosed = true;
    super.onClose();
  }

  Future<void> loadAssets() async {
    isLoading = true;
    update();

    final permission = await PhotoManager.requestPermissionExtend(
      requestOption: PermissionRequestOption(
        androidPermission: AndroidPermission(
          type: mode.requestType,
          mediaLocation: false,
        ),
      ),
    );
    hasAccess = permission.hasAccess;

    if (!hasAccess) {
      assets = <AssetEntity>[];
      assetByteSizes = <String, int>{};
      duplicateGroupCounts = <String, int>{};
      _assetGroupKey = <String, String>{};
      blurResults = <String, BlurScanResult>{};
      totalCount = 0;
      selectedIds.clear();
      isLoading = false;
      update();
      return;
    }

    final paths = await PhotoManager.getAssetPathList(
      type: mode.requestType,
      onlyAll: !(mode.isScreenshots || mode.isInvisible),
      filterOption: FilterOptionGroup(
        videoOption: const FilterOption(needTitle: true),
        imageOption: const FilterOption(needTitle: true),
        orders: const [OrderOption(type: OrderOptionType.createDate)],
      ),
    );

    if (paths.isEmpty) {
      assets = <AssetEntity>[];
      assetByteSizes = <String, int>{};
      duplicateGroupCounts = <String, int>{};
      _assetGroupKey = <String, String>{};
      totalCount = 0;
    } else {
      if (mode.isScreenshots) {
        await _loadScreenshots(paths);
      } else if (mode.isInvisible) {
        await _loadInvisiblePhotos(paths);
      } else if (mode.isDuplicates) {
        await _loadDuplicatePhotos(paths.first);
      } else if (mode.isBlurred) {
        await _loadBlurredPhotos(paths.first);
      } else if (mode.isLargeFiles) {
        await _loadLargeFiles(paths.first);
      } else {
        final recent = paths.first;
        totalCount = await recent.assetCountAsync;
        assets = await recent.getAssetListRange(
          start: 0,
          end: totalCount < _pageSize ? totalCount : _pageSize,
        );
      }
      if (mode.isVideos) {
        await _sortVideosBySize();
      } else if (!mode.isLargeFiles && !mode.isDuplicates && !mode.isBlurred) {
        assetByteSizes = <String, int>{};
        duplicateGroupCounts = <String, int>{};
        _assetGroupKey = <String, String>{};
        blurResults = <String, BlurScanResult>{};
      }
    }

    selectedIds.removeWhere((id) => assets.every((asset) => asset.id != id));
    isLoading = false;
    update();
  }

  bool isSelected(AssetEntity asset) => selectedIds.contains(asset.id);

  /// Caption shown under a grid tile: size, duplicate count, blur score, or
  /// capture date depending on the active mode.
  String assetDetailLabel(AssetEntity asset) {
    if (mode.isLargeFiles || mode.isVideos) {
      return formatBytes(assetByteSizes[asset.id], emptyLabel: 'Size unavailable');
    }
    if (mode.isDuplicates) {
      final count = duplicateGroupCounts[asset.id] ?? 2;
      return '$count duplicates - '
          '${formatBytes(assetByteSizes[asset.id], emptyLabel: 'Size unavailable')}';
    }
    if (mode.isBlurred) {
      final variance = blurResults[asset.id]?.variance;
      if (variance == null) {
        return 'Blur detected';
      }
      return 'Blur score ${variance.toStringAsFixed(1)}';
    }
    return formatShortDate(asset.createDateTime, recentBefore2000: true);
  }

  /// Caption shown on the full-screen swipe-review card.
  String reviewDetailLabel(AssetEntity asset) {
    if (mode.isDuplicates) {
      final count = duplicateGroupCounts[asset.id] ?? 2;
      return 'Very similar to ${count - 1} others';
    }
    return 'Very similar to 3 others';
  }

  int reviewAssetIndex(AssetEntity asset) {
    final index = assets.indexWhere((candidate) => candidate.id == asset.id);
    return index < 0 ? 0 : index;
  }

  void openAssetReview(AssetEntity asset) {
    reviewAsset = asset;
    update();
  }

  void closeAssetReview() {
    reviewAsset = null;
    update();
  }

  void toggleAsset(AssetEntity asset) {
    final isDeselecting = selectedIds.contains(asset.id);
    if (!isDeselecting && _wouldEmptyDuplicateGroup(asset)) {
      Get.snackbar(
        'One copy is kept',
        'At least one photo from each duplicate set stays on your device.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF111929),
        colorText: const Color(0xFFFFFFFF),
        margin: const EdgeInsets.all(16),
      );
      return;
    }
    if (!selectedIds.add(asset.id)) {
      selectedIds.remove(asset.id);
    }
    update();
  }

  /// In duplicates mode, returns true when selecting [asset] would mark every
  /// loaded copy of its group for deletion, leaving no survivor.
  bool _wouldEmptyDuplicateGroup(AssetEntity asset) {
    if (!mode.isDuplicates) {
      return false;
    }
    final key = _assetGroupKey[asset.id];
    if (key == null) {
      return false;
    }
    final unselectedInGroup = assets
        .where((candidate) => _assetGroupKey[candidate.id] == key)
        .where((candidate) => !selectedIds.contains(candidate.id))
        .length;
    return unselectedInGroup <= 1;
  }

  /// For duplicates, the survivor of each loaded group is the first copy seen;
  /// the rest are the "extras" that can be auto-selected for cleanup.
  Set<String> _loadedDuplicateExtras() {
    final keeperByGroup = <String, String>{};
    final extras = <String>{};
    for (final asset in assets) {
      final key = _assetGroupKey[asset.id];
      if (key == null) {
        continue;
      }
      if (keeperByGroup.containsKey(key)) {
        extras.add(asset.id);
      } else {
        keeperByGroup[key] = asset.id;
      }
    }
    return extras;
  }

  /// True for the one copy in each duplicate group that is always kept.
  bool isDuplicateKeeper(AssetEntity asset) {
    if (!mode.isDuplicates) {
      return false;
    }
    final key = _assetGroupKey[asset.id];
    if (key == null) {
      return false;
    }
    for (final candidate in assets) {
      if (_assetGroupKey[candidate.id] == key) {
        return candidate.id == asset.id;
      }
    }
    return false;
  }

  Future<bool> deleteReviewAsset() async {
    final asset = reviewAsset;
    if (asset == null || isDeleting) {
      return false;
    }

    isDeleting = true;
    update();

    final byteSize = await _assetSize(asset);
    // Back the asset up first so it can be restored from the recycle bin, then
    // drop the backup if the OS did not actually delete it.
    final bin = Get.find<RecycleBinService>();
    await bin.backupAssets([asset]);
    final deletedIds = await PhotoManager.editor.deleteWithIds([asset.id]);
    final deleted = deletedIds.contains(asset.id);
    if (!deleted) {
      await bin.discardBackups([asset.id]);
    }
    if (deleted) {
      assets = assets
          .where((candidate) => candidate.id != asset.id)
          .toList(growable: false);
      selectedIds.remove(asset.id);
      assetByteSizes.remove(asset.id);
      duplicateGroupCounts.remove(asset.id);
      _assetGroupKey.remove(asset.id);
      blurResults.remove(asset.id);
      if (mode.isBlurred) {
        _blurredPhotosScan.removeAssets({asset.id});
      }
      totalCount = totalCount - 1;
      if (totalCount < 0) {
        totalCount = 0;
      }
      swipeDeletedCount += 1;
      swipeSavedBytes += byteSize;
      reviewAsset = null;
    }

    isDeleting = false;
    update();
    return deleted;
  }

  void toggleSelectAll() {
    if (assets.isEmpty) {
      return;
    }
    // For duplicates, "select all" means every extra copy except one survivor
    // per group, so cleaning never wipes an entire duplicate set.
    if (mode.isDuplicates) {
      final extras = _loadedDuplicateExtras();
      final allExtrasSelected =
          extras.isNotEmpty && extras.every(selectedIds.contains);
      selectedIds.clear();
      if (!allExtrasSelected) {
        selectedIds.addAll(extras);
      }
      update();
      return;
    }
    if (selectedIds.length == assets.length) {
      selectedIds.clear();
    } else {
      selectedIds
        ..clear()
        ..addAll(assets.map((asset) => asset.id));
    }
    update();
  }

  /// Auto-clean: select every duplicate copy except one survivor per group.
  void autoSelectDuplicateExtras() {
    if (!mode.isDuplicates) {
      return;
    }
    final extras = _loadedDuplicateExtras();
    selectedIds
      ..clear()
      ..addAll(extras);
    update();
  }

  Future<int> deleteSelected() async {
    if (selectedIds.isEmpty || isDeleting) {
      return 0;
    }

    isDeleting = true;
    update();

    // Back up the selected assets before deletion so they land in the recycle
    // bin, then discard backups for any the OS did not actually delete.
    final bin = Get.find<RecycleBinService>();
    final selectedAssets = assets
        .where((asset) => selectedIds.contains(asset.id))
        .toList(growable: false);
    await bin.backupAssets(selectedAssets);

    final requestedIds = selectedIds.toList(growable: false);
    final deletedIds = await PhotoManager.editor.deleteWithIds(requestedIds);
    final deletedSet = deletedIds.toSet();
    await bin.discardBackups(
      requestedIds.where((id) => !deletedSet.contains(id)),
    );
    assets = assets.where((asset) => !deletedSet.contains(asset.id)).toList();
    assetByteSizes.removeWhere((id, _) => deletedSet.contains(id));
    duplicateGroupCounts.removeWhere((id, _) => deletedSet.contains(id));
    _assetGroupKey.removeWhere((id, _) => deletedSet.contains(id));
    blurResults.removeWhere((id, _) => deletedSet.contains(id));
    if (mode.isBlurred) {
      _blurredPhotosScan.removeAssets(deletedSet);
    }
    totalCount = totalCount - deletedSet.length;
    if (totalCount < 0) {
      totalCount = 0;
    }
    selectedIds.clear();
    isDeleting = false;
    update();

    // For duplicates we keep the surviving copies on screen (rather than
    // re-scanning, which would hide a now-unique photo and make it look like
    // every copy was deleted). Other modes refresh from the library.
    if (deletedSet.isNotEmpty && !mode.isDuplicates) {
      await loadAssets();
    }

    return deletedSet.length;
  }

  Future<void> openSettings() => PhotoManager.openSetting();

  Future<void> _loadScreenshots(List<AssetPathEntity> paths) async {
    final screenshotPaths = paths
        .where((path) => _looksLikeScreenshotText(path.name))
        .toList(growable: false);

    if (screenshotPaths.isNotEmpty) {
      final byId = <String, AssetEntity>{};
      for (final path in screenshotPaths) {
        final count = await path.assetCountAsync;
        final pathAssets = await path.getAssetListRange(start: 0, end: count);
        for (final asset in pathAssets) {
          byId[asset.id] = asset;
        }
      }
      totalCount = byId.length;
      assets = byId.values.take(_pageSize).toList(growable: false);
      return;
    }

    final allPath =
        _firstMatchingPath(paths, (path) => path.isAll) ?? paths.first;
    final count = await allPath.assetCountAsync;
    final candidates = await allPath.getAssetListRange(
      start: 0,
      end: count < _pageSize * 4 ? count : _pageSize * 4,
    );
    assets = candidates
        .where(_looksLikeScreenshotAsset)
        .take(_pageSize)
        .toList();
    totalCount = assets.length;
  }

  Future<void> _loadInvisiblePhotos(List<AssetPathEntity> paths) async {
    final matches = paths
        .where((path) => _looksLikeInvisibleText(path.name))
        .toList(growable: false);
    final byId = <String, AssetEntity>{};

    for (final path in matches) {
      final count = await path.assetCountAsync;
      final pathAssets = await path.getAssetListRange(start: 0, end: count);
      for (final asset in pathAssets) {
        byId[asset.id] = asset;
      }
    }

    if (byId.isEmpty) {
      final allPath =
          _firstMatchingPath(paths, (path) => path.isAll) ?? paths.first;
      final count = await allPath.assetCountAsync;
      final candidates = await allPath.getAssetListRange(start: 0, end: count);
      for (final asset in candidates.where(_looksLikeInvisibleAsset)) {
        byId[asset.id] = asset;
      }
    }

    totalCount = byId.length;
    assets = byId.values.take(_pageSize).toList(growable: false);
  }

  Future<void> _loadDuplicatePhotos(AssetPathEntity path) async {
    final count = await path.assetCountAsync;
    final candidates = await path.getAssetListRange(
      start: 0,
      end: count < _pageSize * 4 ? count : _pageSize * 4,
    );
    final sizeEntries = await _measureAssets(candidates);
    assetByteSizes = Map<String, int>.fromEntries(sizeEntries);

    final groups = <String, List<AssetEntity>>{};
    for (final asset in candidates) {
      final size = assetByteSizes[asset.id] ?? 0;
      if (size <= 0) {
        continue;
      }
      final key = '${asset.width}x${asset.height}:$size';
      groups.putIfAbsent(key, () => <AssetEntity>[]).add(asset);
    }

    final duplicateGroups = groups.entries
        .where((entry) => entry.value.length > 1)
        .toList(growable: false);
    final duplicates = duplicateGroups
        .expand((entry) => entry.value)
        .take(_pageSize)
        .toList();
    duplicateGroupCounts = {
      for (final entry in duplicateGroups)
        for (final asset in entry.value) asset.id: entry.value.length,
    };
    _assetGroupKey = {
      for (final entry in duplicateGroups)
        for (final asset in entry.value) asset.id: entry.key,
    };
    assets = duplicates;
    totalCount = duplicates.length;
  }

  Future<void> _loadBlurredPhotos(AssetPathEntity path) async {
    final count = await path.assetCountAsync;
    final restored = _restoreBlurredScan(count);
    if (restored && _blurredPhotosScan.isComplete) {
      return;
    }

    blurScanDone = restored ? _blurredPhotosScan.scannedCount : 0;
    blurScanTotal = count;
    blurResults = restored
        ? Map<String, BlurScanResult>.from(_blurredPhotosScan.blurResults)
        : <String, BlurScanResult>{};
    assets = restored
        ? List<AssetEntity>.from(_blurredPhotosScan.blurryAssets)
        : <AssetEntity>[];
    totalCount = assets.length;
    isLoading = false;
    update();

    final blurry = restored
        ? List<AssetEntity>.from(_blurredPhotosScan.blurryAssets)
        : <AssetEntity>[];
    for (
      var start = blurScanDone;
      start < blurScanTotal;
      start += _blurBatchSize
    ) {
      if (_isClosed) {
        return;
      }
      final end = (start + _blurBatchSize).clamp(0, blurScanTotal);
      final batch = await path.getAssetListRange(start: start, end: end);
      final freshResults = <BlurScanResult>[];

      await Future.wait(
        batch.map((asset) async {
          final scan = await _scanBlurCandidate(asset);
          if (scan == null) {
            return;
          }
          final result = scan.result;
          blurResults[asset.id] = result;
          if (result.isBlurry) {
            blurry.add(asset);
          }
          if (!scan.isCached) {
            freshResults.add(result);
          }
        }),
      );

      if (freshResults.isNotEmpty) {
        await BlurCache.instance.putAll(freshResults);
      }
      blurScanDone = end;
      assets = _sortedBlurredAssets(blurry);
      totalCount = assets.length;
      _blurredPhotosScan.save(
        hasAccess: hasAccess,
        scannedCount: blurScanDone,
        totalToScan: blurScanTotal,
        blurryAssets: assets,
        blurResults: blurResults,
        isComplete: false,
      );
      update();
    }

    totalCount = blurry.length;
    assets = _sortedBlurredAssets(blurry);
    _blurredPhotosScan.save(
      hasAccess: hasAccess,
      scannedCount: blurScanDone,
      totalToScan: blurScanTotal,
      blurryAssets: assets,
      blurResults: blurResults,
    );
    assetByteSizes = <String, int>{};
    duplicateGroupCounts = <String, int>{};
  }

  bool _restoreBlurredScan(int totalToScan) {
    if (!_blurredPhotosScan.canRestore(totalToScan)) {
      return false;
    }
    hasAccess = _blurredPhotosScan.hasAccess;
    blurScanDone = _blurredPhotosScan.scannedCount;
    blurScanTotal = _blurredPhotosScan.totalToScan;
    blurResults = Map<String, BlurScanResult>.from(
      _blurredPhotosScan.blurResults,
    );
    assets = List<AssetEntity>.from(_blurredPhotosScan.blurryAssets);
    totalCount = assets.length;
    isLoading = false;
    update();
    return true;
  }

  List<AssetEntity> _sortedBlurredAssets(List<AssetEntity> blurry) {
    return ([...blurry]..sort((a, b) {
          final aVariance = blurResults[a.id]?.variance ?? double.maxFinite;
          final bVariance = blurResults[b.id]?.variance ?? double.maxFinite;
          return aVariance.compareTo(bVariance);
        }))
        .toList(growable: false);
  }

  Future<({BlurScanResult result, bool isCached})?> _scanBlurCandidate(
    AssetEntity asset,
  ) async {
    try {
      final cached = await BlurCache.instance.get(asset.id);
      if (cached != null) {
        return (result: cached, isCached: true);
      }

      final bytes = await asset
          .thumbnailDataWithSize(const ThumbnailSize(180, 180), quality: 76)
          .timeout(const Duration(seconds: 8));
      if (bytes == null) {
        return null;
      }
      final result = await detectBlurInIsolate(
        assetId: asset.id,
        bytes: bytes,
      ).timeout(const Duration(seconds: 8));
      return (result: result, isCached: false);
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadLargeFiles(AssetPathEntity path) async {
    final count = await path.assetCountAsync;
    final candidates = await path.getAssetListRange(
      start: 0,
      end: count < _pageSize ? count : _pageSize,
    );
    final sizeEntries = await _measureAssets(candidates);
    assetByteSizes = Map<String, int>.fromEntries(sizeEntries);
    duplicateGroupCounts = <String, int>{};
    assets = [...candidates]
      ..sort((a, b) {
        final sizeCompare = (assetByteSizes[b.id] ?? 0).compareTo(
          assetByteSizes[a.id] ?? 0,
        );
        if (sizeCompare != 0) {
          return sizeCompare;
        }
        return b.createDateTime.compareTo(a.createDateTime);
      });
    totalCount = count;
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

  AssetPathEntity? _firstMatchingPath(
    List<AssetPathEntity> paths,
    bool Function(AssetPathEntity path) test,
  ) {
    for (final path in paths) {
      if (test(path)) {
        return path;
      }
    }
    return null;
  }

  Future<void> _sortVideosBySize() async {
    final entries = await _measureAssets(assets);
    assetByteSizes = Map<String, int>.fromEntries(entries);
    assets = [...assets]
      ..sort((a, b) {
        final sizeCompare = (assetByteSizes[b.id] ?? 0).compareTo(
          assetByteSizes[a.id] ?? 0,
        );
        if (sizeCompare != 0) {
          return sizeCompare;
        }
        return b.duration.compareTo(a.duration);
      });
  }

  Future<List<MapEntry<String, int>>> _measureAssets(
    List<AssetEntity> assetsToMeasure,
  ) {
    return Future.wait(
      assetsToMeasure.map((asset) async {
        try {
          final file = await asset.file;
          final size = file == null ? 0 : await file.length();
          return MapEntry(asset.id, size);
        } catch (_) {
          return MapEntry(asset.id, 0);
        }
      }),
    );
  }

  Future<int> _assetSize(AssetEntity asset) async {
    final cached = assetByteSizes[asset.id];
    if (cached != null && cached > 0) {
      return cached;
    }
    try {
      final file = await asset.file;
      return file == null ? 0 : file.length();
    } catch (_) {
      return 0;
    }
  }
}

class _BlurredPhotosScanSnapshot {
  bool hasAccess = false;
  bool isComplete = false;
  int scannedCount = 0;
  int totalToScan = 0;
  List<AssetEntity> blurryAssets = <AssetEntity>[];
  Map<String, BlurScanResult> blurResults = <String, BlurScanResult>{};

  bool canRestore(int expectedTotal) {
    return totalToScan == expectedTotal &&
        (isComplete || scannedCount > 0 || blurryAssets.isNotEmpty);
  }

  void save({
    required bool hasAccess,
    required int scannedCount,
    required int totalToScan,
    required List<AssetEntity> blurryAssets,
    required Map<String, BlurScanResult> blurResults,
    bool isComplete = true,
  }) {
    this.hasAccess = hasAccess;
    this.scannedCount = scannedCount;
    this.totalToScan = totalToScan;
    this.blurryAssets = List<AssetEntity>.from(blurryAssets);
    this.blurResults = Map<String, BlurScanResult>.from(blurResults);
    this.isComplete = isComplete;
  }

  void removeAssets(Set<String> deletedIds) {
    blurryAssets = blurryAssets
        .where((asset) => !deletedIds.contains(asset.id))
        .toList(growable: false);
    blurResults.removeWhere((id, _) => deletedIds.contains(id));
  }
}
