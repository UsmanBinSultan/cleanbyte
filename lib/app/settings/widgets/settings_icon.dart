import 'package:flutter/material.dart';
import 'package:sift/app/components/app_colors.dart';

/// Tinted rounded-square leading icon used on every settings row.
class SettingsIcon extends StatelessWidget {
  const SettingsIcon({
    super.key,
    required this.icon,
    required this.color,
    required this.tint,
  });

  final IconData icon;
  final Color color;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: AppColors.iconChipBg(context, color, tint),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 17),
    );
  }
}
