import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sift/app/ai_categories/ai_categories_controller.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/loading_shimmer.dart';
import 'package:sift/app/components/sift_bottom_nav_bar.dart';
import 'package:sift/app/components/sift_top_app_bar.dart';
import 'package:sift/models/photo_category.dart';

class AiCategoriesView extends StatelessWidget {
  const AiCategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final fromNav = args is Map && args['fromNav'] == true;

    return GetBuilder<AiCategoriesController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.pageBackground(context),
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _Header(
                  title: 'ai_categories'.tr,
                  trailing: _ScanAgainAction(controller: controller),
                  showBack: !fromNav,
                ),
                Expanded(child: _CategoriesBody(controller: controller)),
              ],
            ),
          ),
          bottomNavigationBar: const SiftBottomNavBar(activeIndex: 1),
        );
      },
    );
  }
}

class _CategoriesBody extends StatelessWidget {
  const _CategoriesBody({required this.controller});

  final AiCategoriesController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return _LoadingState(controller: controller);
    }

    if (!controller.hasAccess) {
      return _CenteredState(
        icon: LucideIcons.image,
        title: 'Photos access needed',
        body:
            controller.errorMessage ??
            'Allow photo access to detect categories.',
        primaryLabel: 'Open Settings',
        onPrimary: controller.openSettings,
        secondaryLabel: 'Try Again',
        onSecondary: () => controller.scanLibrary(force: true),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF18D0B8),
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : const Color(0xFF111929),
      onRefresh: () => controller.scanLibrary(force: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ScanSummary(controller: controller),
            const SizedBox(height: 20),
            const Text(
              'DETECTED CATEGORIES',
              style: TextStyle(
                color: Color(0xFF697486),
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.2,
              ),
            ),
            const SizedBox(height: 12),
            _CategoryGrid(controller: controller),
            const SizedBox(height: 18),
            _RescanButton(controller: controller),
          ],
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState({required this.controller});

  final AiCategoriesController controller;

  @override
  Widget build(BuildContext context) {
    final percent = controller.progressPercent;

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const LoadingShimmer(
            child: Icon(
              LucideIcons.sparkles,
              color: Color(0xFF18D0B8),
              size: 42,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Detecting photo categories',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.totalToScan == 0
                ? 'Preparing your library...'
                : '${controller.scannedCount} of ${controller.totalToScan} photos scanned',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted(context),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          LoadingShimmer(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: controller.totalToScan == 0 ? null : controller.progress,
                minHeight: 5,
                backgroundColor: const Color(0xFF222B3C),
                valueColor: const AlwaysStoppedAnimation(Color(0xFF18D0B8)),
              ),
            ),
          ),
          if (controller.totalToScan > 0) ...[
            const SizedBox(height: 8),
            Text(
              '$percent%',
              style: const TextStyle(
                color: Color(0xFF18D0B8),
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ScanSummary extends StatelessWidget {
  const _ScanSummary({required this.controller});

  final AiCategoriesController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? AppColors.surface(context)
            : AppColors.surface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF18D0B8).withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              LucideIcons.sparkles,
              color: Color(0xFF18D0B8),
              size: 21,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${controller.totalPhotos} photos categorized',
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  controller.isScanning
                      ? '${controller.scannedCount} of ${controller.totalToScan} scanned'
                      : 'Grouped locally by faces and image labels.',
                  style: TextStyle(
                    color: AppColors.textMuted(context),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
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

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.controller});

  final AiCategoriesController controller;

  @override
  Widget build(BuildContext context) {
    final categories = controller.visibleCategories;

    return GridView.builder(
      itemCount: categories.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 18,
        crossAxisSpacing: 14,
        childAspectRatio: 0.76,
      ),
      itemBuilder: (context, index) {
        final category = categories[index];
        return _CategoryCard(
          category: category,
          count: controller.countFor(category),
          thumbnail: controller.thumbnailFor(category),
          onTap: () {
            controller.openCategory(category);
            Get.to(
              () => AiCategoryPhotosView(category: category),
              transition: Transition.rightToLeft,
            );
          },
        );
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.count,
    required this.onTap,
    this.thumbnail,
  });

  final PhotoCategory category;
  final int count;
  final VoidCallback onTap;
  final AssetEntity? thumbnail;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.light
                    ? AppColors.surface(context)
                    : AppColors.surface(context),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderFor(context)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  thumbnail == null
                      ? ColoredBox(
                          color: category.color.withValues(alpha: 0.18),
                        )
                      : _Thumbnail(asset: thumbnail!),
                  Positioned(
                    right: 7,
                    top: 7,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFF071120).withValues(alpha: 0.82),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(
                        category.icon,
                        color: category.color,
                        size: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category.label,
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '$count',
            textAlign: TextAlign.center,
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

class _RescanButton extends StatelessWidget {
  const _RescanButton({required this.controller});

  final AiCategoriesController controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: controller.isScanning
            ? null
            : () => controller.scanLibrary(force: true),
        icon: controller.isScanning
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF18D0B8),
                ),
              )
            : const Icon(LucideIcons.refreshCw, size: 14),
        label: Text(controller.isScanning ? 'Scanning' : 'Scan Again'),
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF18D0B8),
          textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class AiCategoryPhotosView extends StatelessWidget {
  const AiCategoryPhotosView({super.key, required this.category});

  final PhotoCategory category;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AiCategoriesController>(
      builder: (controller) {
        final photos = controller.photosFor(category);

        return Scaffold(
          backgroundColor: AppColors.pageBackground(context),
          body: SafeArea(
            child: Column(
              children: [
                _Header(title: category.label),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
                  child: _CategoryDetailSummary(
                    category: category,
                    count: photos.length,
                    thumbnail: photos.isEmpty ? null : photos.first.asset,
                  ),
                ),
                Expanded(
                  child: photos.isEmpty
                      ? const _EmptyCategoryState()
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                childAspectRatio: 1,
                              ),
                          itemCount: photos.length,
                          itemBuilder: (context, index) {
                            final photo = photos[index];
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  _Thumbnail(asset: photo.asset),
                                  Positioned(
                                    left: 6,
                                    bottom: 6,
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF071120,
                                        ).withValues(alpha: 0.82),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        photo.primaryCategory.icon,
                                        color: photo.primaryCategory.color,
                                        size: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CategoryDetailSummary extends StatelessWidget {
  const _CategoryDetailSummary({
    required this.category,
    required this.count,
    this.thumbnail,
  });

  final PhotoCategory category;
  final int count;
  final AssetEntity? thumbnail;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? AppColors.surface(context)
            : AppColors.surface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          SizedBox(
            width: 96,
            height: 96,
            child: thumbnail == null
                ? ColoredBox(color: category.color.withValues(alpha: 0.18))
                : _Thumbnail(asset: thumbnail!),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(category.icon, color: category.color, size: 20),
                const SizedBox(height: 8),
                Text(
                  '$count ${(count == 1 ? 'photo' : 'photos').tr}',
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
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

class _EmptyCategoryState extends StatelessWidget {
  const _EmptyCategoryState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No photos in this category.',
        style: TextStyle(
          color: AppColors.textMuted(context),
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.asset});

  final AssetEntity asset;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailDataWithSize(
        const ThumbnailSize(300, 300),
        quality: 80,
      ),
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (bytes == null) {
          return const ColoredBox(
            color: Color(0xFF172237),
            child: Center(
              child: Icon(
                LucideIcons.image,
                color: Color(0xFF687384),
                size: 20,
              ),
            ),
          );
        }

        return Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true);
      },
    );
  }
}

class _CenteredState extends StatelessWidget {
  const _CenteredState({
    required this.icon,
    required this.title,
    required this.body,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  final IconData icon;
  final String title;
  final String body;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF18D0B8), size: 42),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 22),
            TextButton(
              onPressed: onPrimary,
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF18D0B8),
                foregroundColor: const Color(0xFF062322),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.w900),
              ),
              child: Text(primaryLabel),
            ),
            if (secondaryLabel != null && onSecondary != null) ...[
              const SizedBox(height: 10),
              TextButton(
                onPressed: onSecondary,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF18D0B8),
                  textStyle: const TextStyle(fontWeight: FontWeight.w800),
                ),
                child: Text(secondaryLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, this.trailing, this.showBack = true});

  final String title;
  final Widget? trailing;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return SiftTopAppBar(title: title, trailing: trailing, showBack: showBack);
  }
}

class _ScanAgainAction extends StatelessWidget {
  const _ScanAgainAction({required this.controller});

  final AiCategoriesController controller;

  @override
  Widget build(BuildContext context) {
    final light = Theme.of(context).brightness == Brightness.light;
    final accent = light ? const Color(0xFF0E8F80) : const Color(0xFF18D0B8);
    final scanning = controller.isScanning;

    return TextButton.icon(
      onPressed: scanning ? null : () => controller.scanLibrary(force: true),
      icon: scanning
          ? SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: accent),
            )
          : const Icon(LucideIcons.refreshCw, size: 16),
      label: Text(scanning ? 'Scanning' : 'Scan Again'),
      style: TextButton.styleFrom(
        foregroundColor: accent,
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
      ),
    );
  }
}
