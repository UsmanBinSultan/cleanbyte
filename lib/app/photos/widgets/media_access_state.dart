import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/centered_state_view.dart';
import 'package:sift/app/photos/photos_controller.dart';

/// Shown when photo-library access has not been granted.
class MediaAccessState extends StatelessWidget {
  const MediaAccessState({super.key, required this.controller});

  final SimilarPhotosController controller;

  @override
  Widget build(BuildContext context) {
    return CenteredStateView(
      icon: LucideIcons.image,
      title: 'Photo access needed'.tr,
      body: 'Allow access to show your ${controller.mode.mediaName} here.'.tr,
      primaryLabel: 'Open Settings',
      onPrimary: controller.openSettings,
      secondaryLabel: 'Try Again',
      onSecondary: controller.loadAssets,
    );
  }
}
