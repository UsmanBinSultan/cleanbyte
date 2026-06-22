import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/swipe_cleaner/swipe_cleaner_controller.dart';
import 'package:sift/core/utils/formatters.dart';

/// The undo / delete / keep button row beneath the swipe deck, with a
/// marked-count summary line.
class SwipeActionBar extends StatelessWidget {
  const SwipeActionBar({
    super.key,
    required this.controller,
    required this.busy,
    required this.onUndo,
    required this.onDelete,
    required this.onKeep,
  });

  final SwipeCleanerController controller;
  final bool busy;
  final VoidCallback? onUndo;
  final VoidCallback onDelete;
  final VoidCallback onKeep;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Column(
        children: [
          if (controller.markedCount > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                '${controller.markedCount} marked · frees ~${formatBytes(controller.markedBytes)}',
                style: TextStyle(
                  color: AppColors.textMuted(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _RoundAction(
                icon: LucideIcons.undo2,
                color: AppColors.iconAmber,
                size: 52,
                onTap: busy ? null : onUndo,
              ),
              const SizedBox(width: 22),
              _RoundAction(
                icon: LucideIcons.x,
                color: AppColors.danger,
                size: 68,
                filled: true,
                onTap: busy ? null : onDelete,
              ),
              const SizedBox(width: 22),
              _RoundAction(
                icon: LucideIcons.heart,
                color: AppColors.accent,
                size: 68,
                filled: true,
                onTap: busy ? null : onKeep,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.icon,
    required this.color,
    required this.size,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback? onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: filled ? color : AppColors.surface(context),
            shape: BoxShape.circle,
            border: filled
                ? null
                : Border.all(color: color.withValues(alpha: 0.4)),
            boxShadow: filled
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.32),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            icon,
            color: filled ? Colors.white : color,
            size: size * 0.42,
          ),
        ),
      ),
    );
  }
}
