import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/onboarding/onboarding_controller.dart';
import 'package:sift/app/onboarding/widgets/onboarding_gradient_button.dart';
import 'package:sift/app/onboarding/widgets/permission_row.dart';
import 'package:sift/app/onboarding/widgets/permissions_header.dart';

/// Onboarding page 3 — "One last step": the permission request steps plus the
/// start-scan / demo-mode footer.
class PermissionsPage extends StatelessWidget {
  const PermissionsPage({super.key, required this.controller});

  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const PermissionsHeader(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                  child: Column(
                    children: [
                      PermissionRow(
                        step: 1,
                        icon: LucideIcons.image,
                        iconColor: AppColors.accent,
                        tint: AppColors.tintTeal,
                        title: 'Photos & Videos',
                        tag: 'Required',
                        tagColor: AppColors.accentDeep,
                        body:
                            'Scan for duplicates, blurry shots & large videos. '
                            'Read-only — we never touch your library.',
                        granted: controller.photosGranted,
                        loading: controller.requestingPhotos,
                        onAllow: controller.requestPhotos,
                        onManage: controller.openSystemSettings,
                      ),
                      PermissionRow(
                        step: 2,
                        icon: LucideIcons.folder,
                        iconColor: AppColors.iconBlue,
                        tint: AppColors.tintBlue,
                        title: 'Files & Downloads',
                        tag: 'Optional',
                        tagColor: AppColors.iconBlue,
                        body:
                            'Find large or unused downloaded files. '
                            'You always pick what gets removed.',
                        granted: controller.filesGranted,
                        loading: controller.requestingFiles,
                        onAllow: controller.requestFiles,
                        onManage: controller.openSystemSettings,
                      ),
                      PermissionRow(
                        step: 3,
                        icon: LucideIcons.users,
                        iconColor: AppColors.iconPurple,
                        tint: AppColors.tintPurple,
                        title: 'Contacts',
                        tag: 'Optional',
                        tagColor: AppColors.iconPurple,
                        body:
                            'Detect duplicate or incomplete entries. '
                            'Nothing is sent to any server, 100% local.',
                        granted: controller.contactsGranted,
                        loading: controller.requestingContacts,
                        onAllow: controller.requestContacts,
                        onManage: controller.openSystemSettings,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
          child: Column(
            children: [
              TextButton(
                onPressed: controller.skip,
                child: Text(
                  'Or try Demo Mode without permissions',
                  style: TextStyle(
                    color: AppColors.textMuted(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              OnboardingGradientButton(
                label: 'Start My First Scan',
                leadingIcon: LucideIcons.search,
                onTap: controller.startFirstScan,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
