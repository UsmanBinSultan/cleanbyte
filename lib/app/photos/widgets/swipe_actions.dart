import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';

/// Delete / Skip / Keep action row beneath the swipe review card.
class SwipeActions extends StatelessWidget {
  const SwipeActions({
    super.key,
    required this.isDeleting,
    required this.onDelete,
    required this.onSkip,
    required this.onKeep,
  });

  final bool isDeleting;
  final VoidCallback onDelete;
  final VoidCallback onSkip;
  final VoidCallback onKeep;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SwipeActionButton(
          label: 'Delete',
          icon: LucideIcons.trash2,
          color: AppColors.danger,
          filled: true,
          size: 60,
          busy: isDeleting,
          onTap: isDeleting ? null : onDelete,
        ),
        const SizedBox(width: 28),
        _SwipeActionButton(
          label: 'Skip',
          icon: LucideIcons.chevronsRight,
          color: AppColors.textMuted(context),
          filled: false,
          size: 50,
          onTap: isDeleting ? null : onSkip,
        ),
        const SizedBox(width: 28),
        _SwipeActionButton(
          label: 'Keep',
          icon: LucideIcons.heart,
          color: AppColors.accent,
          filled: true,
          size: 60,
          onTap: isDeleting ? null : onKeep,
        ),
      ],
    );
  }
}

class _SwipeActionButton extends StatelessWidget {
  const _SwipeActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.filled,
    required this.size,
    required this.onTap,
    this.busy = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool filled;
  final double size;
  final VoidCallback? onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkResponse(
            onTap: onTap,
            radius: size * 0.6,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: filled ? color : AppColors.surface(context),
                shape: BoxShape.circle,
                border: filled
                    ? null
                    : Border.all(color: AppColors.borderFor(context)),
                boxShadow: filled
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.32),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: busy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      icon,
                      color: filled ? Colors.white : color,
                      size: size * 0.4,
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textMuted(context),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
