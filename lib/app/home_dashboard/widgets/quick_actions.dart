import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/home_dashboard/home_dashboard_controller.dart';
import 'package:sift/app/routes/app_routes.dart';

/// "Quick Actions" — the first four cleanup categories as a 2-column grid plus
/// a "See all" link to the full action list.
class QuickActions extends StatelessWidget {
  const QuickActions({super.key, required this.controller});

  final HomeDashboardController controller;

  List<_ActionData> _all() => [
    _ActionData(
      title: 'Duplicate Photos',
      metricKey: HomeDashboardController.duplicatesKey,
      icon: LucideIcons.copy,
      iconColor: AppColors.accent,
      tint: AppColors.tintTeal,
      route: AppRoutes.duplicates,
    ),
    _ActionData(
      title: 'Large Videos',
      metricKey: HomeDashboardController.largeVideosKey,
      icon: LucideIcons.video,
      iconColor: AppColors.iconAmber,
      tint: AppColors.tintAmber,
      route: AppRoutes.largeVideos,
    ),
    _ActionData(
      title: 'Screenshots',
      metricKey: HomeDashboardController.screenshotsKey,
      icon: LucideIcons.smartphone,
      iconColor: AppColors.iconPurple,
      tint: AppColors.tintPurple,
      route: AppRoutes.screenshots,
    ),
    _ActionData(
      title: 'Files',
      metricKey: HomeDashboardController.largeFilesKey,
      icon: LucideIcons.folder,
      iconColor: AppColors.iconBlue,
      tint: AppColors.tintBlue,
      route: AppRoutes.largeFiles,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final visible = _all();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Quick Actions',
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                await Get.toNamed(AppRoutes.allActions);
                await controller.refreshSummary();
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  children: [
                    Text(
                      'See all',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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
        const SizedBox(height: 12),
        GridView.builder(
          itemCount: visible.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.55,
          ),
          itemBuilder: (context, index) =>
              _ActionCard(data: visible[index], controller: controller),
        ),
      ],
    );
  }
}

class _ActionData {
  const _ActionData({
    required this.title,
    required this.metricKey,
    required this.icon,
    required this.iconColor,
    required this.tint,
    required this.route,
  });

  final String title;
  final String metricKey;
  final IconData icon;
  final Color iconColor;
  final Color tint;
  final String route;
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.data, required this.controller});

  final _ActionData data;
  final HomeDashboardController controller;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () async {
        await Get.toNamed(data.route);
        await controller.refreshSummary();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.borderFor(context)),
          boxShadow: AppColors.isLight(context)
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
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
                      data.iconColor,
                      data.tint,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(data.icon, color: data.iconColor, size: 20),
                ),
                const Spacer(),
                Icon(
                  LucideIcons.chevronRight,
                  size: 15,
                  color: AppColors.textFaint(context),
                ),
              ],
            ),
            const Spacer(),
            Text(
              data.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              controller.metricSubtitle(data.metricKey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
