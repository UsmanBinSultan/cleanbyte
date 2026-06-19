import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sift/app/ai_categories/ai_categories_controller.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/asset_thumbnail.dart';
import 'package:sift/app/components/centered_state_view.dart';
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
                SiftTopAppBar(
                  title: 'ai_categories'.tr,
                  subtitle: controller.isScanning
                      ? '${controller.scannedCount} of ${controller.totalToScan} scanned'
                      : '${controller.totalPhotos} photos · last scanned today',
                  showBack: !fromNav,
                  trailing: controller.hasAccess && controller.totalPhotos > 0
                      ? _ViewToggle(controller: controller)
                      : null,
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

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.controller});

  final AiCategoriesController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surfaceTint(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _ToggleButton(
            icon: LucideIcons.list,
            active: !controller.isGridView,
            onTap: () => controller.setGridView(false),
          ),
          _ToggleButton(
            icon: LucideIcons.layoutGrid,
            active: controller.isGridView,
            onTap: () => controller.setGridView(true),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        width: 30,
        height: 28,
        decoration: BoxDecoration(
          color: active ? AppColors.surface(context) : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: active && AppColors.isLight(context)
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: 15,
          color: active ? AppColors.accent : AppColors.textMuted(context),
        ),
      ),
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
      return CenteredStateView(
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

    final detected = controller.visibleCategories
        .where((c) => c != PhotoCategory.all)
        .toList();

    if (detected.isEmpty) {
      return CenteredStateView(
        icon: LucideIcons.sparkles,
        title: 'No categories yet',
        body: 'Scan your library to sort photos into smart categories.',
        primaryLabel: 'Scan now',
        onPrimary: () => controller.scanLibrary(force: true),
      );
    }

    final featured = [PhotoCategory.all, ...detected.take(2)];

    return RefreshIndicator(
      color: AppColors.accent,
      backgroundColor: AppColors.surface(context),
      onRefresh: () => controller.scanLibrary(force: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          SizedBox(
            height: 96,
            child: Row(
              children: [
                for (var i = 0; i < featured.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(
                    child: _FeaturedCard(
                      controller: controller,
                      category: featured[i],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'ALL CATEGORIES',
            style: TextStyle(
              color: AppColors.textFaint(context),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          if (controller.isGridView)
            _CategoryGrid(controller: controller, categories: detected)
          else
            _CategoryList(controller: controller, categories: detected),
        ],
      ),
    );
  }
}

void _openCategory(AiCategoriesController controller, PhotoCategory category) {
  controller.openCategory(category);
  Get.to(
    () => AiCategoryPhotosView(category: category),
    transition: Transition.rightToLeft,
  );
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.controller, required this.category});

  final AiCategoriesController controller;
  final PhotoCategory category;

  @override
  Widget build(BuildContext context) {
    final thumb = controller.thumbnailFor(category);
    final count = controller.countFor(category);
    final label = category == PhotoCategory.all ? 'All Photos' : category.label;
    return GestureDetector(
      onTap: () => _openCategory(controller, category),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (thumb != null)
              AssetThumbnail(asset: thumb, size: const ThumbnailSize(240, 240))
            else
              ColoredBox(color: category.color.withValues(alpha: 0.25)),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xCC000000)],
                ),
              ),
            ),
            Positioned(
              left: 10,
              right: 8,
              bottom: 9,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
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

class _CategoryList extends StatelessWidget {
  const _CategoryList({required this.controller, required this.categories});

  final AiCategoriesController controller;
  final List<PhotoCategory> categories;

  @override
  Widget build(BuildContext context) {
    final maxCount = controller.maxCategoryCount;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < categories.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                indent: 64,
                color: AppColors.borderFor(context),
              ),
            _CategoryListRow(
              controller: controller,
              category: categories[i],
              maxCount: maxCount,
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryListRow extends StatelessWidget {
  const _CategoryListRow({
    required this.controller,
    required this.category,
    required this.maxCount,
  });

  final AiCategoriesController controller;
  final PhotoCategory category;
  final int maxCount;

  @override
  Widget build(BuildContext context) {
    final count = controller.countFor(category);
    final thumb = controller.thumbnailFor(category);
    final fraction = maxCount == 0 ? 0.0 : (count / maxCount).clamp(0.05, 1.0);
    return InkWell(
      onTap: () => _openCategory(controller, category),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          children: [
            ClipOval(
              child: SizedBox(
                width: 38,
                height: 38,
                child: thumb != null
                    ? AssetThumbnail(
                        asset: thumb,
                        size: const ThumbnailSize(120, 120),
                      )
                    : ColoredBox(color: category.color.withValues(alpha: 0.2)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.label,
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: fraction.toDouble(),
                      minHeight: 4,
                      backgroundColor: AppColors.surfaceTint(context),
                      valueColor: AlwaysStoppedAnimation(category.color),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$count',
              style: TextStyle(
                color: category.color,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              LucideIcons.chevronRight,
              size: 16,
              color: AppColors.textFaint(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.controller, required this.categories});

  final AiCategoriesController controller;
  final List<PhotoCategory> categories;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemBuilder: (context, index) {
        final category = categories[index];
        return _CategoryGridCard(controller: controller, category: category);
      },
    );
  }
}

class _CategoryGridCard extends StatelessWidget {
  const _CategoryGridCard({required this.controller, required this.category});

  final AiCategoriesController controller;
  final PhotoCategory category;

  @override
  Widget build(BuildContext context) {
    final thumb = controller.thumbnailFor(category);
    final count = controller.countFor(category);
    return GestureDetector(
      onTap: () => _openCategory(controller, category),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (thumb != null)
              AssetThumbnail(asset: thumb, size: const ThumbnailSize(300, 300))
            else
              ColoredBox(color: category.color.withValues(alpha: 0.25)),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x33000000), Color(0xCC000000)],
                ),
              ),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 10,
              bottom: 10,
              right: 10,
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: category.color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(category.icon, size: 13, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      category.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
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
              color: AppColors.accent,
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
              fontWeight: FontWeight.w800,
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
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: controller.totalToScan == 0 ? null : controller.progress,
              minHeight: 5,
              backgroundColor: AppColors.surfaceTint(context),
              valueColor: const AlwaysStoppedAnimation(AppColors.accent),
            ),
          ),
          if (controller.totalToScan > 0) ...[
            const SizedBox(height: 8),
            Text(
              '$percent%',
              style: const TextStyle(
                color: AppColors.accent,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Per-category photo grid (unchanged behaviour, tokenised styling).
// ---------------------------------------------------------------------------
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
                SiftTopAppBar(
                  title: category.label,
                  subtitle: '${photos.length} photos',
                ),
                Expanded(
                  child: photos.isEmpty
                      ? const _EmptyCategoryState()
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
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
                                  AssetThumbnail(
                                    asset: photo.asset,
                                    size: const ThumbnailSize(300, 300),
                                    quality: 80,
                                  ),
                                  Positioned(
                                    left: 6,
                                    bottom: 6,
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: photo.primaryCategory.color,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        photo.primaryCategory.icon,
                                        color: Colors.white,
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
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
