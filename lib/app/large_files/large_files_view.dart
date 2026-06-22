import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/sift_bottom_nav_bar.dart';
import 'package:sift/app/components/sift_top_app_bar.dart';
import 'package:sift/app/large_files/large_files_controller.dart';
import 'package:sift/app/large_files/widgets/browse_all_button.dart';
import 'package:sift/app/large_files/widgets/circle_icon_button.dart';
import 'package:sift/app/large_files/widgets/file_search_page.dart';
import 'package:sift/app/large_files/widgets/files_hub_body.dart';

/// "Files" — a browse hub: a device-storage donut, quick source shortcuts and
/// a category grid. Every number is real (device storage, photo library counts
/// and the on-device document scan). Tapping a category opens either a media
/// cleaner or the document review page. Sub-widgets live under `widgets/`.
class LargeFilesView extends StatelessWidget {
  const LargeFilesView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final fromNav = args is Map && args['fromNav'] == true;

    return GetBuilder<LargeFilesController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.pageBackground(context),
          bottomNavigationBar: fromNav
              ? const SiftBottomNavBar(activeIndex: 2)
              : null,
          body: SafeArea(
            bottom: !fromNav,
            child: Column(
              children: [
                SiftTopAppBar(
                  title: 'Files',
                  showBack: !fromNav,
                  trailing: CircleIconButton(
                    icon: LucideIcons.search,
                    onTap: () => Get.to(() => const FileSearchPage()),
                  ),
                ),
                Expanded(child: FilesHubBody(controller: controller)),
                // Pinned at the bottom of the screen, above the nav bar.
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: BrowseAllButton(controller: controller),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
