import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';

/// Shown when there is nothing left to review.
class EmptyReview extends StatelessWidget {
  const EmptyReview({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.iconChipBg(
                  context,
                  AppColors.accent,
                  AppColors.tintTeal,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.checkCircle2,
                size: 34,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              "You're all clean!",
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Run a Smart Scan to find more to review.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
