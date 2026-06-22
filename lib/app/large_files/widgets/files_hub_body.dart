import 'package:flutter/material.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/loading_shimmer.dart';
import 'package:sift/app/large_files/large_files_controller.dart';
import 'package:sift/app/large_files/widgets/category_grid.dart';
import 'package:sift/app/large_files/widgets/source_grid.dart';
import 'package:sift/app/large_files/widgets/storage_donut_card.dart';

/// Scrollable body of the Files hub: device-storage donut, source shortcuts
/// and the category grid. The browse-all action is pinned below this by the
/// host view, so it is not part of the scroll content.
class FilesHubBody extends StatelessWidget {
  const FilesHubBody({super.key, required this.controller});

  final LargeFilesController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const ListShimmer();
    }

    final hasSources =
        controller.files.isNotEmpty &&
        (controller.sourceBytes(LargeFilesController.sourceDownloads) > 0 ||
            controller.sourceBytes(LargeFilesController.sourceDocuments) > 0 ||
            controller.sourceBytes(LargeFilesController.sourceWhatsApp) > 0 ||
            controller.recentBytes > 0);

    return RefreshIndicator(
      color: AppColors.accent,
      backgroundColor: AppColors.surface(context),
      onRefresh: controller.loadFiles,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
        children: [
          if (controller.hasStorageStats) ...[
            StorageDonutCard(controller: controller),
            const SizedBox(height: 16),
          ],
          if (hasSources) ...[
            SourceGrid(controller: controller),
            const SizedBox(height: 22),
          ],
          Text(
            'Browse by Category',
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 14),
          CategoryGrid(controller: controller),
        ],
      ),
    );
  }
}
