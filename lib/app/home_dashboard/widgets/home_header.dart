import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/home_dashboard/home_dashboard_controller.dart';
import 'package:sift/app/home_dashboard/widgets/dashboard_icon_button.dart';

/// Dashboard greeting header: time-of-day greeting, a reviewable-storage
/// subtitle and a settings gear that switches to the settings tab.
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, required this.controller});

  final HomeDashboardController controller;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final reclaimable = controller.reclaimableBytes;
    final subtitle = controller.isLoadingSummary && reclaimable <= 0
        ? 'Checking what can be cleaned…'
        : reclaimable > 0
        ? '${HomeDashboardController.formatBytes(reclaimable)} may be reviewable'
        : 'Your storage looks tidy';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$_greeting 👋',
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppColors.textMuted(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        DashboardIconButton(
          icon: LucideIcons.settings,
          onTap: () => controller.changeTab(3),
        ),
      ],
    );
  }
}
