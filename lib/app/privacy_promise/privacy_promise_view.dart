import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sift/app/components/onboarding_screen.dart';
import 'package:sift/app/routes/app_routes.dart';

class PrivacyPromiseView extends StatelessWidget {
  const PrivacyPromiseView({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingScreen(
      step: 1,
      skipRoute: AppRoutes.homeDashboard,
      title: 'Your photos never leave your phone.',
      highlight: null,
      body: '',
      primaryLabel: 'Continue',
      onPrimary: () => Get.toNamed(AppRoutes.permissionRationale),
      artType: OnboardingArtType.privacy,
      bullets: const [
        OnboardingBullet(
          title: '100% on-device AI',
          subtitle: 'Nothing uploads. No servers.',
        ),
        OnboardingBullet(
          title: 'We can\'t see your photos. Ever.',
          subtitle: 'Even we don\'t have a way to look.',
        ),
        OnboardingBullet(
          title: 'Open source crypto, audited annually',
          subtitle: 'Latest report: March 2026.',
        ),
      ],
      footer: null,
      linkLabel: 'Read our privacy policy',
    );
  }
}
