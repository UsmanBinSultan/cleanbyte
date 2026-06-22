import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';

/// A numbered permission step card with an Allow / Manage action and a
/// connecting timeline rail.
class PermissionRow extends StatelessWidget {
  const PermissionRow({
    super.key,
    required this.step,
    required this.icon,
    required this.iconColor,
    required this.tint,
    required this.title,
    required this.tag,
    required this.tagColor,
    required this.body,
    required this.granted,
    required this.loading,
    required this.onAllow,
    required this.onManage,
    this.isLast = false,
  });

  final int step;
  final IconData icon;
  final Color iconColor;
  final Color tint;
  final String title;
  final String tag;
  final Color tagColor;
  final String body;
  final bool granted;
  final bool loading;
  final VoidCallback onAllow;
  final VoidCallback onManage;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.iconChipBg(context, iconColor, tint),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$step',
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: AppColors.borderFor(context),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderFor(context)),
                  boxShadow: AppColors.isLight(context)
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.iconChipBg(
                              context,
                              iconColor,
                              tint,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(icon, color: iconColor, size: 19),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  title,
                                  style: TextStyle(
                                    color: AppColors.textPrimary(context),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: tagColor.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: Text(
                                  tag,
                                  style: TextStyle(
                                    color: tagColor,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      body,
                      style: TextStyle(
                        color: AppColors.textMuted(context),
                        fontSize: 11.5,
                        height: 1.4,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 38,
                      child: TextButton(
                        onPressed: loading
                            ? null
                            : (granted ? onManage : onAllow),
                        style: TextButton.styleFrom(
                          backgroundColor: granted
                              ? AppColors.iconChipBg(
                                  context,
                                  AppColors.accent,
                                  AppColors.tintTeal,
                                )
                              : tagColor.withValues(alpha: 0.12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (loading)
                              const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            else
                              Icon(
                                granted
                                    ? LucideIcons.settings2
                                    : LucideIcons.check,
                                size: 15,
                                color: granted
                                    ? AppColors.accentDeep
                                    : tagColor,
                              ),
                            const SizedBox(width: 6),
                            Text(
                              granted ? 'Allowed · Manage' : 'Allow Access',
                              style: TextStyle(
                                color: granted
                                    ? AppColors.accentDeep
                                    : tagColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
