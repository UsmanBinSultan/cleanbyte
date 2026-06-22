import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/loading_shimmer.dart';
import 'package:sift/app/photos/photos_controller.dart';
import 'package:sift/app/photos/widgets/blur_scan_state.dart';
import 'package:sift/app/photos/widgets/bottom_action.dart';
import 'package:sift/app/photos/widgets/duplicate_groups_body.dart';
import 'package:sift/app/photos/widgets/media_access_state.dart';
import 'package:sift/app/photos/widgets/media_empty_state.dart';
import 'package:sift/app/photos/widgets/media_summary_card.dart';
import 'package:sift/app/photos/widgets/media_tile.dart';
import 'package:sift/app/photos/widgets/screenshots_body.dart';
import 'package:sift/app/photos/widgets/swipe_review_pane.dart';
import 'package:sift/app/photos/widgets/tool_header.dart';
import 'package:sift/app/photos/widgets/video_list_body.dart';

/// Shared screen for every media-cleanup tool (photos, videos, screenshots,
/// invisible, duplicates, blurred, large files). The mode picks which body and
/// chrome to show; per-mode widgets live under `widgets/`.
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
                          ToolHeader(controller: controller),
                          Expanded(child: _MediaBody(controller: controller)),
                          BottomAction(controller: controller),
                        ],
                      ),
                    ),
                  )
                : SwipeReviewPane(controller: controller),
          ),
        );
      },
    );
  }
}

/// Routes to the correct body for the current mode, or a loading/empty/access
/// state when there is nothing to show yet.
class _MediaBody extends StatelessWidget {
  const _MediaBody({required this.controller});

  final SimilarPhotosController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const MediaGridShimmer();
    }

    if (!controller.hasAccess) {
      return MediaAccessState(controller: controller);
    }

    if (controller.assets.isEmpty) {
      if (controller.mode.isBlurred &&
          controller.blurScanTotal > 0 &&
          controller.blurScanDone < controller.blurScanTotal) {
        return BlurScanState(controller: controller);
      }
      return MediaEmptyState(controller: controller);
    }

    // Large Videos uses a rich list (stat cards + sort + per-video rows).
    if (controller.mode.isVideos) {
      return VideoListBody(controller: controller);
    }

    // Screenshots: storage header + age filters + grid.
    if (controller.mode.isScreenshots) {
      return ScreenshotsBody(controller: controller);
    }

    // Similar Photos (duplicates) uses a grouped layout, not a flat grid.
    if (controller.mode.isDuplicates) {
      return DuplicateGroupsBody(controller: controller);
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
            sliver: SliverToBoxAdapter(
              child: MediaSummaryCard(controller: controller),
            ),
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
                final isPhotos = controller.mode == MediaCleanupMode.photos;
                return RepaintBoundary(
                  child: MediaTile(
                    asset: asset,
                    isVideo: controller.mode.isVideos,
                    byteSize: controller.assetByteSizes[asset.id],
                    detailLabel: controller.assetDetailLabel(asset),
                    selected: controller.isSelected(asset),
                    keep: controller.isDuplicateKeeper(asset),
                    // Photos: tapping the tile opens the swipe-to-keep/delete
                    // deck, while the corner check-mark toggles selection for
                    // multi-delete. Other modes select on a plain tile tap.
                    onTap: isPhotos
                        ? () => controller.openAssetReview(asset)
                        : () => controller.toggleAsset(asset),
                    onToggleSelect: isPhotos
                        ? () => controller.toggleAsset(asset)
                        : null,
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
