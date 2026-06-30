import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/sift_top_app_bar.dart';
import 'package:sift/app/photos/photos_controller.dart';
import 'package:sift/core/utils/formatters.dart';

/// Top app bar for the media tools — title, optional duplicate-group subtitle
/// and a select-all / clear action.
class ToolHeader extends StatelessWidget {
  const ToolHeader({super.key, required this.controller});

  final SimilarPhotosController controller;

  @override
  Widget build(BuildContext context) {
    final isDup = controller.mode.isDuplicates;
    final groups = isDup
        ? controller.duplicateGroups
        : const <DuplicatePhotoGroup>[];
    final savings = groups.fold<int>(
      0,
      (sum, g) => sum + controller.groupExtraBytes(g),
    );
    final allSelected = isDup
        ? controller.selectedIds.length == controller.deletableDuplicateCount &&
              controller.deletableDuplicateCount > 0
        : controller.assets.isNotEmpty &&
              controller.selectedIds.length == controller.assets.length;

    return SiftTopAppBar(
      title: controller.mode.title,
      subtitle: isDup
          ? '${groups.length} groups · ${formatBytes(savings)}'
          : null,
      trailing: TextButton(
        onPressed: controller.assets.isEmpty
            ? null
            : controller.toggleSelectAll,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent,
          disabledForegroundColor: AppColors.textFaint(context),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
        child: Text(allSelected ? 'clear'.tr : 'select all'.tr),
      ),
    );
  }
}
