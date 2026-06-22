import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/swipe_cleaner/swipe_cleaner_controller.dart';

/// Swipe Cleaner top bar: back button, title with a reviewed/total status line
/// and a marked-for-deletion counter chip.
class SwipeTopBar extends StatelessWidget {
  const SwipeTopBar({super.key, required this.controller});

  final SwipeCleanerController controller;

  @override
  Widget build(BuildContext context) {
    final reviewing =
        controller.hasAccess && controller.total > 0 && !controller.isComplete;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          InkWell(
            onTap: Get.back,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderFor(context)),
              ),
              child: Icon(
                LucideIcons.chevronLeft,
                size: 18,
                color: AppColors.textMuted(context),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Swipe Cleaner',
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                Text(
                  reviewing
                      ? '${controller.reviewedCount} of ${controller.total} reviewed'
                      : 'Keep favorites · delete clutter',
                  style: TextStyle(
                    color: AppColors.textMuted(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (reviewing && controller.markedCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.trash2, size: 13, color: AppColors.danger),
                  const SizedBox(width: 5),
                  Text(
                    '${controller.markedCount}',
                    style: TextStyle(
                      color: AppColors.danger,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
