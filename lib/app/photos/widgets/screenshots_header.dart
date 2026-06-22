import 'package:flutter/material.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/photos/photos_controller.dart';
import 'package:sift/core/utils/formatters.dart';

/// Teal storage card at the top of the Screenshots screen — total GB, count,
/// share of device storage and an Other-vs-Screenshots usage bar.
class ScreenshotsHeader extends StatelessWidget {
  const ScreenshotsHeader({super.key, required this.controller});

  final SimilarPhotosController controller;

  @override
  Widget build(BuildContext context) {
    final bytes = controller.screenshotsBytes;
    final used = controller.deviceUsedBytes;
    final fraction = controller.screenshotsStorageFraction;
    final percentLabel = used <= 0
        ? null
        : (fraction * 100 < 1 ? '<1%' : '${(fraction * 100).round()}%');

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.accentGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentDeep.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SCREENSHOTS STORAGE',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      bytes > 0 ? formatBytes(bytes) : '—',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        height: 1,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${formatThousands(controller.totalCount)} screenshots',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (percentLabel != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        '$percentLabel of storage',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'of ${formatBytes(used)} total used',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Other vs Screenshots usage bar.
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: Row(
              children: [
                Expanded(
                  flex: ((1 - fraction) * 1000).round().clamp(1, 1000),
                  child: Container(
                    height: 7,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                Expanded(
                  flex: (fraction * 1000).round().clamp(0, 1000) == 0
                      ? 1
                      : (fraction * 1000).round(),
                  child: Container(height: 7, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _ScreenshotLegendDot(
                color: Colors.white.withValues(alpha: 0.45),
                label: 'Other',
              ),
              const SizedBox(width: 16),
              _ScreenshotLegendDot(color: Colors.white, label: 'Screenshots'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScreenshotLegendDot extends StatelessWidget {
  const _ScreenshotLegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
