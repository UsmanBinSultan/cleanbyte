import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sift/app/ai_categories/ai_categories_controller.dart';
import 'package:sift/app/ai_categories/ai_category_photos_view.dart';
import 'package:sift/app/components/asset_thumbnail.dart';
import 'package:sift/models/photo_category.dart';

/// Two-column grid of detected categories, each a thumbnail card with an icon,
/// label and count badge.
class CategoryGrid extends StatelessWidget {
  const CategoryGrid({
    super.key,
    required this.controller,
    required this.categories,
  });

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
      itemBuilder: (context, index) => _CategoryGridCard(
        controller: controller,
        category: categories[index],
      ),
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
      onTap: () => openAiCategory(controller, category),
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
