import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/centered_state_view.dart';
import 'package:sift/app/photos/photos_controller.dart';

/// Shown when access is granted but no media of the current mode was found.
class MediaEmptyState extends StatelessWidget {
  const MediaEmptyState({super.key, required this.controller});

  final SimilarPhotosController controller;

  @override
  Widget build(BuildContext context) {
    return CenteredStateView(
      icon: controller.mode.isVideos
          ? LucideIcons.video
          : controller.mode.isScreenshots
          ? LucideIcons.camera
          : controller.mode.isDuplicates
          ? LucideIcons.copy
          : controller.mode.isInvisible
          ? LucideIcons.eyeOff
          : controller.mode.isBlurred
          ? LucideIcons.focus
          : controller.mode.isLargeFiles
          ? LucideIcons.file
          : LucideIcons.image,
      title: controller.mode.emptyTitle,
      body: controller.mode.emptyBody,
      primaryLabel: 'Refresh',
      onPrimary: controller.loadAssets,
    );
  }
}
