import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sift/models/trashed_item.dart';

/// Soft-delete store for photos and videos.
///
/// Before any media is permanently deleted from the gallery or disk, its bytes
/// are copied here and an index entry is recorded. Items survive for
/// [retentionDays] days, after which [purgeExpired] removes them automatically.
/// Until then they can be restored back into the gallery or deleted on demand.
///
/// Extends [GetxController] so widgets can observe it with `GetBuilder`: the
/// bin notifies its listeners (e.g. the Settings count) whenever items change.
class RecycleBinService extends GetxController {
  static const int retentionDays = 30;
  static const _folderName = 'recycle_bin';
  static const _indexFileName = 'recycle_bin_index.json';

  static const _imageExtensions = {
    'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'heic', 'heif', 'tiff', 'tif',
  };
  static const _videoExtensions = {
    'mp4', 'mov', 'm4v', 'avi', 'mkv', '3gp', 'webm', 'flv', 'wmv',
  };

  final List<TrashedItem> _items = <TrashedItem>[];

  /// Items, newest deletion first.
  List<TrashedItem> get items => List.unmodifiable(_items);

  int get count => _items.length;

  int get totalBytes =>
      _items.fold<int>(0, (sum, item) => sum + item.sizeBytes);

  @override
  void onInit() {
    super.onInit();
    _restore();
  }

