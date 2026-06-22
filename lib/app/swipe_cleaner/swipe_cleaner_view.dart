import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:get/get.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/swipe_cleaner/swipe_cleaner_controller.dart';
import 'package:sift/app/swipe_cleaner/widgets/swipe_area.dart';
import 'package:sift/app/swipe_cleaner/widgets/swipe_complete_state.dart';
import 'package:sift/app/swipe_cleaner/widgets/swipe_empty_state.dart';
import 'package:sift/app/swipe_cleaner/widgets/swipe_top_bar.dart';

/// Swipe Cleaner: review the photo library card-by-card, keeping favourites and
/// marking clutter for deletion. Sub-widgets live under `widgets/`.
class SwipeCleanerView extends StatelessWidget {
  const SwipeCleanerView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SwipeCleanerController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.pageBackground(context),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  children: [
                    SwipeTopBar(controller: controller),
                    Expanded(child: _Body(controller: controller)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Routes to the correct body for the current state (loading / no-access /
/// empty / complete / the interactive swipe deck).
class _Body extends StatelessWidget {
  const _Body({required this.controller});

  final SwipeCleanerController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }
    if (!controller.hasAccess) {
      return SwipeEmptyState(
        icon: LucideIcons.lock,
        title: 'Photo access needed',
        body: 'Allow photo access so Swipe Cleaner can show your library.',
        actionLabel: 'Open Settings',
        onAction: controller.openSettings,
      );
    }
    if (controller.total == 0) {
      return SwipeEmptyState(
        icon: LucideIcons.imageOff,
        title: 'No photos to review',
        body: 'Photos from your library will appear here to swipe through.',
        actionLabel: 'Refresh',
        onAction: controller.load,
      );
    }
    if (controller.isComplete) {
      return SwipeCompleteState(controller: controller);
    }
    return SwipeArea(controller: controller);
  }
}
