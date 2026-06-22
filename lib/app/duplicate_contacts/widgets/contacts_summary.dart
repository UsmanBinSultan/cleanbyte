import 'package:flutter/material.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/duplicate_contacts/duplicate_contacts_controller.dart';

/// Summary header above the duplicate-group list: a headline plus three stat
/// tiles (total dupes / selected / groups).
class ContactsSummary extends StatelessWidget {
  const ContactsSummary({super.key, required this.controller});

  final DuplicateContactsController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${controller.duplicateCount} Duplicated Contacts',
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 24,
              letterSpacing: -0.8,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${controller.groups.length} matching groups ready to review',
            style: TextStyle(
              color: AppColors.textMuted(context),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _ContactStatTile(
                value: controller.duplicateCount.toString(),
                label: 'Total Dupes',
                accent: AppColors.accent,
                tint: AppColors.tintTeal,
              ),
              const SizedBox(width: 12),
              _ContactStatTile(
                value: controller.selectedIds.length.toString(),
                label: 'Selected',
                accent: AppColors.iconBlue,
                tint: AppColors.tintBlue,
              ),
              const SizedBox(width: 12),
              _ContactStatTile(
                value: controller.groups.length.toString(),
                label: 'Groups',
                accent: AppColors.accentDeep,
                tint: AppColors.tintMint,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactStatTile extends StatelessWidget {
  const _ContactStatTile({
    required this.value,
    required this.label,
    required this.accent,
    required this.tint,
  });

  final String value;
  final String label;
  final Color accent;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: AppColors.iconChipBg(context, accent, tint),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                color: accent,
                fontSize: 20,
                letterSpacing: -0.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
