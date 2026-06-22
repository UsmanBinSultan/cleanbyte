import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/onboarding/onboarding_bullet.dart';

/// Later-page bullet treatment: a check chip with a title + subtitle row.
class OnboardingBulletRow extends StatelessWidget {
  const OnboardingBulletRow({super.key, required this.bullet});

  final OnboardingBullet bullet;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.check,
              size: 12,
              color: Color(0xFF061019),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bullet.title.tr,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  bullet.subtitle.tr,
                  style: TextStyle(
                    color: AppColors.textMuted(context),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
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
