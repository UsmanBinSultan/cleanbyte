import 'package:flutter/material.dart';
import 'package:sift/app/components/app_colors.dart';

/// Subtle, bordered secondary action shown beneath the primary CTA.
class OnboardingSecondaryButton extends StatelessWidget {
  const OnboardingSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 34,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: AppColors.surfaceTint(context),
          foregroundColor: AppColors.textPrimary(context),
          side: BorderSide(color: AppColors.borderFor(context)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
          textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
        ),
        child: Text(label),
      ),
    );
  }
}
