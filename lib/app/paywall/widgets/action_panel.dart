import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';

/// Data for one row in the paywall [ActionPanel].
class ActionRowData {
  const ActionRowData({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing = LucideIcons.chevronRight,
    this.isLoading = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final IconData trailing;
  final bool isLoading;
  final VoidCallback? onTap;
}

/// Bordered panel that stacks the manage / cancel / refund action rows.
class ActionPanel extends StatelessWidget {
  const ActionPanel({super.key, required this.rows});

  final List<ActionRowData> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            _ActionRow(data: rows[i]),
            if (i != rows.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                color: AppColors.borderFor(context),
                indent: 45,
              ),
          ],
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.data});

  final ActionRowData data;

  @override
  Widget build(BuildContext context) {
    final light = AppColors.isLight(context);
    return InkWell(
      onTap: data.isLoading ? null : data.onTap,
      child: SizedBox(
        height: 60,
        child: Row(
          children: [
            const SizedBox(width: 11),
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: light
                    ? AppColors.lightSurfaceTint
                    : const Color(0xFF1B2334),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderFor(context)),
              ),
              child: Icon(
                data.icon,
                color: AppColors.textMuted(context),
                size: 15,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    data.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textMuted(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            if (data.isLoading)
              const SizedBox(
                width: 15,
                height: 15,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.accent,
                ),
              )
            else
              Icon(
                data.trailing,
                color: AppColors.textFaint(context),
                size: 15,
              ),
            const SizedBox(width: 13),
          ],
        ),
      ),
    );
  }
}
