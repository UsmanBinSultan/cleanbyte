import 'package:flutter/material.dart';
import 'package:sift/app/components/app_colors.dart';

/// Centered two-tone onboarding title (plain text plus an accent highlight).
class OnboardingRichTitle extends StatelessWidget {
  const OnboardingRichTitle({
    super.key,
    required this.title,
    required this.highlight,
  });

  final String title;
  final String highlight;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: title),
          TextSpan(
            text: highlight,
            style: const TextStyle(color: AppColors.accent),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      style: TextStyle(
        color: AppColors.textPrimary(context),
        fontSize: 26,
        height: 1.2,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
    );
  }
}
