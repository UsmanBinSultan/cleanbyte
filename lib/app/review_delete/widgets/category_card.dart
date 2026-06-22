import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/cleanup_action.dart';

/// One cleanup category on the Review & Delete screen: an icon header, the
/// Review all / Keep all mark buttons and a "View all items" link.
class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.action,
    required this.subtitle,
    required this.marked,
    required this.onMark,
    required this.onKeep,
    required this.onViewAll,
  });

  final CleanupAction action;
  final String? subtitle;
  final bool marked;
  final VoidCallback onMark;
  final VoidCallback onKeep;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: marked ? AppColors.danger : AppColors.borderFor(context),
          width: marked ? 1.5 : 1,
        ),
        boxShadow: AppColors.isLight(context)
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.iconChipBg(
                      context,
                      action.iconColor,
                      action.tint,
                    ),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(action.icon, color: action.iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textPrimary(context),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle ?? 'Ready to review',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textMuted(context),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Row(
              children: [
                Expanded(
                  child: _MarkButton(
                    label: 'Review all',
                    icon: LucideIcons.eye,
                    color: AppColors.danger,
                    tint: AppColors.dangerBg,
                    active: marked,
                    onTap: onMark,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MarkButton(
                    label: 'Keep all',
                    icon: LucideIcons.check,
                    color: AppColors.accentDeep,
                    tint: AppColors.tintTeal,
                    active: !marked,
                    onTap: onKeep,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.borderFor(context)),
          InkWell(
            onTap: onViewAll,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'View all items',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    LucideIcons.chevronRight,
                    size: 15,
                    color: AppColors.accent,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MarkButton extends StatelessWidget {
  const _MarkButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.tint,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color tint;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active
              ? AppColors.iconChipBg(context, color, tint)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? color : AppColors.borderFor(context),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: active ? color : AppColors.textMuted(context),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: active ? color : AppColors.textMuted(context),
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
