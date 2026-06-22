import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/battery_manager/battery_manager_controller.dart';
import 'package:sift/app/components/app_colors.dart';

/// Gradient CTA that turns on every battery optimisation at once.
class ApplyButton extends StatelessWidget {
  const ApplyButton({super.key, required this.controller});

  final BatteryManagerController controller;

  @override
  Widget build(BuildContext context) {
    final allOn =
        controller.activeOptimisationCount == controller.optimisations.length;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppColors.accentGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: TextButton.icon(
          onPressed: allOn ? null : controller.applyAllOptimisations,
          icon: const Icon(LucideIcons.zap, size: 17),
          label: Text(
            allOn
                ? 'All optimisations on'
                : 'Apply All Optimisations · +${controller.formatSavingMinutes(controller.maxSavingMinutes)}',
          ),
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            disabledForegroundColor: Colors.white70,
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
    );
  }
}
