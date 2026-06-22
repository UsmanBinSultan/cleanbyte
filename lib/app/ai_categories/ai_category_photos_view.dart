import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sift/app/ai_categories/ai_categories_controller.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/asset_thumbnail.dart';
import 'package:sift/app/components/sift_top_app_bar.dart';
import 'package:sift/models/photo_category.dart';

/// Opens the per-category photo grid for [category].
void openAiCategory(AiCategoriesController controller, PhotoCategory category) {
  controller.openCategory(category);
  Get.to(
    () => AiCategoryPhotosView(category: category),
    transition: Transition.rightToLeft,
  );
}

/// Grid of the photos detected for a single [PhotoCategory].
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
                          itemBuilder: (context, index) =>
                              _CategoryPhotoTile(photo: photos[index]),
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

class _CategoryPhotoTile extends StatelessWidget {
  const _CategoryPhotoTile({required this.photo});

  final CategorizedPhoto photo;

  @override
  Widget build(BuildContext context) {
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
