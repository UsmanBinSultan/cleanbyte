import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sift/services/recycle_bin_service.dart';

/// Drives the Tinder-style "Swipe Cleaner" review.
///
/// Photos are reviewed one card at a time: swipe right to keep, swipe left to
/// mark for deletion. Deletions are *deferred* — marking only records the id,
/// so [undo] is always safe and nothing leaves the gallery until [commit] is
/// called. On commit the marked assets are first backed up to the
/// [RecycleBinService] (30-day soft delete) and then removed via
/// `PhotoManager.editor.deleteWithIds`, exactly like the grid cleaners.
///
/// All decision/loading state lives here so the view stays presentation-only.
class SwipeCleanerController extends GetxController {
  static SwipeCleanerController instance = Get.find();

  static const int _maxPhotos = 200;

  bool isLoading = true;
  bool hasAccess = false;
  bool isCommitting = false;
  bool didCommit = false;

  final List<AssetEntity> _queue = <AssetEntity>[];
  final List<_Decision> _history = <_Decision>[];
  final Set<String> _markedIds = <String>{};
  final Map<String, int> _markedSizes = <String, int>{};

  int index = 0;
  int markedBytes = 0;

  List<AssetEntity> get queue => List.unmodifiable(_queue);
  int get total => _queue.length;
  int get reviewedCount => index.clamp(0, _queue.length);
  int get markedCount => _markedIds.length;
  int get keptCount => _history.where((decision) => !decision.marked).length;
  bool get canUndo => _history.isNotEmpty;
  bool get isComplete =>
      !isLoading && hasAccess && _queue.isNotEmpty && index >= _queue.length;

  AssetEntity? get current =>
      index >= 0 && index < _queue.length ? _queue[index] : null;
  AssetEntity? get upNext =>
      index + 1 < _queue.length ? _queue[index + 1] : null;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading = true;
    didCommit = false;
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

    _queue.clear();
    _history.clear();
    _markedIds.clear();
    _markedSizes.clear();
    index = 0;
    markedBytes = 0;

    if (hasAccess) {
      final paths = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true,
        filterOption: FilterOptionGroup(
          imageOption: const FilterOption(needTitle: true),
          orders: const [OrderOption(type: OrderOptionType.createDate)],
        ),
      );
      if (paths.isNotEmpty) {
        final library = paths.first;
        final count = await library.assetCountAsync;
        final loaded = await library.getAssetListRange(
          start: 0,
          end: count < _maxPhotos ? count : _maxPhotos,
        );
        _queue.addAll(loaded);
      }
    }

    isLoading = false;
    update();
  }

  void keep() {
    final asset = current;
    if (asset == null) {
      return;
    }
    _history.add(_Decision(asset.id, marked: false));
    index++;
    update();
  }

  Future<void> markForDeletion() async {
    final asset = current;
    if (asset == null) {
      return;
    }
    _markedIds.add(asset.id);
    _history.add(_Decision(asset.id, marked: true));
    index++;
    update();

    // Size is only needed for the "you'll free ~X" estimate, so fetch it
    // lazily without blocking the swipe animation.
    final size = await _sizeOf(asset);
    if (_markedIds.contains(asset.id)) {
      _markedSizes[asset.id] = size;
      markedBytes += size;
      update();
    }
  }

  void undo() {
    if (_history.isEmpty) {
      return;
    }
    final last = _history.removeLast();
    index = (index - 1).clamp(0, _queue.length);
    if (last.marked) {
      _markedIds.remove(last.id);
      final size = _markedSizes.remove(last.id) ?? 0;
      markedBytes = (markedBytes - size).clamp(0, 1 << 62);
    }
    update();
  }

  /// Permanently apply the marked deletions (via the recycle bin). Returns the
  /// number of assets actually removed from the gallery.
  Future<int> commit() async {
    if (_markedIds.isEmpty || isCommitting) {
      return 0;
    }
    isCommitting = true;
    update();

    final bin = Get.find<RecycleBinService>();
    final marked = _queue
        .where((asset) => _markedIds.contains(asset.id))
        .toList(growable: false);
    await bin.backupAssets(marked);

    final requestedIds = marked.map((asset) => asset.id).toList(growable: false);
    final deletedIds = await PhotoManager.editor.deleteWithIds(requestedIds);
    final deletedSet = deletedIds.toSet();
    await bin.discardBackups(
      requestedIds.where((id) => !deletedSet.contains(id)),
    );

    _queue.removeWhere((asset) => deletedSet.contains(asset.id));
    _markedIds.clear();
    _markedSizes.clear();
    markedBytes = 0;
    isCommitting = false;
    didCommit = true;
    update();
    return deletedSet.length;
  }

  Future<void> openSettings() => PhotoManager.openSetting();

  Future<int> _sizeOf(AssetEntity asset) async {
    try {
      final file = await asset.file;
      return file == null ? 0 : await file.length();
    } catch (_) {
      return 0;
    }
  }
}

class _Decision {
  const _Decision(this.id, {required this.marked});

  final String id;
  final bool marked;
}
