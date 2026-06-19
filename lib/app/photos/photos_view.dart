import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/asset_thumbnail.dart';
import 'package:sift/app/components/centered_state_view.dart';
import 'package:sift/app/components/loading_shimmer.dart';
import 'package:sift/app/components/selection_check_mark.dart';
import 'package:sift/app/components/sift_top_app_bar.dart';
import 'package:sift/app/photos/photos_controller.dart';
import 'package:sift/core/utils/formatters.dart';

class SimilarPhotosView extends StatelessWidget {
  const SimilarPhotosView({super.key, this.mode = MediaCleanupMode.photos});

  final MediaCleanupMode mode;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SimilarPhotosController>(
      tag: mode.name,
      init: SimilarPhotosController(mode: mode),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.pageBackground(context),
          body: SafeArea(
            child: controller.reviewAsset == null
                ? Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: Column(
                        children: [
                          _ToolHeader(controller: controller),
                          Expanded(child: _MediaBody(controller: controller)),
                          _BottomAction(controller: controller),
                        ],
                      ),
                    ),
                  )
                : _SwipeReviewPane(controller: controller),
          ),
        );
      },
    );
  }
}

class _MediaBody extends StatelessWidget {
  const _MediaBody({required this.controller});

  final SimilarPhotosController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const MediaGridShimmer();
    }

    if (!controller.hasAccess) {
      return _AccessState(controller: controller);
    }

    if (controller.assets.isEmpty) {
      if (controller.mode.isBlurred &&
          controller.blurScanTotal > 0 &&
          controller.blurScanDone < controller.blurScanTotal) {
        return _BlurScanState(controller: controller);
      }
      return _EmptyState(controller: controller);
    }

    // Large Videos uses a rich list (stat cards + sort + per-video rows).
    if (controller.mode.isVideos) {
      return _VideoListBody(controller: controller);
    }

    // Screenshots: storage header + age filters + grid.
    if (controller.mode.isScreenshots) {
      return _ScreenshotsBody(controller: controller);
    }

    // Similar Photos (duplicates) uses a grouped layout, not a flat grid.
    if (controller.mode.isDuplicates) {
      return _DuplicateGroupsBody(controller: controller);
    }

    // Adaptive column count: 3 on phones, more on wider tablets/landscape.
    final width = MediaQuery.sizeOf(context).width.clamp(0, 560);
    final crossAxisCount = (width / 130).floor().clamp(3, 5);

    return RefreshIndicator(
      color: AppColors.accent,
      backgroundColor: AppColors.surface(context),
      onRefresh: controller.loadAssets,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            sliver: SliverToBoxAdapter(child: _Summary(controller: controller)),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: SliverGrid.builder(
              itemCount: controller.assets.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.78,
              ),
              itemBuilder: (context, index) {
                final asset = controller.assets[index];
                return RepaintBoundary(
                  child: _MediaTile(
                    asset: asset,
                    isVideo: controller.mode.isVideos,
                    byteSize: controller.assetByteSizes[asset.id],
                    detailLabel: controller.assetDetailLabel(asset),
                    selected: controller.isSelected(asset),
                    keep: controller.isDuplicateKeeper(asset),
                    onTap: controller.mode == MediaCleanupMode.photos
                        ? () => controller.openAssetReview(asset)
                        : () => controller.toggleAsset(asset),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// Large Videos — rich list layout (stat cards + sort + per-video rows)
// ===========================================================================
class _VideoListBody extends StatelessWidget {
  const _VideoListBody({required this.controller});

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
          _VideoSortChips(controller: controller),
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
              child: _VideoRow(
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

class _VideoSortChips extends StatelessWidget {
  const _VideoSortChips({required this.controller});

  final SimilarPhotosController controller;

  @override
  Widget build(BuildContext context) {
    Widget chip(String label, VideoSort sort) {
      final active = controller.videoSort == sort;
      return InkWell(
        onTap: () => controller.setVideoSort(sort),
        borderRadius: BorderRadius.circular(99),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: active ? AppColors.accent : AppColors.surface(context),
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
              color: active ? AppColors.accent : AppColors.borderFor(context),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : AppColors.textMuted(context),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        chip('Largest', VideoSort.largest),
        const SizedBox(width: 8),
        chip('Oldest', VideoSort.oldest),
        const SizedBox(width: 8),
        chip('Recent', VideoSort.recent),
      ],
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

class _VideoRow extends StatelessWidget {
  const _VideoRow({
    required this.asset,
    required this.size,
    required this.selected,
    required this.onTap,
    required this.onDelete,
  });

  final AssetEntity asset;
  final int? size;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final name = (asset.title?.trim().isNotEmpty ?? false)
        ? asset.title!.trim()
        : 'Video';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected ? AppColors.accent : AppColors.borderFor(context),
          width: selected ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 84,
                    height: 60,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        AssetThumbnail(
                          asset: asset,
                          size: const ThumbnailSize(240, 200),
                        ),
                        const Center(
                          child: Icon(
                            LucideIcons.playCircle,
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                        Positioned(
                          left: 4,
                          bottom: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              formatDuration(asset.videoDuration),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textPrimary(context),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            formatShortDate(
                              asset.createDateTime,
                              recentBefore2000: true,
                            ),
                            style: TextStyle(
                              color: AppColors.textMuted(context),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '  ·  ',
                            style: TextStyle(
                              color: AppColors.textFaint(context),
                            ),
                          ),
                          Text(
                            formatBytes(size),
                            style: const TextStyle(
                              color: AppColors.danger,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SelectionCheckMark(selected: selected),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
            
            
             [
              // Compress isn't implemented yet — per request it triggers the
              // same delete flow as the Delete button for now.
              // Expanded(
              //   child: _VideoActionButton(
              //     label: 'Compress',
              //     icon: LucideIcons.arrowDownToLine,
              //     color: AppColors.accent,
              //     tint: AppColors.tintTeal,
              //     onTap: onDelete,
              //   ),
              // ),
              const SizedBox(width: 10),
              Expanded(
                child: _VideoActionButton(
                  label: 'Delete',
                  icon: LucideIcons.trash2,
                  color: AppColors.danger,
                  tint: AppColors.dangerBg,
                  onTap: onDelete,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VideoActionButton extends StatelessWidget {
  const _VideoActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.tint,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.iconChipBg(context, color, tint),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 42,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// Screenshots — storage header + age filters + grid
// ===========================================================================
class _ScreenshotsBody extends StatelessWidget {
  const _ScreenshotsBody({required this.controller});

  final SimilarPhotosController controller;

  @override
  Widget build(BuildContext context) {
    final shots = controller.filteredScreenshots;
    final width = MediaQuery.sizeOf(context).width.clamp(0, 560);
    final cols = (width / 130).floor().clamp(3, 5);
    final selectedShown = shots.where(controller.isSelected).length;

    return RefreshIndicator(
      color: AppColors.accent,
      backgroundColor: AppColors.surface(context),
      onRefresh: controller.loadAssets,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            sliver: SliverToBoxAdapter(
              child: _ScreenshotsHeader(controller: controller),
            ),
          ),
          if (controller.screenshotsOlderThanYear > 0)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              sliver: SliverToBoxAdapter(
                child: _ScreenshotReviewBanner(controller: controller),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            sliver: SliverToBoxAdapter(
              child: _ScreenshotYearChips(controller: controller),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '$selectedShown of ${shots.length} selected',
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
                      'Select all',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: SliverGrid.builder(
              itemCount: shots.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.78,
              ),
              itemBuilder: (context, index) {
                final asset = shots[index];
                return RepaintBoundary(
                  child: _MediaTile(
                    asset: asset,
                    isVideo: false,
                    byteSize: controller.assetByteSizes[asset.id],
                    detailLabel: controller.assetDetailLabel(asset),
                    selected: controller.isSelected(asset),
                    onTap: () => controller.toggleAsset(asset),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ScreenshotsHeader extends StatelessWidget {
  const _ScreenshotsHeader({required this.controller});

  final SimilarPhotosController controller;

  @override
  Widget build(BuildContext context) {
    final bytes = controller.screenshotsBytes;
    final used = controller.deviceUsedBytes;
    final fraction = controller.screenshotsStorageFraction;
    final percentLabel = used <= 0
        ? null
        : (fraction * 100 < 1 ? '<1%' : '${(fraction * 100).round()}%');

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.accentGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentDeep.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SCREENSHOTS STORAGE',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      bytes > 0 ? formatBytes(bytes) : '—',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        height: 1,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${formatThousands(controller.totalCount)} screenshots',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (percentLabel != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        '$percentLabel of storage',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'of ${formatBytes(used)} total used',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Other vs Screenshots usage bar.
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: Row(
              children: [
                Expanded(
                  flex: ((1 - fraction) * 1000).round().clamp(1, 1000),
                  child: Container(
                    height: 7,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                Expanded(
                  flex: (fraction * 1000).round().clamp(0, 1000) == 0
                      ? 1
                      : (fraction * 1000).round(),
                  child: Container(height: 7, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _ScreenshotLegendDot(
                color: Colors.white.withValues(alpha: 0.45),
                label: 'Other',
              ),
              const SizedBox(width: 16),
              _ScreenshotLegendDot(color: Colors.white, label: 'Screenshots'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScreenshotLegendDot extends StatelessWidget {
  const _ScreenshotLegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ScreenshotReviewBanner extends StatelessWidget {
  const _ScreenshotReviewBanner({required this.controller});

  final SimilarPhotosController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.star, size: 16, color: AppColors.accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${controller.screenshotsOlderThanYear} screenshots older than '
              '1 year — likely safe to delete',
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 12,
                height: 1.3,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: controller.selectOldScreenshots,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accent,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 32),
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            child: const Text('Review'),
          ),
        ],
      ),
    );
  }
}

class _ScreenshotYearChips extends StatelessWidget {
  const _ScreenshotYearChips({required this.controller});

  final SimilarPhotosController controller;

  @override
  Widget build(BuildContext context) {
    final years = controller.screenshotYears;
    Widget chip(String label, int? value) {
      final active = controller.screenshotYear == value;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: InkWell(
          onTap: () => controller.setScreenshotYear(value),
          borderRadius: BorderRadius.circular(99),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: active ? AppColors.accent : AppColors.surface(context),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(
                color: active ? AppColors.accent : AppColors.borderFor(context),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : AppColors.textMuted(context),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          chip('All', null),
          for (final year in years) chip('$year', year),
          chip('Older', 0),
        ],
      ),
    );
  }
}

class _SwipeReviewPane extends StatefulWidget {
  const _SwipeReviewPane({required this.controller});

  final SimilarPhotosController controller;

  @override
  State<_SwipeReviewPane> createState() => _SwipeReviewPaneState();
}

class _SwipeReviewPaneState extends State<_SwipeReviewPane> {
  double _dragDx = 0;

  SimilarPhotosController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    final asset = controller.reviewAsset;
    if (asset == null) {
      return const SizedBox.shrink();
    }

    final index = controller.reviewAssetIndex(asset);
    final total = controller.totalCount == 0
        ? controller.assets.length
        : controller.totalCount;
    final reviewed = total == 0 ? 0 : (index + 1).clamp(1, total).toInt();
    final progress = total == 0 ? 0.0 : reviewed / total;
    final width = MediaQuery.sizeOf(context).width;
    final ratio = (_dragDx / (width * 0.5)).clamp(-1.0, 1.0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
      child: Column(
        children: [
          _SwipeReviewHeader(
            asset: asset,
            reviewed: reviewed,
            total: total,
            progress: progress.clamp(0.0, 1.0),
            savedBytes: controller.swipeSavedBytes,
            onBack: controller.closeAssetReview,
          ),
          const SizedBox(height: 14),
          Expanded(
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() => _dragDx += details.delta.dx);
              },
              onHorizontalDragEnd: (details) {
                final velocity = details.primaryVelocity ?? 0;
                if (_dragDx < -86 || velocity < -420) {
                  _deleteCurrent();
                } else if (_dragDx > 86 || velocity > 420) {
                  controller.keepReviewAsset();
                  setState(() => _dragDx = 0);
                } else {
                  setState(() => _dragDx = 0);
                }
              },
              child: Transform.translate(
                offset: Offset(_dragDx, 0),
                child: Transform.rotate(
                  angle: ratio * 0.12,
                  child: _SwipePhotoCard(
                    asset: asset,
                    subtitle: controller.reviewDetailLabel(asset),
                    keepOpacity: ratio > 0 ? ratio : 0,
                    deleteOpacity: ratio < 0 ? -ratio : 0,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const _SwipeHints(),
          const SizedBox(height: 14),
          _SwipeActions(
            isDeleting: controller.isDeleting,
            onDelete: _deleteCurrent,
            onSkip: () {
              controller.skipReviewAsset();
              setState(() => _dragDx = 0);
            },
            onKeep: () {
              controller.keepReviewAsset();
              setState(() => _dragDx = 0);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCurrent() async {
    if (controller.isDeleting) {
      return;
    }
    final deleted = await controller.deleteReviewAsset();
    if (mounted) {
      setState(() => _dragDx = 0);
    }
    if (!deleted) {
      Get.snackbar(
        'Nothing deleted'.tr,
        'The system did not remove this photo.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

class _SwipeReviewHeader extends StatelessWidget {
  const _SwipeReviewHeader({
    required this.asset,
    required this.reviewed,
    required this.total,
    required this.progress,
    required this.savedBytes,
    required this.onBack,
  });

  final AssetEntity asset;
  final int reviewed;
  final int total;
  final double progress;
  final int savedBytes;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _ReviewCircleButton(icon: LucideIcons.chevronLeft, onTap: onBack),
            Expanded(
              child: Column(
                children: [
                  Text(
                    monthYearLabel(asset.createDateTime),
                    style: TextStyle(
                      color: AppColors.textFaint(context),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Pic $reviewed of $total',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            _ReviewCircleButton(icon: LucideIcons.rotateCcw, onTap: onBack),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            color: AppColors.accent,
            backgroundColor: AppColors.surfaceTint(context),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '$reviewed of $total reviewed',
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '${formatBytes(savedBytes)} saved',
              style: const TextStyle(
                color: AppColors.accent,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ReviewCircleButton extends StatelessWidget {
  const _ReviewCircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderFor(context)),
        ),
        child: Icon(icon, size: 16, color: AppColors.textMuted(context)),
      ),
    );
  }
}

class _SwipeHints extends StatelessWidget {
  const _SwipeHints();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const _SwipeHint(
          label: 'Swipe left',
          sub: 'to delete',
          color: AppColors.danger,
          tint: AppColors.dangerBg,
          icon: LucideIcons.chevronLeft,
          iconLeading: true,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or',
            style: TextStyle(
              color: AppColors.textFaint(context),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const _SwipeHint(
          label: 'Swipe right',
          sub: 'to keep',
          color: AppColors.accentDeep,
          tint: AppColors.tintTeal,
          icon: LucideIcons.chevronRight,
          iconLeading: false,
        ),
      ],
    );
  }
}

class _SwipeHint extends StatelessWidget {
  const _SwipeHint({
    required this.label,
    required this.sub,
    required this.color,
    required this.tint,
    required this.icon,
    required this.iconLeading,
  });

  final String label;
  final String sub;
  final Color color;
  final Color tint;
  final IconData icon;
  final bool iconLeading;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.iconChipBg(context, color, tint),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (iconLeading) ...[
                Icon(icon, size: 13, color: color),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (!iconLeading) ...[
                const SizedBox(width: 4),
                Icon(icon, size: 13, color: color),
              ],
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          sub,
          style: TextStyle(
            color: AppColors.textFaint(context),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _SwipePhotoCard extends StatelessWidget {
  const _SwipePhotoCard({
    required this.asset,
    required this.subtitle,
    this.keepOpacity = 0,
    this.deleteOpacity = 0,
  });

  final AssetEntity asset;
  final String subtitle;
  final double keepOpacity;
  final double deleteOpacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.borderFor(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(27),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _ReviewPhoto(asset: asset),
            // Scrim so the caption stays legible over the photo.
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 130,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0xCC000000), Colors.transparent],
                  ),
                ),
              ),
            ),
            const Positioned(left: 12, top: 12, child: _AiDeleteBadge()),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shortDateTimeLabel(asset.createDateTime),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            _DecisionStamp(
              label: 'DELETE',
              color: AppColors.danger,
              angle: -0.25,
              opacity: deleteOpacity,
            ),
            _DecisionStamp(
              label: 'KEEP',
              color: AppColors.accent,
              angle: 0.25,
              opacity: keepOpacity,
            ),
          ],
        ),
      ),
    );
  }
}

class _DecisionStamp extends StatelessWidget {
  const _DecisionStamp({
    required this.label,
    required this.color,
    required this.angle,
    required this.opacity,
  });

  final String label;
  final Color color;
  final double angle;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Opacity(
        opacity: opacity.clamp(0, 1),
        child: Transform.rotate(
          angle: angle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color, width: 3),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewPhoto extends StatefulWidget {
  const _ReviewPhoto({required this.asset});

  final AssetEntity asset;

  @override
  State<_ReviewPhoto> createState() => _ReviewPhotoState();
}

class _ReviewPhotoState extends State<_ReviewPhoto> {
  late Future<Uint8List?> _photo;

  @override
  void initState() {
    super.initState();
    _photo = _load();
  }

  @override
  void didUpdateWidget(_ReviewPhoto oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The swipe pane rebuilds on every drag delta; only reload when the
    // reviewed asset actually changes so the full-size image isn't decoded
    // again on each frame.
    if (oldWidget.asset.id != widget.asset.id) {
      _photo = _load();
    }
  }

  Future<Uint8List?> _load() => widget.asset.thumbnailDataWithSize(
    const ThumbnailSize(900, 1200),
    quality: 92,
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _photo,
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (bytes == null) {
          return const ColoredBox(
            color: Color(0xFF347E62),
            child: Center(
              child: Icon(
                LucideIcons.image,
                color: Color(0xFF9ED1C2),
                size: 42,
              ),
            ),
          );
        }

        return Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true);
      },
    );
  }
}

class _AiDeleteBadge extends StatelessWidget {
  const _AiDeleteBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(99),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.sparkles, size: 10, color: Colors.white),
          SizedBox(width: 4),
          Text(
            'AI – SUGGESTS DELETE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _KeepBadge extends StatelessWidget {
  const _KeepBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 18,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF18D0B8),
        borderRadius: BorderRadius.circular(9),
      ),
      alignment: Alignment.center,
      child: const Text(
        'KEEP',
        style: TextStyle(
          color: Color(0xFF062322),
          fontSize: 8,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

// ===========================================================================
// Grouped "Similar Photos" layout (duplicates mode)
// ===========================================================================
class _DuplicateGroupsBody extends StatelessWidget {
  const _DuplicateGroupsBody({required this.controller});

  final SimilarPhotosController controller;

  @override
  Widget build(BuildContext context) {
    final groups = controller.duplicateGroups;
    return RefreshIndicator(
      color: AppColors.accent,
      backgroundColor: AppColors.surface(context),
      onRefresh: controller.loadAssets,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          _SimilarSummaryCard(controller: controller, groups: groups),
          const SizedBox(height: 12),
          const _AiPickNote(),
          const SizedBox(height: 14),
          for (var i = 0; i < groups.length; i++) ...[
            _DuplicateGroupCard(
              controller: controller,
              group: groups[i],
              index: i + 1,
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _SimilarSummaryCard extends StatelessWidget {
  const _SimilarSummaryCard({required this.controller, required this.groups});

  final SimilarPhotosController controller;
  final List<DuplicatePhotoGroup> groups;

  @override
  Widget build(BuildContext context) {
    final toDelete = controller.deletableDuplicateCount;
    final savings = groups.fold<int>(
      0,
      (sum, g) => sum + controller.groupExtraBytes(g),
    );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.iconChipBg(
          context,
          AppColors.accent,
          AppColors.tintMint,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.copy,
                  color: AppColors.accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$toDelete photos can be deleted',
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'We kept the best from each group',
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
          const SizedBox(height: 14),
          Row(
            children: [
              _SummaryStat(
                value: '${controller.totalCount}',
                label: 'total',
                color: AppColors.textPrimary(context),
              ),
              _SummaryStat(
                value: '$toDelete',
                label: 'to delete',
                color: AppColors.danger,
              ),
              _SummaryStat(
                value: formatBytes(savings),
                label: 'savings',
                color: AppColors.accentDeep,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textMuted(context),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _AiPickNote extends StatelessWidget {
  const _AiPickNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.iconChipBg(
                context,
                AppColors.iconPurple,
                AppColors.tintPurple,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.sparkles,
              size: 16,
              color: AppColors.iconPurple,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'We picked the sharpest, best-exposed photo from each group. '
              'Review before deleting.',
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DuplicateGroupCard extends StatelessWidget {
  const _DuplicateGroupCard({
    required this.controller,
    required this.group,
    required this.index,
  });

  final SimilarPhotosController controller;
  final DuplicatePhotoGroup group;
  final int index;

  @override
  Widget build(BuildContext context) {
    final selectedInGroup = group.extras
        .where((e) => controller.isSelected(e))
        .length;
    final allSelected =
        group.extras.isNotEmpty && selectedInGroup == group.extras.length;
    final bytes = controller.groupExtraBytes(group);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderFor(context)),
        boxShadow: AppColors.isLight(context)
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                Text(
                  'Group $index',
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  group.label,
                  style: TextStyle(
                    color: AppColors.textMuted(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                _MiniPill(
                  text: '${group.photoCount} photos',
                  color: AppColors.textMuted(context),
                  bg: AppColors.surfaceTint(context),
                ),
                const SizedBox(width: 6),
                _MiniPill(
                  text: '-${formatBytes(bytes)}',
                  color: AppColors.danger,
                  bg: AppColors.iconChipBg(
                    context,
                    AppColors.danger,
                    AppColors.dangerBg,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 68,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: group.all.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final asset = group.all[i];
                final keeper = controller.isKeeper(group, asset);
                return _GroupThumb(
                  asset: asset,
                  keeper: keeper,
                  selected: !keeper && controller.isSelected(asset),
                  onTap: keeper ? null : () => controller.toggleAsset(asset),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: AppColors.borderFor(context)),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Row(
              children: [
                Expanded(
                  child: _GroupActionButton(
                    label: selectedInGroup > 0
                        ? 'Keep best · Delete $selectedInGroup'
                        : 'Keep best',
                    icon: LucideIcons.checkCircle2,
                    filled: true,
                    active: allSelected,
                    onTap: () =>
                        controller.setGroupExtrasSelected(group, true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _GroupActionButton(
                    label: 'Keep all',
                    icon: LucideIcons.layers,
                    filled: false,
                    active: selectedInGroup == 0,
                    onTap: () =>
                        controller.setGroupExtrasSelected(group, false),
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

/// Pill button used in the duplicate-group footer ("Keep best" / "Keep all").
class _GroupActionButton extends StatelessWidget {
  const _GroupActionButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool filled;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.accent;
    final bg = filled
        ? (active ? accent : AppColors.iconChipBg(context, accent, AppColors.tintTeal))
        : AppColors.surface(context);
    final fg = filled
        ? (active ? Colors.white : accent)
        : (active ? accent : AppColors.textMuted(context));

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: filled
                ? null
                : Border.all(
                    color: active ? accent : AppColors.borderFor(context),
                  ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: fg),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: fg,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({required this.text, required this.color, required this.bg});

  final String text;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _GroupThumb extends StatelessWidget {
  const _GroupThumb({
    required this.asset,
    required this.keeper,
    required this.selected,
    required this.onTap,
  });

  final AssetEntity asset;
  final bool keeper;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 58,
        height: 68,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: keeper
                      ? AppColors.accent
                      : selected
                      ? AppColors.danger
                      : AppColors.borderFor(context),
                  width: 2,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: AssetThumbnail(
                asset: asset,
                size: const ThumbnailSize(160, 160),
              ),
            ),
            if (keeper)
              Positioned(
                left: 2,
                top: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: const Text(
                    'Best',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 7,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              )
            else
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.danger
                        : Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.surface(context),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    selected ? LucideIcons.x : LucideIcons.circle,
                    size: 9,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SwipeActions extends StatelessWidget {
  const _SwipeActions({
    required this.isDeleting,
    required this.onDelete,
    required this.onSkip,
    required this.onKeep,
  });

  final bool isDeleting;
  final VoidCallback onDelete;
  final VoidCallback onSkip;
  final VoidCallback onKeep;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SwipeActionButton(
          label: 'Delete',
          icon: LucideIcons.trash2,
          color: AppColors.danger,
          filled: true,
          size: 60,
          busy: isDeleting,
          onTap: isDeleting ? null : onDelete,
        ),
        const SizedBox(width: 28),
        _SwipeActionButton(
          label: 'Skip',
          icon: LucideIcons.chevronsRight,
          color: AppColors.textMuted(context),
          filled: false,
          size: 50,
          onTap: isDeleting ? null : onSkip,
        ),
        const SizedBox(width: 28),
        _SwipeActionButton(
          label: 'Keep',
          icon: LucideIcons.heart,
          color: AppColors.accent,
          filled: true,
          size: 60,
          onTap: isDeleting ? null : onKeep,
        ),
      ],
    );
  }
}

class _SwipeActionButton extends StatelessWidget {
  const _SwipeActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.filled,
    required this.size,
    required this.onTap,
    this.busy = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool filled;
  final double size;
  final VoidCallback? onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkResponse(
            onTap: onTap,
            radius: size * 0.6,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: filled ? color : AppColors.surface(context),
                shape: BoxShape.circle,
                border: filled
                    ? null
                    : Border.all(color: AppColors.borderFor(context)),
                boxShadow: filled
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.32),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: busy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      icon,
                      color: filled ? Colors.white : color,
                      size: size * 0.4,
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textMuted(context),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.controller});

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
        : 'Recent photos ready to review';

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

class _BlurScanState extends StatelessWidget {
  const _BlurScanState({required this.controller});

  final SimilarPhotosController controller;

  @override
  Widget build(BuildContext context) {
    final progress = controller.blurScanTotal == 0
        ? 0.0
        : controller.blurScanDone / controller.blurScanTotal;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.focus, color: Color(0xFF18D0B8), size: 42),
            const SizedBox(height: 18),
            Text(
              'Scanning for blurred photos'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${controller.blurScanDone} of ${controller.blurScanTotal} scanned',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 7,
                color: const Color(0xFF18D0B8),
                backgroundColor: const Color(0xFF172231),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccessState extends StatelessWidget {
  const _AccessState({required this.controller});

  final SimilarPhotosController controller;

  @override
  Widget build(BuildContext context) {
    return CenteredStateView(
      icon: LucideIcons.image,
      title: 'Photo access needed'.tr,
      body: 'Allow access to show your ${controller.mode.mediaName} here.'.tr,
      primaryLabel: 'Open Settings',
      onPrimary: controller.openSettings,
      secondaryLabel: 'Try Again',
      onSecondary: controller.loadAssets,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.controller});

  final SimilarPhotosController controller;

  @override
  Widget build(BuildContext context) {
    return CenteredStateView(
      icon: controller.mode.isVideos
          ? LucideIcons.video
          : controller.mode.isScreenshots
          ? LucideIcons.camera
          : controller.mode.isDuplicates
          ? LucideIcons.copy
          : controller.mode.isInvisible
          ? LucideIcons.eyeOff
          : controller.mode.isBlurred
          ? LucideIcons.focus
          : controller.mode.isLargeFiles
          ? LucideIcons.file
          : LucideIcons.image,
      title: controller.mode.emptyTitle,
      body: controller.mode.emptyBody,
      primaryLabel: 'Refresh',
      onPrimary: controller.loadAssets,
    );
  }
}

class _MediaTile extends StatelessWidget {
  const _MediaTile({
    required this.asset,
    required this.isVideo,
    required this.byteSize,
    required this.detailLabel,
    required this.selected,
    required this.onTap,
    this.keep = false,
  });

  final AssetEntity asset;
  final bool isVideo;
  final int? byteSize;
  final String detailLabel;
  final bool selected;
  final VoidCallback onTap;
  final bool keep;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.borderFor(context),
            width: selected ? 2 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AssetThumbnail(asset: asset),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.05),
                        Colors.black.withValues(alpha: 0.62),
                      ],
                    ),
                  ),
                ),
              ),
              if (isVideo)
                Positioned(
                  left: 7,
                  bottom: 7,
                  child: _Pill(
                    icon: LucideIcons.play,
                    label: formatDuration(asset.videoDuration),
                  ),
                ),
              if (keep && !selected)
                const Positioned(left: 7, top: 7, child: _KeepBadge()),
              Positioned(
                right: 7,
                top: 7,
                child: SelectionCheckMark(selected: selected),
              ),
              Positioned(
                left: 7,
                right: 7,
                bottom: isVideo ? 32 : 8,
                child: Text(
                  detailLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolHeader extends StatelessWidget {
  const _ToolHeader({required this.controller});

  final SimilarPhotosController controller;

  @override
  Widget build(BuildContext context) {
    final isDup = controller.mode.isDuplicates;
    final groups = isDup
        ? controller.duplicateGroups
        : const <DuplicatePhotoGroup>[];
    final savings = groups.fold<int>(
      0,
      (sum, g) => sum + controller.groupExtraBytes(g),
    );
    final allSelected = isDup
        ? controller.selectedIds.length == controller.deletableDuplicateCount &&
              controller.deletableDuplicateCount > 0
        : controller.assets.isNotEmpty &&
              controller.selectedIds.length == controller.assets.length;

    return SiftTopAppBar(
      title: controller.mode.title,
      subtitle: isDup
          ? '${groups.length} groups · ${formatBytes(savings)}'
          : null,
      trailing: TextButton(
        onPressed: controller.assets.isEmpty
            ? null
            : controller.toggleSelectAll,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent,
          disabledForegroundColor: AppColors.textFaint(context),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
        child: Text(allSelected ? 'clear'.tr : 'select_all'.tr),
      ),
    );
  }
}

class _BottomAction extends StatelessWidget {
  const _BottomAction({required this.controller});

  final SimilarPhotosController controller;

  @override
  Widget build(BuildContext context) {
    final isDup = controller.mode.isDuplicates;
    final selectedCount = controller.selectedIds.length;
    final enabled = selectedCount > 0 && !controller.isDeleting;
    final label = controller.isDeleting
        ? 'Deleting...'
        : isDup
        ? 'Delete $selectedCount photos · Free ${formatBytes(controller.selectedBytes)}'
        : 'Delete selected ($selectedCount)';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
      decoration: BoxDecoration(
        color: AppColors.bottomBar(context),
        border: Border(top: BorderSide(color: AppColors.borderFor(context))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isDup) ...[
            _SelectAllGroupsRow(controller: controller),
            const SizedBox(height: 10),
          ],
          SizedBox(
            width: double.infinity,
            height: 52,
            child: TextButton.icon(
              onPressed: enabled
                  ? () => confirmAndDeleteSelected(controller)
                  : null,
              icon: controller.isDeleting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(LucideIcons.trash, size: 18),
              label: Text(label),
              style: TextButton.styleFrom(
                disabledBackgroundColor: AppColors.surfaceTint(context),
                disabledForegroundColor: AppColors.textFaint(context),
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          if (isDup)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Review in the Recycle Bin if needed',
                style: TextStyle(
                  color: AppColors.textFaint(context),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SelectAllGroupsRow extends StatelessWidget {
  const _SelectAllGroupsRow({required this.controller});

  final SimilarPhotosController controller;

  @override
  Widget build(BuildContext context) {
    final total = controller.deletableDuplicateCount;
    final selected = controller.selectedIds.length;
    final allSelected = total > 0 && selected == total;
    return Row(
      children: [
        GestureDetector(
          onTap: controller.toggleSelectAll,
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              Icon(
                allSelected
                    ? LucideIcons.checkCircle2
                    : LucideIcons.circle,
                size: 18,
                color: allSelected
                    ? AppColors.accent
                    : AppColors.textFaint(context),
              ),
              const SizedBox(width: 8),
              Text(
                'Select all groups',
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Text(
          '$selected/$total selected',
          style: TextStyle(
            color: AppColors.textMuted(context),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

Future<void> confirmAndDeleteSelected(
  SimilarPhotosController controller,
) async {
  final mediaName = controller.mode.mediaName;
  final confirmed = await Get.dialog<bool>(
    AlertDialog(
      backgroundColor: const Color(0xFF111929),
      title: const Text(
        'Delete selected?',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
      ),
      content: Text(
        'This will ask the device photo library to delete ${controller.selectedIds.length} $mediaName.',
        style: const TextStyle(color: Color(0xFFC2CAD6)),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Get.back(result: true),
          style: TextButton.styleFrom(foregroundColor: const Color(0xFFFF7A5F)),
          child: const Text('Delete'),
        ),
      ],
    ),
  );

  if (confirmed != true) {
    return;
  }

  final deleted = await controller.deleteSelected();
  Get.snackbar(
    deleted == 0 ? 'Nothing deleted' : 'Deleted $deleted',
    deleted == 0
        ? 'The system did not remove any items.'
        : controller.mode.isDuplicates
        ? 'Extra copies removed. One copy of each set was kept.'
        : 'Your library has been updated.',
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: const Color(0xFF111929),
    colorText: Colors.white,
    margin: const EdgeInsets.all(16),
  );
}
