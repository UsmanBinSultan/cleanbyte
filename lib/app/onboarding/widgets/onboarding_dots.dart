import 'package:flutter/material.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/onboarding/onboarding_controller.dart';

/// Page-position dots for the onboarding flow; the active dot widens.
class OnboardingDots extends StatelessWidget {
  const OnboardingDots({super.key, required this.active});

  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(OnboardingController.pageCount, (index) {
        final on = index == active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: on ? 22 : 7,
          height: 7,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: on ? AppColors.accent : AppColors.borderFor(context),
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}
