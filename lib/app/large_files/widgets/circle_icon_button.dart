import 'package:flutter/material.dart';
import 'package:sift/app/components/app_colors.dart';

/// Small circular, bordered icon button used in the Files hub app bar.
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({super.key, required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface(context),
      shape: CircleBorder(
        side: BorderSide(color: AppColors.borderFor(context)),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(icon, size: 18, color: AppColors.textPrimary(context)),
        ),
      ),
    );
  }
}
