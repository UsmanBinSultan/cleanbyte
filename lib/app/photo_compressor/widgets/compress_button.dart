import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/photo_compressor/photo_compressor_controller.dart';

/// Sticky bottom bar that compresses the current selection and reports the
/// result via a snackbar.
class CompressButton extends StatelessWidget {
  const CompressButton({super.key, required this.controller});

  final PhotoCompressorController controller;

  @override
  Widget build(BuildContext context) {
    final enabled = controller.selectedCount > 0 && !controller.isCompressing;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: BoxDecoration(
        color: AppColors.bottomBar(context),
        border: Border(top: BorderSide(color: AppColors.borderFor(context))),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: TextButton.icon(
          onPressed: enabled ? () => _compress(controller) : null,
          icon: controller.isCompressing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(LucideIcons.minimize2, size: 18),
          label: Text(
            controller.isCompressing
                ? 'Compressing...'
                : 'Compress selected (${controller.selectedCount} photos)',
          ),
          style: TextButton.styleFrom(
            disabledBackgroundColor: AppColors.surfaceTint(context),
            disabledForegroundColor: AppColors.textFaint(context),
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _compress(PhotoCompressorController controller) async {
    final count = await controller.compressSelected();
    Get.snackbar(
      count == 0 ? 'Nothing compressed' : 'Compressed $count photos',
      count == 0
          ? controller.errorMessage ?? 'No photos were processed.'
          : 'Smaller JPEG copies were saved to your gallery.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF111929),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }
}
