import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:sift/models/blur_result.dart';

const double kSharpThreshold = 100;
const double kBlurryThreshold = 50;

Future<BlurScanResult> detectBlurInIsolate({
  required String assetId,
  required Uint8List bytes,
}) {
  return compute(_detectBlur, <String, Object>{
    'assetId': assetId,
    'bytes': bytes,
  });
}

BlurScanResult _detectBlur(Map<String, Object> payload) {
  final assetId = payload['assetId']! as String;
  final bytes = payload['bytes']! as Uint8List;
  final source = img.decodeImage(bytes);
  if (source == null) {
    return _result(assetId, 0, BlurLevel.blurry);
  }

  final resized = img.copyResize(
    source,
    width: 180,
    height: 180,
    interpolation: img.Interpolation.average,
  );
  final gray = img.grayscale(resized);
  final variance = _laplacianVariance(gray);
  final level = variance >= kSharpThreshold
      ? BlurLevel.sharp
      : variance >= kBlurryThreshold
      ? BlurLevel.borderline
      : BlurLevel.blurry;
  return _result(assetId, variance, level);
}

BlurScanResult _result(String assetId, double variance, BlurLevel level) {
  return BlurScanResult(
    assetId: assetId,
    variance: variance,
    level: level,
    cachedAt: DateTime.now().millisecondsSinceEpoch,
  );
}

double _laplacianVariance(img.Image gray) {
  final width = gray.width;
  final height = gray.height;
  if (width < 3 || height < 3) {
    return 0;
  }

  final values = Float64List((width - 2) * (height - 2));
  var index = 0;
  for (var y = 1; y < height - 1; y++) {
    for (var x = 1; x < width - 1; x++) {
      final center = _luma(gray, x, y);
      final top = _luma(gray, x, y - 1);
      final bottom = _luma(gray, x, y + 1);
      final left = _luma(gray, x - 1, y);
      final right = _luma(gray, x + 1, y);
      values[index++] = ((top + bottom + left + right) - (4 * center))
          .abs()
          .toDouble();
    }
  }
  return _variance(values, index);
}

double _luma(img.Image image, int x, int y) =>
    image.getPixel(x, y).r.toDouble();

double _variance(Float64List values, int count) {
  if (count == 0) {
    return 0;
  }

  var sum = 0.0;
  for (var i = 0; i < count; i++) {
    sum += values[i];
  }
  final mean = sum / count;

  var squareDistance = 0.0;
  for (var i = 0; i < count; i++) {
    final distance = values[i] - mean;
    squareDistance += distance * distance;
  }
  return squareDistance / count;
}
