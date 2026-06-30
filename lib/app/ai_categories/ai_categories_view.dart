import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sift/app/ai_categories/ai_categories_controller.dart';
import 'package:sift/app/ai_categories/widgets/categories_body.dart';
import 'package:sift/app/ai_categories/widgets/view_toggle.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/sift_bottom_nav_bar.dart';
import 'package:sift/app/components/sift_top_app_bar.dart';

/// "AI Categories" — auto-sorts the photo library into smart categories. The
/// body and per-category grid live alongside this file under `widgets/` and
/// `ai_category_photos_view.dart`.
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
                  title: 'Ai Categories'.tr,
                  subtitle: controller.isScanning
                      ? '${controller.scannedCount} of ${controller.totalToScan} scanned'
                      : '${controller.totalPhotos} photos · last scanned today',
                  showBack: !fromNav,
                  trailing: controller.hasAccess && controller.totalPhotos > 0
                      ? ViewToggle(controller: controller)
                      : null,
                ),
                Expanded(child: CategoriesBody(controller: controller)),
              ],
            ),
          ),
          bottomNavigationBar: const SiftBottomNavBar(activeIndex: 1),
        );
      },
    );
  }
}
