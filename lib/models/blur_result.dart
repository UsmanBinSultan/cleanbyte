enum BlurLevel {
  sharp,
  borderline,
  blurry;

  String get label {
    switch (this) {
      case BlurLevel.sharp:
        return 'Sharp';
      case BlurLevel.borderline:
        return 'Borderline';
      case BlurLevel.blurry:
        return 'Blurry';
    }
  }
}

class BlurScanResult {
  const BlurScanResult({
    required this.assetId,
    required this.variance,
    required this.level,
    required this.cachedAt,
  });

  factory BlurScanResult.fromJson(Map<String, dynamic> json) {
    return BlurScanResult(
      assetId: json['assetId'] as String? ?? '',
      variance: (json['variance'] as num?)?.toDouble() ?? 0,
      level:
          BlurLevel.values[(json['levelIndex'] as int? ?? 0).clamp(
            0,
            BlurLevel.values.length - 1,
          )],
      cachedAt: json['cachedAt'] as int? ?? 0,
    );
  }

  final String assetId;
  final double variance;
  final BlurLevel level;
  final int cachedAt;

  bool get isBlurry => level == BlurLevel.blurry;

  bool get isExpired =>
      DateTime.now().millisecondsSinceEpoch - cachedAt >
      const Duration(days: 7).inMilliseconds;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'assetId': assetId,
      'variance': variance,
      'levelIndex': level.index,
      'cachedAt': cachedAt,
    };
  }
}
