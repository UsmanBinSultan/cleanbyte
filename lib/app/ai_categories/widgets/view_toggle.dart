import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/ai_categories/ai_categories_controller.dart';
import 'package:sift/app/components/app_colors.dart';

/// List / grid layout toggle shown in the AI categories app bar.
class ViewToggle extends StatelessWidget {
  const ViewToggle({super.key, required this.controller});

  final AiCategoriesController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surfaceTint(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _ToggleButton(
            icon: LucideIcons.list,
            active: !controller.isGridView,
            onTap: () => controller.setGridView(false),
          ),
          _ToggleButton(
            icon: LucideIcons.layoutGrid,
            active: controller.isGridView,
            onTap: () => controller.setGridView(true),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        width: 30,
        height: 28,
        decoration: BoxDecoration(
          color: active ? AppColors.surface(context) : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: active && AppColors.isLight(context)
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: 15,
          color: active ? AppColors.accent : AppColors.textMuted(context),
        ),
      ),
    );
  }
}
