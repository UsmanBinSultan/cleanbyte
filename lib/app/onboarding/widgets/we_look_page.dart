import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/onboarding/onboarding_controller.dart';
import 'package:sift/app/onboarding/widgets/onboarding_dots.dart';
import 'package:sift/app/onboarding/widgets/onboarding_gradient_button.dart';
import 'package:sift/app/onboarding/widgets/onboarding_rich_title.dart';
import 'package:sift/app/onboarding/widgets/onboarding_subtitle.dart';
import 'package:sift/app/onboarding/widgets/onboarding_top_bar.dart';
import 'package:sift/app/onboarding/widgets/photo_grid_art.dart';

/// Onboarding page 0 — "We only look, never delete": the photo collage hero,
/// reassurance copy and a three-point feature strip.
class WeLookPage extends StatelessWidget {
  const WeLookPage({super.key, required this.controller});

  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    final chips = [
      (LucideIcons.search, 'We inspect your\nlibrary'),
      (LucideIcons.image, 'We highlight what\nmatters'),
      (LucideIcons.shieldCheck, "You're always in\ncontrol"),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        child: Column(
          children: [
            OnboardingTopBar(onSkip: controller.skip),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: PhotoGridArt(),
            ),
            const OnboardingRichTitle(
              title: 'We only look,\n',
              highlight: 'never delete.',
            ),
            const SizedBox(height: 14),
            const OnboardingSubtitle(
              'We scan your photos to find duplicates, blurred shots '
              'and similar images. Your photos stay safe.',
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderFor(context)),
                boxShadow: AppColors.isLight(context)
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  for (final chip in chips)
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.iconChipBg(
                                context,
                                AppColors.accent,
                                AppColors.tintTeal,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              chip.$1,
                              color: AppColors.accent,
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            chip.$2,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textPrimary(context),
                              fontSize: 10,
                              height: 1.2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            OnboardingDots(active: controller.currentPage),
            const SizedBox(height: 20),
            OnboardingGradientButton(
              label: 'Get Started',
              icon: LucideIcons.arrowRight,
              onTap: controller.next,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
