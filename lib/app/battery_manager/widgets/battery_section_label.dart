import 'package:flutter/material.dart';
import 'package:sift/app/components/app_colors.dart';

/// Section heading used between battery manager sections.
class BatterySectionLabel extends StatelessWidget {
  const BatterySectionLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: AppColors.textPrimary(context),
        fontSize: 16,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
      ),
    );
  }
}
