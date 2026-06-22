import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/ai_categories/ai_categories_controller.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/loading_shimmer.dart';

/// Scan-in-progress state with a shimmer icon, progress bar and a scanned-count
/// readout.
class CategoriesLoadingState extends StatelessWidget {
  const CategoriesLoadingState({super.key, required this.controller});

  final AiCategoriesController controller;

  @override
  Widget build(BuildContext context) {
    final percent = controller.progressPercent;
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const LoadingShimmer(
            child: Icon(
              LucideIcons.sparkles,
              color: AppColors.accent,
              size: 42,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Detecting photo categories',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.totalToScan == 0
                ? 'Preparing your library...'
                : '${controller.scannedCount} of ${controller.totalToScan} photos scanned',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted(context),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: controller.totalToScan == 0 ? null : controller.progress,
              minHeight: 5,
              backgroundColor: AppColors.surfaceTint(context),
              valueColor: const AlwaysStoppedAnimation(AppColors.accent),
            ),
          ),
          if (controller.totalToScan > 0) ...[
            const SizedBox(height: 8),
            Text(
              '$percent%',
              style: const TextStyle(
                color: AppColors.accent,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
