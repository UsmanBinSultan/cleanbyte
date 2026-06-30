import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/large_files/large_files_controller.dart';

/// Storage summary card — a teal usage donut on the left and a
/// Used / Available legend on the right, mirroring the Figma design. Driven by
/// real device stats from [LargeFilesController].
class StorageDonutCard extends StatelessWidget {
  const StorageDonutCard({super.key, required this.controller});

  final LargeFilesController controller;

  @override
  Widget build(BuildContext context) {
    final fraction = controller.storageUsedFraction.clamp(0.0, 1.0);
    final usedGb = _formatGb(controller.storageUsedBytes);
    final freeGb = _formatGb(controller.storageFreeBytes);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderFor(context)),
        boxShadow: AppColors.isLight(context)
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 84,
                height: 84,
                child: CustomPaint(
                  painter: _StorageRingPainter(
                    progress: fraction,
                    track: AppColors.borderFor(context),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Used',
                          style: TextStyle(
                            color: AppColors.textMuted(context),
                            fontSize: 10,
                            height: 1,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          usedGb,
                          style: TextStyle(
                            color: AppColors.textPrimary(context),
                            fontSize: 15,
                            height: 1,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  children: [
                    _StorageLegendRow(
                      color: AppColors.accent,
                      label: 'Used',
                      value: '$usedGb GB',
                      labelColor: AppColors.textPrimary(context),
                      valueColor: AppColors.textPrimary(context),
                    ),
                    const SizedBox(height: 12),
                    _StorageLegendRow(
                      color: AppColors.borderFor(context),
                      label: 'Available',
                      value: '$freeGb GB',
                      labelColor: AppColors.textMuted(context),
                      valueColor: AppColors.textMuted(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: AppColors.borderFor(context)),
          const SizedBox(height: 12),
          Align(
            // Directional so the caption aligns to the leading edge in RTL.
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              'Clean Byte-managed storage',
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StorageLegendRow extends StatelessWidget {
  const _StorageLegendRow({
    required this.color,
    required this.label,
    required this.value,
    required this.labelColor,
    required this.valueColor,
  });

  final Color color;
  final String label;
  final String value;
  final Color labelColor;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _StorageRingPainter extends CustomPainter {
  const _StorageRingPainter({required this.progress, required this.track});

  final double progress;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final base = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;
    final fill = Paint()
      ..shader = AppColors.accentGradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, base);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress.clamp(0, 1),
      false,
      fill,
    );
  }

  @override
  bool shouldRepaint(covariant _StorageRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.track != track;
}

/// Formats bytes as a GB number (no unit suffix), e.g. 189.4.
String _formatGb(int bytes) {
  if (bytes <= 0) {
    return '0';
  }
  const gb = 1000 * 1000 * 1000;
  return (bytes / gb).toStringAsFixed(1);
}
