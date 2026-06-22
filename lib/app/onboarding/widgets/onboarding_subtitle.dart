import 'package:flutter/material.dart';
import 'package:sift/app/components/app_colors.dart';

/// Centered muted subtitle paragraph used under each onboarding title.
class OnboardingSubtitle extends StatelessWidget {
  const OnboardingSubtitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: AppColors.textMuted(context),
        fontSize: 15,
        height: 1.55,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
