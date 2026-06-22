import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/onboarding/onboarding_bullet.dart';

/// First-page bullet treatment: a white card with the three feature bullets laid
/// out as icon columns.
class OnboardingBulletCard extends StatelessWidget {
  const OnboardingBulletCard({super.key, required this.bullets});

  final List<OnboardingBullet> bullets;

  @override
  Widget build(BuildContext context) {
    final icons = [
      LucideIcons.search,
      LucideIcons.image,
      LucideIcons.shieldCheck,
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var i = 0; i < bullets.length; i++)
            Expanded(
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8FFF4),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icons[i], color: AppColors.accent, size: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    bullets[i].title.tr,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.lightFg,
                      fontSize: 10,
                      height: 1.1,
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
