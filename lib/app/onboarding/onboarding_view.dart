import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sift/app/components/onboarding_screen.dart';
import 'package:sift/app/onboarding/onboarding_controller.dart';
import 'package:sift/app/routes/app_routes.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OnboardingController>(
      autoRemove: false,
      builder: (controller) {
        return PageView(
          controller: controller.pageController,
          onPageChanged: controller.onPageChanged,
          children: [
            OnboardingScreen(
              step: 0,
              skipRoute: AppRoutes.homeDashboard,
              title: 'onboarding_privacy_title'.tr,
              highlight: null,
              body: '',
              primaryLabel: 'continue'.tr,
              onPrimary: controller.onPrimaryPressed,
              artType: OnboardingArtType.privacy,
              bullets: const [
                OnboardingBullet(
                  title: 'onboarding_ai_title',
                  subtitle: 'onboarding_ai_subtitle',
                ),
                OnboardingBullet(
                  title: 'onboarding_private_title',
                  subtitle: 'onboarding_private_subtitle',
                ),
                OnboardingBullet(
                  title: 'onboarding_crypto_title',
                  subtitle: 'onboarding_crypto_subtitle',
                ),
              ],
              linkLabel: 'privacy_policy'.tr,
            ),
            OnboardingScreen(
              step: 1,
              title: 'onboarding_permission_title'.tr,
              highlight: 'onboarding_permission_highlight'.tr,
              body: 'onboarding_permission_body'.tr,
              primaryLabel: controller.isLoadingLibraryStats
                  ? 'scanning_library'.tr
                  : 'allow_photos_access'.tr,
              onPrimary: controller.onPrimaryPressed,
              secondaryLabel: 'maybe_later'.tr,
              onSecondary: controller.onSecondaryPressed,
              footer: 'onboarding_permission_footer'.tr,
              artType: OnboardingArtType.permission,
            ),
            OnboardingScreen(
              step: 2,
              skipRoute: AppRoutes.homeDashboard,
              eyebrow: 'photos_library'.tr,
              title: controller.libraryTitle,
              highlight: controller.libraryHighlight,
              body: 'onboarding_library_body'.tr,
              primaryLabel: 'show_me_clean'.tr,
              onPrimary: controller.onPrimaryPressed,
              artType: OnboardingArtType.library,
              artBadgeLabel: controller.libraryArtBadgeLabel,
            ),
          ],
        );
      },
    );
  }
}
