import 'package:flutter/material.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/photo_compressor/photo_compressor_controller.dart';

/// Row of compression-quality chips (one per [CompressionQuality]).
class QualityRow extends StatelessWidget {
  const QualityRow({super.key, required this.controller});

  final PhotoCompressorController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final quality in CompressionQuality.values) ...[
          Expanded(
            child: _QualityChip(
              quality: quality,
              selected: controller.quality == quality,
              onTap: () => controller.setQuality(quality),
            ),
          ),
          if (quality != CompressionQuality.values.last)
            const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class _QualityChip extends StatelessWidget {
  const _QualityChip({
    required this.quality,
    required this.selected,
    required this.onTap,
  });

  final CompressionQuality quality;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          color: selected
              ? (AppColors.isLight(context)
                    ? const Color(0xFFE6F5F2)
                    : const Color(0xFF092A31))
              : AppColors.surface(context),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.borderFor(context),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  quality.title,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              quality.label,
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 9,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
