import 'dart:async';

import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';

class InitialScanController extends GetxController {
  static InitialScanController instance = Get.find();

  bool isScanning = false;
  bool isComplete = false;
  double progress = 0;
  int photoCount = 0;
  int videoCount = 0;
  int albumCount = 0;
  String status = 'Tap to begin';
  String? errorMessage;

  Timer? _progressTimer;

  /// Rough seconds-remaining estimate derived from current progress, shown on
  /// the live-scan screen. Returns 0 once complete.
  int get estimatedSecondsLeft {
    if (isComplete) return 0;
    return ((1 - progress) * 75).round().clamp(1, 99);
  }

  /// Friendly label for the stage the scan is currently in (drives the stepper
  /// and the headline). 0 = Scan Start … 4 = Complete.
  int get stageIndex {
    if (isComplete) return 4;
    if (progress >= 0.75) return 3;
    if (progress >= 0.5) return 2;
    if (progress >= 0.25) return 1;
    return 0;
  }

  @override
  void onReady() {
    super.onReady();
    // The user arrives here by tapping "Start Smart Scan" / "AI Cleanup", so
    // begin scanning immediately unless a scan already ran.
    if (!isScanning && !isComplete) {
      startScan();
    }
  }

  void stopScan() {
    _progressTimer?.cancel();
    isScanning = false;
    status = 'Scan stopped';
    update();
  }

  @override
  void onClose() {
    _progressTimer?.cancel();
    super.onClose();
  }

  Future<void> startScan() async {
    if (isScanning) {
      return;
    }

    isScanning = true;
    isComplete = false;
    progress = 0.03;
    photoCount = 0;
    videoCount = 0;
    albumCount = 0;
    status = 'Requesting library access...';
    errorMessage = null;
    update();

    _startProgressPulse();

    try {
      final permission = await PhotoManager.requestPermissionExtend();
      if (!permission.hasAccess) {
        throw const InitialScanException('Photo access is needed to scan.');
      }

      status = 'Scanning your library...';
      update();

      final imagePaths = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true,
      );
      final videoPaths = await PhotoManager.getAssetPathList(
        type: RequestType.video,
        onlyAll: true,
      );

      final albumPaths = await PhotoManager.getAssetPathList(
        type: RequestType.common,
        onlyAll: false,
      );

      albumCount = albumPaths.where((path) => !path.isAll).length;
      photoCount = await _countAssets(imagePaths);
      progress = progress < 0.58 ? 0.58 : progress;
      status = 'Checking videos...';
      update();

      videoCount = await _countAssets(videoPaths);
      progress = 1;
      isComplete = true;
      status = 'Scan Complete';
    } on InitialScanException catch (error) {
      errorMessage = error.message;
      status = 'Scan paused';
    } catch (_) {
      errorMessage = 'Could not scan this device. Please try again.';
      status = 'Scan paused';
    } finally {
      _progressTimer?.cancel();
      isScanning = false;
      update();
    }
  }

  void _startProgressPulse() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 260), (_) {
      if (!isScanning || progress >= 0.92) {
        return;
      }
      progress = (progress + 0.025).clamp(0, 0.92);
      update();
    });
  }

  Future<int> _countAssets(List<AssetPathEntity> paths) async {
    var count = 0;
    for (final path in paths) {
      count += await path.assetCountAsync;
    }
    return count;
  }
}

class InitialScanException implements Exception {
  const InitialScanException(this.message);

  final String message;
}
