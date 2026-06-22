import 'package:flutter/material.dart';
import 'package:sift/app/components/app_colors.dart';

/// Wide-tracked uppercase section heading used on the paywall.
class PaywallSectionLabel extends StatelessWidget {
  const PaywallSectionLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: AppColors.textFaint(context),
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 3,
      ),
    );
  }
}
