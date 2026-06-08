enum TrashedMediaType {
  image,
  video;

  bool get isVideo => this == TrashedMediaType.video;
}

/// A single photo or video that was soft-deleted into the recycle bin.
///
/// The original bytes are copied to [backupPath] (inside the app-private
/// recycle bin folder) at delete time so the media can later be restored back
/// into the gallery or purged permanently after the retention window.
class TrashedItem {
  const TrashedItem({
    required this.id,
    required this.backupPath,
    required this.displayName,
    required this.type,
    required this.sizeBytes,
    required this.deletedAtMillis,
  });

  /// Stable key. For gallery assets this is the `AssetEntity.id`; for
  /// file-based sources (WhatsApp, Large Files) it is derived from the path.
  final String id;

  /// Absolute path of the copied file inside the recycle bin folder.
  final String backupPath;

  /// Original file name, shown in the UI.
  final String displayName;

  final TrashedMediaType type;
  final int sizeBytes;
  final int deletedAtMillis;

  DateTime get deletedAt =>
      DateTime.fromMillisecondsSinceEpoch(deletedAtMillis);

  /// Whole days remaining before auto-deletion, clamped to `[0, retentionDays]`.
  int daysLeft(int retentionDays) {
    final elapsed = DateTime.now().difference(deletedAt).inDays;
    final left = retentionDays - elapsed;
    if (left < 0) {
      return 0;
    }
    if (left > retentionDays) {
      return retentionDays;
    }
    return left;
  }

  bool isExpired(int retentionDays) {
    final age = DateTime.now().difference(deletedAt);
    return age.inDays >= retentionDays;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'backupPath': backupPath,
    'displayName': displayName,
    'type': type.name,
    'sizeBytes': sizeBytes,
    'deletedAtMillis': deletedAtMillis,
  };

  static TrashedItem? fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final backupPath = json['backupPath'];
    final displayName = json['displayName'];
    if (id is! String || backupPath is! String || displayName is! String) {
      return null;
    }
    final type = TrashedMediaType.values.firstWhere(
      (value) => value.name == json['type'],
      orElse: () => TrashedMediaType.image,
    );
    final size = json['sizeBytes'];
    final deletedAt = json['deletedAtMillis'];
    return TrashedItem(
      id: id,
      backupPath: backupPath,
      displayName: displayName,
      type: type,
      sizeBytes: size is int ? size : 0,
      deletedAtMillis: deletedAt is int
          ? deletedAt
          : DateTime.now().millisecondsSinceEpoch,
    );
  }
}
