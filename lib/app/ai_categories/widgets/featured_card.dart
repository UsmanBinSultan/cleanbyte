import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sift/app/ai_categories/ai_categories_controller.dart';
import 'package:sift/app/ai_categories/ai_category_photos_view.dart';
import 'package:sift/app/components/asset_thumbnail.dart';
import 'package:sift/models/photo_category.dart';

/// Large featured category tile (used for "All Photos" and the top categories)
/// with a thumbnail, label and count.
class FeaturedCard extends StatelessWidget {
  const FeaturedCard({
    super.key,
    required this.controller,
    required this.category,
  });

  final AiCategoriesController controller;
  final PhotoCategory category;

  @override
  Widget build(BuildContext context) {
    final thumb = controller.thumbnailFor(category);
    final count = controller.countFor(category);
    final label = category == PhotoCategory.all ? 'All Photos' : category.label;
    return GestureDetector(
      onTap: () => openAiCategory(controller, category),
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
