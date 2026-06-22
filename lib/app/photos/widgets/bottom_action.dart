import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/photos/photos_controller.dart';
import 'package:sift/core/utils/formatters.dart';

/// Sticky bottom delete bar for the media tools. For duplicates it also shows a
/// "select all groups" row and a recycle-bin hint.
class BottomAction extends StatelessWidget {
  const BottomAction({super.key, required this.controller});

  final SimilarPhotosController controller;

  @override
  Widget build(BuildContext context) {
    final isDup = controller.mode.isDuplicates;
    final selectedCount = controller.selectedIds.length;
    final enabled = selectedCount > 0 && !controller.isDeleting;
    final label = controller.isDeleting
        ? 'Deleting...'
        : isDup
        ? 'Delete $selectedCount photos · Free ${formatBytes(controller.selectedBytes)}'
        : 'Delete selected ($selectedCount)';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
      decoration: BoxDecoration(
        color: AppColors.bottomBar(context),
        border: Border(top: BorderSide(color: AppColors.borderFor(context))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isDup) ...[
            _SelectAllGroupsRow(controller: controller),
            const SizedBox(height: 10),
          ],
          SizedBox(
            width: double.infinity,
            height: 52,
            child: TextButton.icon(
              onPressed: enabled
                  ? () => confirmAndDeleteSelected(controller)
                  : null,
              icon: controller.isDeleting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(LucideIcons.trash, size: 18),
              label: Text(label),
              style: TextButton.styleFrom(
                disabledBackgroundColor: AppColors.surfaceTint(context),
                disabledForegroundColor: AppColors.textFaint(context),
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          if (isDup)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Review in the Recycle Bin if needed',
                style: TextStyle(
                  color: AppColors.textFaint(context),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SelectAllGroupsRow extends StatelessWidget {
  const _SelectAllGroupsRow({required this.controller});

  final SimilarPhotosController controller;

  @override
  Widget build(BuildContext context) {
    final total = controller.deletableDuplicateCount;
    final selected = controller.selectedIds.length;
    final allSelected = total > 0 && selected == total;
    return Row(
      children: [
        GestureDetector(
          onTap: controller.toggleSelectAll,
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              Icon(
                allSelected ? LucideIcons.checkCircle2 : LucideIcons.circle,
                size: 18,
                color: allSelected
                    ? AppColors.accent
                    : AppColors.textFaint(context),
              ),
              const SizedBox(width: 8),
              Text(
                'Select all groups',
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Text(
          '$selected/$total selected',
          style: TextStyle(
            color: AppColors.textMuted(context),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Confirms then asks the device photo library to delete the selected items.
Future<void> confirmAndDeleteSelected(
  SimilarPhotosController controller,
) async {
  final mediaName = controller.mode.mediaName;
  final confirmed = await Get.dialog<bool>(
    AlertDialog(
      backgroundColor: const Color(0xFF111929),
      title: const Text(
        'Delete selected?',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
      ),
      content: Text(
        'This will ask the device photo library to delete ${controller.selectedIds.length} $mediaName.',
        style: const TextStyle(color: Color(0xFFC2CAD6)),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Get.back(result: true),
          style: TextButton.styleFrom(foregroundColor: const Color(0xFFFF7A5F)),
          child: const Text('Delete'),
        ),
      ],
    ),
  );

  if (confirmed != true) {
    return;
  }

  final deleted = await controller.deleteSelected();
  Get.snackbar(
    deleted == 0 ? 'Nothing deleted' : 'Deleted $deleted',
    deleted == 0
        ? 'The system did not remove any items.'
        : controller.mode.isDuplicates
        ? 'Extra copies removed. One copy of each set was kept.'
        : 'Your library has been updated.',
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: const Color(0xFF111929),
    colorText: Colors.white,
    margin: const EdgeInsets.all(16),
  );
}
