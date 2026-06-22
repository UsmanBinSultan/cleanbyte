import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/ai_categories/ai_categories_controller.dart';
import 'package:sift/app/ai_categories/widgets/categories_loading_state.dart';
import 'package:sift/app/ai_categories/widgets/category_grid.dart';
import 'package:sift/app/ai_categories/widgets/category_list.dart';
import 'package:sift/app/ai_categories/widgets/featured_card.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/centered_state_view.dart';
import 'package:sift/models/photo_category.dart';

/// Routes to the correct AI-categories body: loading, no-access, empty, or the
/// featured cards + category list/grid.
class CategoriesBody extends StatelessWidget {
  const CategoriesBody({super.key, required this.controller});

  final AiCategoriesController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return CategoriesLoadingState(controller: controller);
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
                    child: FeaturedCard(
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
            CategoryGrid(controller: controller, categories: detected)
          else
            CategoryList(controller: controller, categories: detected),
        ],
      ),
    );
  }
}
