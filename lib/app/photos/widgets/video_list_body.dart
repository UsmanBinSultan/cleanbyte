import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/photos/photos_controller.dart';
import 'package:sift/app/photos/widgets/video_row.dart';
import 'package:sift/app/photos/widgets/video_sort_chips.dart';
import 'package:sift/core/utils/formatters.dart';

/// The large-videos screen body: total/selected stat cards, sort chips and a
/// list of per-video rows with single-video delete.
class VideoListBody extends StatelessWidget {
  const VideoListBody({super.key, required this.controller});

  final SimilarPhotosController controller;

  @override
  Widget build(BuildContext context) {
    final allSelected =
        controller.assets.isNotEmpty &&
        controller.selectedIds.length == controller.assets.length;
    return RefreshIndicator(
      color: AppColors.accent,
      backgroundColor: AppColors.surface(context),
      onRefresh: controller.loadAssets,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        children: [
          Row(
            children: [
              _VideoStat(
                value: '${controller.totalCount}',
                label: 'Videos',
                highlight: false,
              ),
              const SizedBox(width: 10),
              _VideoStat(
                value: formatBytes(controller.totalVideoBytes),
                label: 'Total size',
                highlight: false,
              ),
              const SizedBox(width: 10),
              _VideoStat(
                value: formatBytes(controller.selectedBytes),
                label: 'Selected',
                highlight: true,
              ),
            ],
          ),
          const SizedBox(height: 16),
          VideoSortChips(controller: controller),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: controller.selectedIds.isEmpty
                      ? AppColors.textFaint(context)
                      : AppColors.iconAmber,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${controller.selectedIds.length} videos selected · '
                  '${formatBytes(controller.selectedBytes)}',
                  style: TextStyle(
                    color: AppColors.textMuted(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              InkWell(
                onTap: controller.assets.isEmpty
                    ? null
                    : controller.toggleSelectAll,
                child: Text(
                  allSelected ? 'Clear' : 'Select all',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final asset in controller.assets)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: VideoRow(
                asset: asset,
                size: controller.assetByteSizes[asset.id],
                selected: controller.isSelected(asset),
                onTap: () => controller.toggleAsset(asset),
                onDelete: () => _confirmDeleteVideo(context, controller, asset),
              ),
            ),
        ],
      ),
    );
  }
}

class _VideoStat extends StatelessWidget {
  const _VideoStat({
    required this.value,
    required this.label,
    required this.highlight,
  });

  final String value;
  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final light = AppColors.isLight(context);
    return Expanded(
      child: Container(
        height: 66,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: highlight ? AppColors.accentGradient : null,
          color: highlight
              ? null
              : (light ? const Color(0xFF1E293B) : AppColors.surface(context)),
          borderRadius: BorderRadius.circular(16),
          border: highlight || light
              ? null
              : Border.all(color: AppColors.borderFor(context)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  color: highlight || light
                      ? Colors.white
                      : AppColors.textPrimary(context),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: highlight
                    ? Colors.white70
                    : (light ? Colors.white70 : AppColors.textMuted(context)),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Confirms then deletes a single video (recycle-bin backed).
Future<void> _confirmDeleteVideo(
  BuildContext context,
  SimilarPhotosController controller,
  AssetEntity asset,
) async {
  final confirmed = await Get.dialog<bool>(
    AlertDialog(
      title: const Text(
        'Delete video?',
        style: TextStyle(fontWeight: FontWeight.w900),
      ),
      content: const Text(
        'This video will be moved to the recycle bin and removed from your '
        'gallery.',
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Get.back(result: true),
          style: TextButton.styleFrom(foregroundColor: AppColors.danger),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  if (confirmed != true) {
    return;
  }
  final ok = await controller.deleteAsset(asset);
  Get.snackbar(
    ok ? 'Deleted' : 'Nothing deleted',
    ok
        ? 'The video was moved to the recycle bin.'
        : 'The video could not be removed.',
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: const Color(0xFF111929),
    colorText: Colors.white,
    margin: const EdgeInsets.all(16),
  );
}
