import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/battery_manager/battery_manager_controller.dart';
import 'package:sift/app/components/app_colors.dart';

/// Card summarising the estimated extra battery from active optimisations.
class ExtraBatteryCard extends StatelessWidget {
  const ExtraBatteryCard({super.key, required this.controller});

  final BatteryManagerController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estimated extra battery',
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${controller.activeOptimisationCount} of '
                  '${controller.optimisations.length} optimisations on',
                  style: TextStyle(
                    color: AppColors.textMuted(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.iconChipBg(
                context,
                AppColors.accent,
                AppColors.tintTeal,
              ),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.zap, size: 13, color: AppColors.accentDeep),
                const SizedBox(width: 4),
                Text(
                  '+${controller.formatSavingMinutes(controller.estimatedSavingMinutes)}',
                  style: const TextStyle(
                    color: AppColors.accentDeep,
                    fontSize: 12,
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
