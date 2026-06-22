import 'package:flutter/material.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/photos/photos_controller.dart';
import 'package:sift/app/photos/widgets/media_tile.dart';
import 'package:sift/app/photos/widgets/screenshot_review_banner.dart';
import 'package:sift/app/photos/widgets/screenshot_year_chips.dart';
import 'package:sift/app/photos/widgets/screenshots_header.dart';

/// The Screenshots screen body: storage header, optional "older than a year"
/// review banner, age filters and a selectable grid.
class ScreenshotsBody extends StatelessWidget {
  const ScreenshotsBody({super.key, required this.controller});

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
              child: ScreenshotsHeader(controller: controller),
            ),
          ),
          if (controller.screenshotsOlderThanYear > 0)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              sliver: SliverToBoxAdapter(
                child: ScreenshotReviewBanner(controller: controller),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            sliver: SliverToBoxAdapter(
              child: ScreenshotYearChips(controller: controller),
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
                  child: MediaTile(
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
