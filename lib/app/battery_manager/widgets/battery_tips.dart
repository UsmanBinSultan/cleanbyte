import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';

/// Static list of battery-care tips.
class BatteryTips extends StatelessWidget {
  const BatteryTips({super.key});

  static const _tips = [
    (LucideIcons.zap, 'Charge between 20–80% for best long-term health'),
    (
      LucideIcons.clock,
      'Avoid charging overnight without Optimised Charging on',
    ),
    (
      LucideIcons.thermometer,
      'Heat degrades battery — remove case while charging',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final tip in _tips)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderFor(context)),
            ),
            child: Row(
              children: [
                Icon(tip.$1, size: 16, color: AppColors.accent),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tip.$2,
                    style: TextStyle(
                      color: AppColors.textMuted(context),
                      fontSize: 12.5,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
