import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/home_dashboard/home_dashboard_controller.dart';
import 'package:sift/app/routes/app_routes.dart';

/// A single cleanup category surfaced on the Home, All Actions and
/// Review & Delete screens. Kept in one place so every list stays in sync.
class CleanupAction {
  const CleanupAction({
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

/// The canonical, ordered list of cleanup categories.
const List<CleanupAction> kCleanupActions = [
  CleanupAction(
    title: 'Duplicate Photos',
    metricKey: HomeDashboardController.duplicatesKey,
    icon: LucideIcons.copy,
    iconColor: AppColors.accent,
    tint: AppColors.tintTeal,
    route: AppRoutes.duplicates,
  ),
  CleanupAction(
    title: 'Large Videos',
    metricKey: HomeDashboardController.largeVideosKey,
    icon: LucideIcons.video,
    iconColor: AppColors.iconAmber,
    tint: AppColors.tintAmber,
    route: AppRoutes.largeVideos,
  ),
  CleanupAction(
    title: 'Screenshots',
    metricKey: HomeDashboardController.screenshotsKey,
    icon: LucideIcons.smartphone,
    iconColor: AppColors.iconPurple,
    tint: AppColors.tintPurple,
    route: AppRoutes.screenshots,
  ),
  CleanupAction(
    title: 'Files',
    metricKey: HomeDashboardController.largeFilesKey,
    icon: LucideIcons.folder,
    iconColor: AppColors.iconBlue,
    tint: AppColors.tintBlue,
    route: AppRoutes.largeFiles,
  ),
  CleanupAction(
    title: 'Photos',
    metricKey: HomeDashboardController.similarPhotosKey,
    icon: LucideIcons.image,
    iconColor: AppColors.accent,
    tint: AppColors.tintMint,
    route: AppRoutes.similarPhotos,
  ),
  CleanupAction(
    title: 'Blurred Photos',
    metricKey: HomeDashboardController.blurredPhotosKey,
    icon: LucideIcons.focus,
    iconColor: AppColors.iconPink,
    tint: AppColors.tintPink,
    route: AppRoutes.blurredPhotos,
  ),
  CleanupAction(
    title: 'Photo Compressor',
    metricKey: HomeDashboardController.photoCompressorKey,
    icon: LucideIcons.minimize2,
    iconColor: AppColors.iconPink,
    tint: AppColors.tintPink,
    route: AppRoutes.photoCompressor,
  ),
  CleanupAction(
    title: 'Duplicate Contacts',
    metricKey: HomeDashboardController.duplicateContactsKey,
    icon: LucideIcons.users,
    iconColor: AppColors.iconAmber,
    tint: AppColors.tintAmber,
    route: AppRoutes.duplicateContacts,
  ),
  CleanupAction(
    title: 'WhatsApp Cleaner',
    metricKey: HomeDashboardController.whatsappCleanerKey,
    icon: LucideIcons.messageCircle,
    iconColor: AppColors.whatsapp,
    tint: AppColors.tintGreen,
    route: AppRoutes.whatsappCleaner,
  ),
  // CleanupAction(
  //   title: 'Apps Manager',
  //   metricKey: HomeDashboardController.appsManagerKey,
  //   icon: LucideIcons.layoutGrid,
  //   iconColor: AppColors.iconBlue,
  //   tint: AppColors.tintBlue,
  //   route: AppRoutes.appsManager,
  // ),
  CleanupAction(
    title: 'Battery Saver',
    metricKey: HomeDashboardController.batteryManagerKey,
    icon: LucideIcons.batteryCharging,
    iconColor: AppColors.accent,
    tint: AppColors.tintGreen,
    route: AppRoutes.batteryManager,
  ),
  // CleanupAction(
  //   title: 'AI Cleanup',
  //   metricKey: HomeDashboardController.aiCleanupKey,
  //   icon: LucideIcons.sparkles,
  //   iconColor: AppColors.iconPurple,
  //   tint: AppColors.tintPurple,
  //   route: AppRoutes.initialScan,
  // ),
];
