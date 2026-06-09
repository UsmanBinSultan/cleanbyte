import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/asset_thumbnail.dart';
import 'package:sift/app/components/centered_state_view.dart';
import 'package:sift/app/components/loading_shimmer.dart';
import 'package:sift/app/components/sift_top_app_bar.dart';
import 'package:sift/app/photo_compressor/photo_compressor_controller.dart';
import 'package:sift/core/utils/formatters.dart';

class PhotoCompressorView extends StatelessWidget {
  const PhotoCompressorView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PhotoCompressorController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.pageBackground(context),
          body: SafeArea(
            child: Column(
              children: [
                SiftTopAppBar(title: 'photo_compressor'.tr),
                Expanded(child: _CompressorBody(controller: controller)),
                _CompressButton(controller: controller),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CompressorBody extends StatelessWidget {
  const _CompressorBody({required this.controller});

  final PhotoCompressorController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const MediaGridShimmer();
    }

    if (!controller.hasAccess) {
      return CenteredStateView(
        icon: LucideIcons.image,
        title: 'Photos access needed',
        body: 'Allow photo access to pick images and compress them.',
        primaryLabel: 'Open Settings',
        onPrimary: controller.openSettings,
        secondaryLabel: 'Try Again',
        onSecondary: controller.loadPhotos,
      );
    }

    if (controller.errorMessage != null && controller.photos.isEmpty) {
      return CenteredStateView(
        icon: LucideIcons.imageOff,
        title: 'Photos unavailable',
        body: controller.errorMessage!,
        primaryLabel: 'Try Again',
        onPrimary: controller.loadPhotos,
      );
    }

    if (controller.photos.isEmpty) {
      return CenteredStateView(
        icon: LucideIcons.image,
        title: 'No photos found',
        body: 'Photos from your library will appear here after they are found.',
        primaryLabel: 'Refresh',
        onPrimary: controller.loadPhotos,
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF18D0B8),
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : const Color(0xFF111929),
      onRefresh: controller.loadPhotos,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PreviewCard(controller: controller),
            const SizedBox(height: 22),
            const Text(
              'QUALITY',
              style: TextStyle(
                color: Color(0xFF697486),
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.2,
              ),
            ),
            const SizedBox(height: 12),
            _QualityRow(controller: controller),
            const SizedBox(height: 16),
            _SavingsPanel(controller: controller),
            if (controller.errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                controller.errorMessage!,
                style: const TextStyle(
                  color: Color(0xFFFF9A87),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
            const SizedBox(height: 22),
            Row(
              children: [
                const Text(
                  'PHOTOS',
                  style: TextStyle(
                    color: Color(0xFF697486),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.2,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: controller.loadPhotos,
                  icon: const Icon(LucideIcons.imagePlus, size: 14),
                  label: const Text('Pick photos'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF18D0B8),
                    textStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: controller.toggleSelectAll,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF18D0B8),
                    textStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  child: Text(
                    controller.selectedCount == controller.photos.length
                        ? 'Deselect'
                        : 'Select all',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.light
                    ? AppColors.surface(context)
                    : AppColors.surface(context),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  for (final photo in controller.photos)
                    _PhotoRow(
                      photo: photo,
                      selected: controller.isSelected(photo),
                      originalSize: controller.originalSizes[photo.id] ?? 0,
                      compressed: controller.compressedBySource[photo.id],
                      onTap: () => controller.togglePhoto(photo),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.controller});

  final PhotoCompressorController controller;

  @override
  Widget build(BuildContext context) {
    final photo = controller.previewPhoto;
    final previewCompressed = controller.previewCompressed;
    final percent = controller.estimatedSavingsPercent;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? AppColors.surface(context)
            : AppColors.surface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ImagePreview(asset: photo, big: true),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Icon(
                  LucideIcons.arrowRight,
                  color: Color(0xFF18D0B8),
                  size: 32,
                ),
              ),
              Column(
                children: [
                  _ImagePreview(
                    asset: photo,
                    compressed: previewCompressed,
                    big: false,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '-$percent%',
                    style: const TextStyle(
                      color: Color(0xFF18D0B8),
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Compress selected photos',
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            controller.showsLastCompressedHint
                ? 'Last compressed photo is saved to your gallery.'
                : controller.selectedCount == 0
                ? 'Pick images below to create smaller JPEG copies.'
                : '${controller.selectedCount} selected - originals stay untouched.',
            style: TextStyle(
              color: AppColors.textMuted(context),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.big, this.asset, this.compressed});

  final AssetEntity? asset;
  final CompressedPhoto? compressed;
  final bool big;

  @override
  Widget build(BuildContext context) {
    final width = big ? 94.0 : 64.0;
    final height = big ? 70.0 : 48.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFF172237),
          border: Border.all(color: const Color(0xFF3A4A67), width: 2),
        ),
        child: compressed == null
            ? asset == null
                  ? const Icon(
                      LucideIcons.imageOff,
                      color: Color(0xFF687384),
                      size: 22,
                    )
                  : AssetThumbnail(
                      asset: asset!,
                      size: const ThumbnailSize(360, 360),
                    )
            : Image.file(File(compressed!.outputPath), fit: BoxFit.cover),
      ),
    );
  }
}

class _QualityRow extends StatelessWidget {
  const _QualityRow({required this.controller});

  final PhotoCompressorController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final quality in CompressionQuality.values) ...[
          Expanded(
            child: _QualityChip(
              quality: quality,
              selected: controller.quality == quality,
              onTap: () => controller.setQuality(quality),
            ),
          ),
          if (quality != CompressionQuality.values.last)
            const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class _QualityChip extends StatelessWidget {
  const _QualityChip({
    required this.quality,
    required this.selected,
    required this.onTap,
  });

  final CompressionQuality quality;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          color: selected
              ? (AppColors.isLight(context)
                    ? const Color(0xFFE6F5F2)
                    : const Color(0xFF092A31))
              : AppColors.surface(context),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected
                ? const Color(0xFF18D0B8)
                : AppColors.borderFor(context),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  quality.title,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              quality.label,
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 9,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavingsPanel extends StatelessWidget {
  const _SavingsPanel({required this.controller});

  final PhotoCompressorController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Row(
        children: [
          Text(
            'Estimated savings',
            style: TextStyle(
              color: AppColors.textMuted(context),
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          Text(
            formatBytes(controller.estimatedSavings),
            style: const TextStyle(
              color: Color(0xFF18D0B8),
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            'from ${controller.selectedCount} selected',
            style: TextStyle(
              color: AppColors.textMuted(context),
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoRow extends StatelessWidget {
  const _PhotoRow({
    required this.photo,
    required this.selected,
    required this.originalSize,
    required this.onTap,
    this.compressed,
  });

  final AssetEntity photo;
  final bool selected;
  final int originalSize;
  final CompressedPhoto? compressed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final subtitle = compressed == null
        ? formatBytes(originalSize)
        : '${formatBytes(compressed!.originalSize)} -> ${formatBytes(compressed!.compressedSize)}';

    return InkWell(
      onTap: onTap,
      child: Container(
        height: 62,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.borderFor(context)),
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 38,
                height: 38,
                child: AssetThumbnail(
                  asset: photo,
                  size: const ThumbnailSize(360, 360),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    photo.title ?? 'Photo',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textMuted(context),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF18D0B8) : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF18D0B8)
                      : const Color(0xFF4E596B),
                ),
              ),
              child: selected
                  ? const Icon(
                      LucideIcons.check,
                      color: Color(0xFF071120),
                      size: 16,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _CompressButton extends StatelessWidget {
  const _CompressButton({required this.controller});

  final PhotoCompressorController controller;

  @override
  Widget build(BuildContext context) {
    final enabled = controller.selectedCount > 0 && !controller.isCompressing;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: BoxDecoration(
        color: AppColors.bottomBar(context),
        border: Border(top: BorderSide(color: AppColors.borderFor(context))),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: TextButton.icon(
          onPressed: enabled ? () => _compress(controller) : null,
          icon: controller.isCompressing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(LucideIcons.minimize2, size: 18),
          label: Text(
            controller.isCompressing
                ? 'Compressing...'
                : 'Compress selected (${controller.selectedCount} photos)',
          ),
          style: TextButton.styleFrom(
            disabledBackgroundColor: const Color(0xFF111929),
            disabledForegroundColor: const Color(0xFF586274),
            backgroundColor: const Color(0xFF18B8A8),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _compress(PhotoCompressorController controller) async {
    final count = await controller.compressSelected();
    Get.snackbar(
      count == 0 ? 'Nothing compressed' : 'Compressed $count photos',
      count == 0
          ? controller.errorMessage ?? 'No photos were processed.'
          : 'Smaller JPEG copies were saved to your gallery.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF111929),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }
}
