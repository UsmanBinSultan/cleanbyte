import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';

/// Decorative phone mockup with a storage usage ring and floating category
/// chips, shown on the "Find space" onboarding page.
class StorageMockup extends StatelessWidget {
  const StorageMockup({super.key});

  @override
  Widget build(BuildContext context) {
    Widget chip(IconData icon, String value, String label, Color color) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderFor(context)),
          boxShadow: AppColors.isLight(context)
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: AppColors.iconChipBg(context, color, AppColors.tintTeal),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 13, color: color),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.textMuted(context),
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 270,
      width: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Phone body
          Container(
            width: 130,
            height: 230,
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.borderFor(context), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 28,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
              child: Column(
                children: [
                  Container(
                    width: 34,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary(context),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: CustomPaint(
                      painter: _MiniRingPainter(progress: 0.74),
                      child: Center(
                        child: Text(
                          '74%',
                          style: TextStyle(
                            color: AppColors.textPrimary(context),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _legendRow(context, AppColors.accent, 'Photos'),
                  const SizedBox(height: 6),
                  _legendRow(context, AppColors.accentDeep, 'Videos'),
                  const SizedBox(height: 6),
                  _legendRow(context, AppColors.textFaint(context), 'Files'),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 18,
            child: chip(
              LucideIcons.image,
              '4.8 GB',
              'Photos',
              AppColors.accent,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 64,
            child: chip(
              LucideIcons.video,
              '9.2 GB',
              'Videos',
              AppColors.accentDeep,
            ),
          ),
          Positioned(
            left: 6,
            bottom: 14,
            child: chip(
              LucideIcons.folder,
              '3.0 GB',
              'Files',
              AppColors.iconBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendRow(BuildContext context, Color dot, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceTint(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 8,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniRingPainter extends CustomPainter {
  const _MiniRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: size.width / 2 - 4);
    final base = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final fill = Paint()
      ..shader = const SweepGradient(
        colors: [AppColors.accent, AppColors.accentDeep, AppColors.accent],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, base);
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * progress, false, fill);
  }

  @override
  bool shouldRepaint(covariant _MiniRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
