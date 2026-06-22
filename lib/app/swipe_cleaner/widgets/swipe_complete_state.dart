import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/swipe_cleaner/swipe_cleaner_controller.dart';
import 'package:sift/app/swipe_cleaner/widgets/swipe_primary_button.dart';
import 'package:sift/core/utils/formatters.dart';

/// Shown once every photo has been reviewed: a summary plus actions to commit
/// the deletions, review again or return home.
class SwipeCompleteState extends StatelessWidget {
  const SwipeCompleteState({super.key, required this.controller});

  final SwipeCleanerController controller;

  Future<void> _commit() async {
    final removed = await controller.commit();
    Get.snackbar(
      'Swipe Cleaner',
      removed > 0
          ? 'Moved $removed ${removed == 1 ? 'photo' : 'photos'} to the recycle bin.'
          : 'Nothing was removed.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    final marked = controller.markedCount;
    final done = controller.didCommit;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: AppColors.iconChipBg(
                context,
                AppColors.accent,
                AppColors.tintTeal,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              done ? LucideIcons.check : LucideIcons.sparkles,
              size: 36,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            done ? 'All done!' : 'Review complete',
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            done
                ? 'Cleaned-up photos are safe in the recycle bin for 30 days.'
                : '${controller.keptCount} kept · $marked marked for deletion.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted(context),
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 28),
          if (!done && marked > 0)
            SwipePrimaryButton(
              label:
                  'Delete $marked ${marked == 1 ? 'photo' : 'photos'}'
                  ' · frees ~${formatBytes(controller.markedBytes)}',
              color: AppColors.danger,
              icon: LucideIcons.trash2,
              busy: controller.isCommitting,
              onTap: _commit,
            ),
          if (!done && marked > 0) const SizedBox(height: 12),
          SwipePrimaryButton(
            label: 'Review again',
            gradient: true,
            icon: LucideIcons.refreshCw,
            onTap: controller.load,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: Get.back,
            child: Text(
              'Back to home',
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
