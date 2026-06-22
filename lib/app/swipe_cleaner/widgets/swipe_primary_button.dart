import 'package:flutter/material.dart';
import 'package:sift/app/components/app_colors.dart';

/// Full-width primary button used by the Swipe Cleaner empty and complete
/// states. Supports a gradient or solid colour, an optional icon and a busy
/// spinner.
class SwipePrimaryButton extends StatelessWidget {
  const SwipePrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.gradient = false,
    this.color,
    this.busy = false,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool gradient;
  final Color? color;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: gradient ? AppColors.accentGradient : null,
        color: gradient ? null : color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextButton(
        onPressed: busy ? null : onTap,
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
        child: busy
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 16),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
