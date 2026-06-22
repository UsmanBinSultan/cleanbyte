import 'package:flutter/material.dart';
import 'package:sift/app/components/app_colors.dart';

/// The three-page progress dots, expanding the active one.
class OnboardingDots extends StatelessWidget {
  const OnboardingDots({super.key, required this.activeIndex});

  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          final active = index == activeIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: active ? 24 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: active ? AppColors.accent : const Color(0xFFE2F0EE),
              borderRadius: BorderRadius.circular(999),
            ),
          );
        }),
      ),
    );
  }
}
