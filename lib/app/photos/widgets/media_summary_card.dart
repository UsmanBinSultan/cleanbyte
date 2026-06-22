import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/photos/photos_controller.dart';
import 'package:sift/core/utils/formatters.dart';

/// Top-of-grid summary card: a mode icon plus a count/size headline and a
/// short sort note, shared by the photo/invisible/blurred/large-file grids.
class MediaSummaryCard extends StatelessWidget {
  const MediaSummaryCard({super.key, required this.controller});

  final SimilarPhotosController controller;

  @override
  Widget build(BuildContext context) {
    final shown = controller.assets.length;
    final noun = controller.mode.isVideos
        ? 'videos'
        : controller.mode.isScreenshots
        ? 'screenshots'
        : controller.mode.isDuplicates
        ? 'duplicate photos'
        : controller.mode.isInvisible
        ? 'invisible photos'
        : controller.mode.isBlurred
        ? 'blurred photos'
        : controller.mode.isLargeFiles
        ? 'files'
        : 'photos';
    final sortNote = controller.mode.isVideos
        ? 'Largest videos shown first'
        : controller.mode.isScreenshots
        ? 'Gallery screenshots ready to review'
        : controller.mode.isDuplicates
        ? 'Likely duplicate pictures ready to review'
        : controller.mode.isInvisible
        ? 'Hidden and private albums ready to review'
        : controller.mode.isBlurred
        ? controller.blurScanTotal > 0
              ? '${controller.blurScanDone} of ${controller.blurScanTotal} scanned'
              : 'Blurriest pictures shown first'
        : controller.mode.isLargeFiles
        ? 'Sorted from largest to smallest'
        : 'Tap to review · tap the circle to select';

    final totalBytes = controller.assetByteSizes.values.fold<int>(
      0,
      (sum, value) => sum + value,
    );
    final icon = controller.mode.isVideos
        ? LucideIcons.video
        : controller.mode.isScreenshots
        ? LucideIcons.smartphone
        : controller.mode.isDuplicates
        ? LucideIcons.copy
        : controller.mode.isBlurred
        ? LucideIcons.focus
        : controller.mode.isLargeFiles
        ? LucideIcons.file
        : LucideIcons.image;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderFor(context)),
        boxShadow: AppColors.isLight(context)
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.iconChipBg(
                context,
                AppColors.accent,
                AppColors.tintTeal,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.accent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  totalBytes > 0
                      ? formatBytes(totalBytes)
                      : '${controller.totalCount} $noun',
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  totalBytes > 0
                      ? '${controller.totalCount} $noun · $sortNote'
                      : '$shown loaded · $sortNote',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textMuted(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
