import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sift/app/components/onboarding_screen.dart';
import 'package:sift/app/routes/app_routes.dart';

class ProblemFramingView extends StatelessWidget {
  const ProblemFramingView({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingScreen(
      step: 0,
      skipRoute: AppRoutes.homeDashboard,
      eyebrow: 'PHOTOS LIBRARY',
      title: 'Your phone has 23,481 photos.',
      highlight: '12,400 look identical.',
      body:
          'Most of your library is duplicates, screenshots, and forgotten bursts. We\'ll show you what\'s safe to clear - you decide what goes.',
      primaryLabel: 'Show me what to clean',
      onPrimary: () => Get.toNamed(AppRoutes.privacyPromise),
      artType: OnboardingArtType.library,
    );
  }
}
