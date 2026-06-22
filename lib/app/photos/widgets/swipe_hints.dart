import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';

/// "Swipe left to delete / Swipe right to keep" hint chips.
class SwipeHints extends StatelessWidget {
  const SwipeHints({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const _SwipeHint(
          label: 'Swipe left',
          sub: 'to delete',
          color: AppColors.danger,
          tint: AppColors.dangerBg,
          icon: LucideIcons.chevronLeft,
          iconLeading: true,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or',
            style: TextStyle(
              color: AppColors.textFaint(context),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const _SwipeHint(
          label: 'Swipe right',
          sub: 'to keep',
          color: AppColors.accentDeep,
          tint: AppColors.tintTeal,
          icon: LucideIcons.chevronRight,
          iconLeading: false,
        ),
      ],
    );
  }
}

class _SwipeHint extends StatelessWidget {
  const _SwipeHint({
    required this.label,
    required this.sub,
    required this.color,
    required this.tint,
    required this.icon,
    required this.iconLeading,
  });

  final String label;
  final String sub;
  final Color color;
  final Color tint;
  final IconData icon;
  final bool iconLeading;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.iconChipBg(context, color, tint),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (iconLeading) ...[
                Icon(icon, size: 13, color: color),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (!iconLeading) ...[
                const SizedBox(width: 4),
                Icon(icon, size: 13, color: color),
              ],
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          sub,
          style: TextStyle(
            color: AppColors.textFaint(context),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
