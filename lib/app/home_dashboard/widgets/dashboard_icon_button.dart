import 'package:flutter/material.dart';
import 'package:sift/app/components/app_colors.dart';

/// Small circular, bordered icon button used on the dashboard header and the
/// access gate.
class DashboardIconButton extends StatelessWidget {
  const DashboardIconButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderFor(context)),
        ),
        child: Icon(icon, size: 18, color: AppColors.textMuted(context)),
      ),
    );
  }
}
