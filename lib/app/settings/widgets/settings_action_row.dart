import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/settings/widgets/settings_icon.dart';

/// Tappable settings row with a leading icon, title, optional subtitle, an
/// optional trailing value and a chevron.
class SettingsActionRow extends StatelessWidget {
  const SettingsActionRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.tint,
    required this.titleKey,
    this.subtitleKey,
    this.valueKey,
    this.valueText,
    this.onTap,
    this.titleColor,
  });

  final IconData icon;
  final Color iconColor;
  final Color tint;
  final String titleKey;
  final String? subtitleKey;
  final String? valueKey;
  final String? valueText;
  final VoidCallback? onTap;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 60,
        child: Row(
          children: [
            const SizedBox(width: 14),
            SettingsIcon(icon: icon, color: iconColor, tint: tint),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titleKey.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: titleColor ?? AppColors.textPrimary(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitleKey != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitleKey!.tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textMuted(context),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Text(
              valueText ?? valueKey?.tr ?? '',
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? LucideIcons.chevronLeft
                  : LucideIcons.chevronRight,
              color: AppColors.textFaint(context),
              size: 16,
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}
