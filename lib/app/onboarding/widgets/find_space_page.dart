import 'package:flutter/material.dart';
import 'package:sift/app/onboarding/onboarding_controller.dart';
import 'package:sift/app/onboarding/widgets/onboarding_dots.dart';
import 'package:sift/app/onboarding/widgets/onboarding_gradient_button.dart';
import 'package:sift/app/onboarding/widgets/onboarding_rich_title.dart';
import 'package:sift/app/onboarding/widgets/onboarding_subtitle.dart';
import 'package:sift/app/onboarding/widgets/onboarding_top_bar.dart';
import 'package:sift/app/onboarding/widgets/storage_mockup.dart';

/// Onboarding page 1 — "Find what's taking up space": the storage mockup and a
/// short explanation of the scan.
class FindSpacePage extends StatelessWidget {
  const FindSpacePage({super.key, required this.controller});

  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        children: [
          OnboardingTopBar(onSkip: controller.skip),
          const Spacer(flex: 2),
          const StorageMockup(),
          const Spacer(flex: 2),
          const OnboardingRichTitle(
            title: "Find what's taking up\n",
            highlight: 'space.',
          ),
          const SizedBox(height: 14),
          const OnboardingSubtitle(
            'Clean Byte scans your photos, videos, and files '
            'to help you safely free storage.',
          ),
          const Spacer(flex: 3),
          OnboardingDots(active: controller.currentPage),
          const SizedBox(height: 20),
          OnboardingGradientButton(label: 'Next', onTap: controller.next),
        ],
      ),
    );
  }
}
