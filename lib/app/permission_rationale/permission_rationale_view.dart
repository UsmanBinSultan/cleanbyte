import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sift/app/components/onboarding_screen.dart';
import 'package:sift/app/routes/app_routes.dart';

class PermissionRationaleView extends StatelessWidget {
  const PermissionRationaleView({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingScreen(
      step: 2,
      title: 'We need to read your photos.',
      highlight: 'Just to look - never to delete.',
      body:
          'The AI runs on your phone, side-by-side with your library, looking for duplicates, blurs, and photos you\'d never miss.\n\nApple shows you a permission prompt next. We keep it minimal - read access only, no metadata sync.',
      primaryLabel: 'Allow photos access',
      onPrimary: () => Get.toNamed(AppRoutes.initialScan),
      secondaryLabel: 'Maybe later',
      onSecondary: () => Get.toNamed(AppRoutes.initialScan),
      footer: 'We only read photos. We never delete without your tap.',
      artType: OnboardingArtType.permission,
    );
  }
}
