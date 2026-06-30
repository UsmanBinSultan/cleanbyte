import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/home_dashboard/home_dashboard_controller.dart';
import 'package:sift/app/home_dashboard/widgets/dashboard_icon_button.dart';

/// Shown on the home tab when media access has not been granted: an explainer
/// and the "Allow Access" / "Open Settings" actions.
class AccessGate extends StatelessWidget {
  const AccessGate({super.key, required this.controller});

  final HomeDashboardController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 6, 24, 104),
      child: Column(
        children: [
          Align(
            // Directional so the settings button moves to the leading edge in RTL.
            alignment: AlignmentDirectional.centerEnd,
            child: DashboardIconButton(
              icon: LucideIcons.settings,
              onTap: () => controller.changeTab(3),
            ),
          ),
          const Spacer(),
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.iconChipBg(
                context,
                AppColors.accent,
                AppColors.tintTeal,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.imagePlus,
              size: 38,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Allow access to clean up',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Clean Byte scans your photos and files on your device to find '
            'what is taking up space. Your data never leaves your phone.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted(context),
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 26),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppColors.accentGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: TextButton.icon(
                onPressed: controller.requestMediaAccess,
                icon: const Icon(LucideIcons.unlock, size: 17),
                label: const Text('Allow Access'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: controller.openMediaSettings,
            child: Text(
              'Open Settings',
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.shieldCheck,
                size: 13,
                color: AppColors.textFaint(context),
              ),
              const SizedBox(width: 6),
              Text(
                'Nothing leaves your device',
                style: TextStyle(
                  color: AppColors.textFaint(context),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
