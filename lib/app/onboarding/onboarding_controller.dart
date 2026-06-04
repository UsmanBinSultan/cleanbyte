import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sift/app/routes/app_routes.dart';
import 'package:sift/services/app_flags.dart';

class OnboardingController extends GetxController {
  static OnboardingController instance = Get.find();

  static const int _duplicateScanPageSize = 200;

  final PageController pageController = PageController();
  int currentPage = 0;
  bool hasPhotoAccess = false;
  bool isLoadingLibraryStats = false;
  int? libraryPhotoCount;
  int? identicalPhotoCount;

  void onPageChanged(int index) {
    currentPage = index;
    update();
  }

  Future<void> onPrimaryPressed() async {
    if (currentPage < 2) {
      if (currentPage == 1) {
        if (isLoadingLibraryStats) {
          return;
        }
        await _requestPhotoAccessAndLoadStats();
      }
      pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    await _finishOnboarding();
  }

  Future<void> onSecondaryPressed() async {
    if (currentPage == 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    await _finishOnboarding();
  }

  Future<void> skip() async {
    await _finishOnboarding();
  }

  Future<void> _finishOnboarding() async {
    await AppFlags.markOnboardingSeen();
    Get.offAllNamed(AppRoutes.homeDashboard);
  }

  String get libraryTitle {
    final count = libraryPhotoCount;
    if (!hasPhotoAccess) {
      return 'Your photo library is\nready when you are.';
    }
    if (count == null) {
      return 'Counting your\nphotos.';
    }
    final noun = count == 1 ? 'photo' : 'photos';
    return 'Your phone has ${_formatCount(count)}\n$noun.';
  }

  String? get libraryHighlight {
    if (!hasPhotoAccess) {
      return 'Allow access anytime.';
    }
    final count = identicalPhotoCount;
    if (count == null) {
      return 'Scanning similar photos.';
    }
    if (count == 0) {
      return 'No identical photos found yet.';
    }
    final noun = count == 1 ? 'photo looks' : 'photos look';
    return '${_formatCount(count)} $noun identical.';
  }

  String get libraryArtBadgeLabel {
    final count = identicalPhotoCount;
    if (hasPhotoAccess && count != null) {
      return count > 999 ? '${_formatCount(count)}+' : _formatCount(count);
    }
    return 'Scan';
  }

  Future<void> _requestPhotoAccessAndLoadStats() async {
    isLoadingLibraryStats = true;
    update();

    final permission = await PhotoManager.requestPermissionExtend(
      requestOption: const PermissionRequestOption(
        androidPermission: AndroidPermission(
          type: RequestType.image,
          mediaLocation: false,
        ),
      ),
    );
    hasPhotoAccess = permission.hasAccess;

    if (!hasPhotoAccess) {
      libraryPhotoCount = null;
      identicalPhotoCount = null;
      isLoadingLibraryStats = false;
      update();
      return;
    }

    try {
      final paths = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true,
        filterOption: FilterOptionGroup(
          imageOption: const FilterOption(needTitle: true),
          orders: const [OrderOption(type: OrderOptionType.createDate)],
        ),
      );

      if (paths.isEmpty) {
        libraryPhotoCount = 0;
        identicalPhotoCount = 0;
      } else {
        final library = paths.first;
        final count = await library.assetCountAsync;
        libraryPhotoCount = count;
        isLoadingLibraryStats = false;
        update();
        unawaited(_loadIdenticalPhotoCount(library, count));
        return;
      }
    } catch (_) {
      libraryPhotoCount = null;
      identicalPhotoCount = null;
    }

    isLoadingLibraryStats = false;
    update();
  }

  Future<void> _loadIdenticalPhotoCount(
    AssetPathEntity library,
    int totalCount,
  ) async {
    try {
      identicalPhotoCount = await _countIdenticalPhotos(library, totalCount);
    } catch (_) {
      identicalPhotoCount = 0;
    }
    if (!isClosed) {
      update();
    }
  }

  Future<int> _countIdenticalPhotos(
    AssetPathEntity library,
    int totalCount,
  ) async {
    if (totalCount < 2) {
      return 0;
    }

    final groups = <String, int>{};
    for (var start = 0; start < totalCount; start += _duplicateScanPageSize) {
      final end = (start + _duplicateScanPageSize).clamp(0, totalCount);
      final assets = await library.getAssetListRange(start: start, end: end);
      final signatures = await Future.wait(assets.map(_photoSignature));
      for (final signature in signatures) {
        if (signature == null) {
          continue;
        }
        groups.update(signature, (count) => count + 1, ifAbsent: () => 1);
      }
    }

    return groups.values
        .where((groupCount) => groupCount > 1)
        .fold<int>(0, (total, groupCount) => total + groupCount);
  }

  Future<String?> _photoSignature(AssetEntity photo) async {
    try {
      final file = await photo.file;
      final byteSize = file == null ? 0 : await file.length();
      if (byteSize <= 0) {
        return null;
      }
      return '${photo.width}x${photo.height}:$byteSize';
    } catch (_) {
      return null;
    }
  }

  String _formatCount(int value) {
    final text = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      final remaining = text.length - i;
      buffer.write(text[i]);
      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write(',');
      }
    }
    return buffer.toString();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
