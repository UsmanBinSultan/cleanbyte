import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/initial_scan/initial_scan_controller.dart';
import 'package:sift/app/routes/app_routes.dart';

/// Bottom action row: a primary "Review Results" button and a "Scan Again"
/// secondary button.
class ScanActions extends StatelessWidget {
  const ScanActions({super.key, required this.controller});

  final InitialScanController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              gradient: AppColors.accentGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.28),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: TextButton.icon(
              onPressed: () => Get.toNamed(AppRoutes.reviewDelete),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              icon: const Text('Review Results'),
              label: const Icon(LucideIcons.arrowRight, size: 16),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 50,
            child: TextButton.icon(
              onPressed: controller.isScanning ? null : controller.startScan,
              style: TextButton.styleFrom(
                backgroundColor: AppColors.surface(context),
                foregroundColor: AppColors.textPrimary(context),
                side: BorderSide(color: AppColors.borderFor(context)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              icon: const Icon(LucideIcons.refreshCw, size: 14),
              label: const Text('Scan Again'),
            ),
          ),
        ),
      ],
    );
  }
}
