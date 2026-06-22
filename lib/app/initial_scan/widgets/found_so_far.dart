import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/home_dashboard/home_dashboard_controller.dart';
import 'package:sift/app/initial_scan/initial_scan_controller.dart';
import 'package:sift/app/routes/app_routes.dart';

/// "Found So Far" — three live stat cards (photos / old files / duplicates)
/// sourced from the home dashboard metrics, each opening its cleanup screen.
class FoundSoFar extends StatelessWidget {
  const FoundSoFar({super.key, required this.controller});

  final InitialScanController controller;

  @override
  Widget build(BuildContext context) {
    final home = Get.isRegistered<HomeDashboardController>()
        ? HomeDashboardController.instance
        : null;
    final similar = home?.metric(HomeDashboardController.similarPhotosKey);
    final files = home?.metric(HomeDashboardController.largeFilesKey);
    final dupes = home?.metric(HomeDashboardController.duplicatesKey);

    String bytesLabel(int? bytes) => (bytes ?? 0) > 0
        ? '~${HomeDashboardController.formatBytes(bytes!)}'
        : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Found So Far',
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            InkWell(
              onTap: () => Get.toNamed(AppRoutes.reviewDelete),
              child: Row(
                children: [
                  Text(
                    'View Details',
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
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                ontap: () => Get.toNamed(AppRoutes.similarPhotos),
                label: 'Photos',
                value: '${similar?.count ?? controller.photoCount}',
                sub: bytesLabel(similar?.bytes),
                color: AppColors.accent,
                tint: AppColors.tintMint,
                icon: LucideIcons.image,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                ontap: () => Get.toNamed(AppRoutes.largeFiles),
                label: 'Old Files',
                value: '${files?.count ?? 0}',
                sub: bytesLabel(files?.bytes),
                color: AppColors.iconBlue,
                tint: AppColors.tintBlue,
                icon: LucideIcons.folder,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                ontap: () => Get.toNamed(AppRoutes.duplicates),
                label: 'Duplicates',
                value: '${dupes?.count ?? 0}',
                sub: bytesLabel(dupes?.bytes),
                color: AppColors.iconAmber,
                tint: AppColors.tintAmber,
                icon: LucideIcons.copy,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
    required this.tint,
    required this.icon,
    required this.ontap,
  });

  final String label;
  final String value;
  final String sub;
  final Color color;
  final Color tint;
  final IconData icon;
  final VoidCallback? ontap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.iconChipBg(context, color, tint),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: ontap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(height: 10),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (sub.isNotEmpty)
                Text(
                  sub,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
