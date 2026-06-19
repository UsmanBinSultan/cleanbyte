import 'package:flutter/material.dart';
import 'package:sift/app/components/app_colors.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.secondary = false,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool secondary;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: secondary ? null : AppColors.accentGradient,
          color: secondary ? AppColors.surfaceTint(context) : null,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: secondary
                ? AppColors.borderFor(context)
                : Colors.transparent,
          ),
          boxShadow: secondary
              ? null
              : [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.24),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: TextButton.icon(
          onPressed: onPressed,
          icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 19),
          label: Text(label),
          style: TextButton.styleFrom(
            foregroundColor: secondary
                ? AppColors.textMuted(context)
                : Colors.white,
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
        ),
      ),
    );
  }
}