  Future<void> _restore() async {
    try {
      final file = await _indexFile();
      if (!await file.exists()) {
        return;
      }
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! List) {
        return;
      }
      _items
        ..clear()
        ..addAll(
          decoded
              .whereType<Map<String, dynamic>>()
              .map(TrashedItem.fromJson)
              .whereType<TrashedItem>(),
        );
      _sort();
    } catch (_) {
      // A corrupt index should not crash startup; start with an empty bin.
    }
    await purgeExpired();
  }

  /// Back up gallery [assets] before they are passed to `deleteWithIds`.
  /// Returns the set of asset ids that were successfully copied.
  Future<Set<String>> backupAssets(List<AssetEntity> assets) async {
    final backedUp = <String>{};
    if (assets.isEmpty) {
      return backedUp;
    }
    for (final asset in assets) {
      if (asset.type != AssetType.image && asset.type != AssetType.video) {
        continue;
      }
      try {
        final origin = await asset.originFile ?? await asset.file;
        if (origin == null || !await origin.exists()) {
          continue;
        }
        var name = asset.title ?? '';
        if (name.isEmpty) {
          name = await asset.titleAsync;
        }
        if (name.isEmpty) {
          name = '${asset.id}.${_extensionFor(origin.path)}';
        }
        final item = await _copyIntoBin(
          id: asset.id,
          source: origin,
          displayName: name,
          type: asset.type == AssetType.video
              ? TrashedMediaType.video
              : TrashedMediaType.image,
        );
        if (item != null) {
          backedUp.add(asset.id);
        }
      } catch (_) {
        // Skip this asset; the caller still deletes it as before.
      }
    }
    if (backedUp.isNotEmpty) {
      await _persist();
    }
    return backedUp;
  }

  /// Back up a single file (WhatsApp / Large Files) before it is deleted.
  /// No-op for anything that is not a known image or video. Returns the
  /// created item, or `null` when skipped.
  Future<TrashedItem?> backupFile(String path) async {
    final extension = _extensionFor(path);
    final isImage = _imageExtensions.contains(extension);
    final isVideo = _videoExtensions.contains(extension);
    if (!isImage && !isVideo) {
      return null;
    }
    try {
      final source = File(path);
      if (!await source.exists()) {
        return null;
      }
      final item = await _copyIntoBin(
        id: _idForPath(path),
        source: source,
        displayName: _fileNameOf(path),
        type: isVideo ? TrashedMediaType.video : TrashedMediaType.image,
      );
      if (item != null) {
        await _persist();
      }
      return item;
    } catch (_) {
      return null;
    }
  }

  /// Remove backups for ids whose actual deletion did not happen
  /// (e.g. the user cancelled the system delete dialog).
  Future<void> discardBackups(Iterable<String> ids) async {
    final idSet = ids.toSet();
    if (idSet.isEmpty) {
      return;
    }
    final removed = <TrashedItem>[];
    _items.removeWhere((item) {
      if (idSet.contains(item.id)) {
        removed.add(item);
        return true;
      }
      return false;
    });
    if (removed.isEmpty) {
      return;
    }
    for (final item in removed) {
      await _deleteBackupFile(item);
    }
    await _persist();
  }

  /// Re-insert an item into the device gallery, then drop it from the bin.
  Future<bool> restore(TrashedItem item) async {
    try {
      final file = File(item.backupPath);
      if (!await file.exists()) {
        // Backing file vanished; clean up the dangling entry.
        await _removeEntry(item);
        return false;
      }
      if (item.type.isVideo) {
        await PhotoManager.editor.saveVideo(file, title: item.displayName);
      } else {
        await PhotoManager.editor.saveImageWithPath(
          item.backupPath,
          title: item.displayName,
        );
      }
      await _removeEntry(item);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<int> restoreMany(List<TrashedItem> items) async {
    var restored = 0;
    for (final item in items) {
      if (await restore(item)) {
        restored++;
      }
    }
    return restored;
  }

  Future<void> deletePermanently(TrashedItem item) async {
    await _removeEntry(item);
  }

  Future<void> deleteManyPermanently(List<TrashedItem> items) async {
    for (final item in items) {
      await _deleteBackupFile(item);
    }
    final ids = items.map((item) => item.id).toSet();
    _items.removeWhere((item) => ids.contains(item.id));
    await _persist();
  }

  Future<void> emptyBin() async {
    for (final item in List<TrashedItem>.from(_items)) {
      await _deleteBackupFile(item);
    }
    _items.clear();
    await _persist();
  }

  /// Drop everything older than [retentionDays].
  Future<void> purgeExpired() async {
    final expired =
        _items.where((item) => item.isExpired(retentionDays)).toList();
    if (expired.isEmpty) {
      return;
    }
    for (final item in expired) {
      await _deleteBackupFile(item);
    }
    final ids = expired.map((item) => item.id).toSet();
    _items.removeWhere((item) => ids.contains(item.id));
    await _persist();
  }

  // --- internals -----------------------------------------------------------

  Future<TrashedItem?> _copyIntoBin({
    required String id,
    required File source,
    required String displayName,
    required TrashedMediaType type,
  }) async {
    final directory = await _binDirectory();
    final extension = _extensionFor(
      displayName.isNotEmpty ? displayName : source.path,
    );
    final safeId = id.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    final backupPath =
        '${directory.path}${Platform.pathSeparator}$safeId.$extension';
    final backupFile = await source.copy(backupPath);
    final size = await backupFile.length();

    // Replace any previous entry for the same id so re-deletes stay unique.
    _items.removeWhere((existing) => existing.id == id);
    final item = TrashedItem(
      id: id,
      backupPath: backupFile.path,
      displayName: displayName,
      type: type,
      sizeBytes: size,
      deletedAtMillis: DateTime.now().millisecondsSinceEpoch,
    );
    _items.add(item);
    _sort();
    return item;
  }

  Future<void> _removeEntry(TrashedItem item) async {
    await _deleteBackupFile(item);
    _items.removeWhere((existing) => existing.id == item.id);
    await _persist();
  }

  Future<void> _deleteBackupFile(TrashedItem item) async {
    try {
      final file = File(item.backupPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Index entry is still removed; orphan file is harmless.
    }
  }

  void _sort() {
    _items.sort((a, b) => b.deletedAtMillis.compareTo(a.deletedAtMillis));
  }

  Future<Directory> _binDirectory() async {
    final support = await getApplicationSupportDirectory();
    final directory = Directory(
      '${support.path}${Platform.pathSeparator}$_folderName',
    );
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  Future<File> _indexFile() async {
    final directory = await _binDirectory();
    return File('${directory.path}${Platform.pathSeparator}$_indexFileName');
  }

  Future<void> _persist() async {
    // Notify observers (e.g. the Settings count) regardless of disk outcome:
    // the in-memory list is the source of truth for the UI.
    update();
    try {
      final file = await _indexFile();
      await file.writeAsString(
        jsonEncode(_items.map((item) => item.toJson()).toList()),
        flush: true,
      );
    } catch (_) {
      // In-memory state stays correct; persistence retries on next change.
    }
  }

  String _extensionFor(String path) {
    final name = _fileNameOf(path);
    final dot = name.lastIndexOf('.');
    if (dot <= 0 || dot == name.length - 1) {
      return 'dat';
    }
    return name.substring(dot + 1).toLowerCase();
  }

  String _fileNameOf(String path) {
    final normalized = path.replaceAll('\\', '/');
    final slash = normalized.lastIndexOf('/');
    return slash < 0 ? normalized : normalized.substring(slash + 1);
  }

  String _idForPath(String path) {
    // Stable per-path id; combine a hash with the file name for readability.
    return 'file_${path.hashCode}_${_fileNameOf(path)}';
  }
}
