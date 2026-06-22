import 'package:flutter/material.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/photo_compressor/photo_compressor_controller.dart';
import 'package:sift/core/utils/formatters.dart';

/// Panel showing the estimated bytes saved across the current selection.
class SavingsPanel extends StatelessWidget {
  const SavingsPanel({super.key, required this.controller});

  final PhotoCompressorController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Row(
        children: [
          Text(
            'Estimated savings',
            style: TextStyle(
              color: AppColors.textMuted(context),
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          Text(
            formatBytes(controller.estimatedSavings),
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            'from ${controller.selectedCount} selected',
            style: TextStyle(
              color: AppColors.textMuted(context),
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
