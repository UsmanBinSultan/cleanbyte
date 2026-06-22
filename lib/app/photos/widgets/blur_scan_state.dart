import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/photos/photos_controller.dart';

/// Progress state shown while the on-device blur scan is still running.
class BlurScanState extends StatelessWidget {
  const BlurScanState({super.key, required this.controller});

  final SimilarPhotosController controller;

  @override
  Widget build(BuildContext context) {
    final progress = controller.blurScanTotal == 0
        ? 0.0
        : controller.blurScanDone / controller.blurScanTotal;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.focus, color: Color(0xFF18D0B8), size: 42),
            const SizedBox(height: 18),
            Text(
              'Scanning for blurred photos'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${controller.blurScanDone} of ${controller.blurScanTotal} scanned',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 7,
                color: const Color(0xFF18D0B8),
                backgroundColor: const Color(0xFF172231),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
