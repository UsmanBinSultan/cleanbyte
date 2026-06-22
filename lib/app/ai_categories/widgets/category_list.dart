import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sift/app/ai_categories/ai_categories_controller.dart';
import 'package:sift/app/ai_categories/ai_category_photos_view.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/asset_thumbnail.dart';
import 'package:sift/models/photo_category.dart';

/// Vertical list of detected categories with a usage bar and count per row.
class CategoryList extends StatelessWidget {
  const CategoryList({
    super.key,
    required this.controller,
    required this.categories,
  });

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
      onTap: () => openAiCategory(controller, category),
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
