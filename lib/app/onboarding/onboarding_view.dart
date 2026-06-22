import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/onboarding/onboarding_controller.dart';
import 'package:sift/app/onboarding/widgets/find_space_page.dart';
import 'package:sift/app/onboarding/widgets/permissions_page.dart';
import 'package:sift/app/onboarding/widgets/privacy_page.dart';
import 'package:sift/app/onboarding/widgets/we_look_page.dart';

/// The 4-page onboarding flow. Each page lives in its own file under
/// `widgets/`; this view just hosts the PageView and shared controller.
class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OnboardingController>(
      autoRemove: false,
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.pageBackground(context),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: PageView(
                  controller: controller.pageController,
                  onPageChanged: controller.onPageChanged,
                  children: [
                    WeLookPage(controller: controller),
                    FindSpacePage(controller: controller),
                    PrivacyPage(controller: controller),
                    PermissionsPage(controller: controller),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
