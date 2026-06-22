import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/home_dashboard/home_dashboard_controller.dart';

/// Bottom confirm bar summarising the marked categories and opening the first
/// one's review screen.
class ConfirmBar extends StatelessWidget {
  const ConfirmBar({
    super.key,
    required this.markedBytes,
    required this.markedCount,
    required this.enabled,
    required this.onConfirm,
  });

  final int markedBytes;
  final int markedCount;
  final bool enabled;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
      decoration: BoxDecoration(
        color: AppColors.bottomBar(context),
        border: Border(top: BorderSide(color: AppColors.borderFor(context))),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Marked for Review: '
                  '${HomeDashboardController.formatBytes(markedBytes)}',
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '$markedCount items',
                style: TextStyle(
                  color: AppColors.textMuted(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: TextButton.icon(
              onPressed: enabled ? onConfirm : null,
              icon: const Icon(LucideIcons.eye, size: 18),
              label: Text(
                'Confirm & Review · '
                '${HomeDashboardController.formatBytes(markedBytes)}',
              ),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.surfaceTint(context),
                disabledForegroundColor: AppColors.textFaint(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
