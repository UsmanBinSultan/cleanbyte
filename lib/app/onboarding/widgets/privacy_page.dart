import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/onboarding/onboarding_controller.dart';
import 'package:sift/app/onboarding/widgets/onboarding_dots.dart';
import 'package:sift/app/onboarding/widgets/onboarding_gradient_button.dart';
import 'package:sift/app/onboarding/widgets/onboarding_rich_title.dart';
import 'package:sift/app/onboarding/widgets/onboarding_subtitle.dart';
import 'package:sift/app/onboarding/widgets/onboarding_top_bar.dart';
import 'package:sift/app/onboarding/widgets/privacy_card.dart';
import 'package:sift/app/onboarding/widgets/privacy_mockup.dart';

/// Onboarding page 2 — "Your photos stay private": the dark privacy mockup and
/// three on-device reassurance cards.
class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key, required this.controller});

  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    final cards = [
      (
        LucideIcons.search,
        'Scan runs on your device',
        'No data ever leaves your phone. Everything is processed locally.',
        'On-device',
      ),
      (
        LucideIcons.cloudOff,
        'No uploads, ever',
        'Your photos and videos are never uploaded to any server.',
        'Zero uploads',
      ),
      (
        LucideIcons.shieldCheck,
        'You approve every deletion',
        'Nothing is removed without your explicit tap. You are always in control.',
        'You decide',
      ),
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        children: [
          OnboardingTopBar(onSkip: controller.skip),
          const SizedBox(height: 12),
          const PrivacyMockup(),
          const SizedBox(height: 18),
          const OnboardingRichTitle(
            title: 'Your photos\n',
            highlight: 'stay private.',
          ),
          const SizedBox(height: 12),
          const OnboardingSubtitle(
            'Clean Byte never sees your media. Everything happens '
            'on your device, with your permission.',
          ),
          const SizedBox(height: 20),
          for (final card in cards) ...[
            PrivacyCard(
              icon: card.$1,
              title: card.$2,
              body: card.$3,
              tag: card.$4,
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 8),
          OnboardingDots(active: controller.currentPage),
          const SizedBox(height: 20),
          OnboardingGradientButton(label: 'Next', onTap: controller.next),
        ],
      ),
    );
  }
}
