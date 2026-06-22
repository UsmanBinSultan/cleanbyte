import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';

/// Info row explaining that the best photo of each duplicate group was kept.
class AiPickNote extends StatelessWidget {
  const AiPickNote({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.iconChipBg(
                context,
                AppColors.iconPurple,
                AppColors.tintPurple,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.sparkles,
              size: 16,
              color: AppColors.iconPurple,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'We picked the sharpest, best-exposed photo from each group. '
              'Review before deleting.',
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
