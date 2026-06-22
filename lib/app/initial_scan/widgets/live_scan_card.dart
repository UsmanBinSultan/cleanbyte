import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/initial_scan/initial_scan_controller.dart';

/// The main live-scan card: a progress ring, a percent + status readout, two
/// mini stats and a staged progress stepper.
class LiveScanCard extends StatelessWidget {
  const LiveScanCard({super.key, required this.controller});

  final InitialScanController controller;

  static const _stages = [
    'Scan Start',
    'Analyzing',
    'Categorizing',
    'Reviewing',
    'Complete',
  ];

  @override
  Widget build(BuildContext context) {
    final percent = (controller.progress * 100).round().clamp(0, 100);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                controller.isComplete ? 'Scan complete' : 'Live Scan',
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 116,
                height: 116,
                child: CustomPaint(
                  painter: _ScanRingPainter(progress: controller.progress),
                  child: Center(
                    child: Icon(
                      controller.isComplete
                          ? LucideIcons.check
                          : LucideIcons.image,
                      color: AppColors.accent,
                      size: 26,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$percent',
                          style: TextStyle(
                            color: AppColors.textPrimary(context),
                            fontSize: 40,
                            height: 1,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 6, left: 1),
                          child: Text(
                            '%',
                            style: TextStyle(
                              color: AppColors.textMuted(context),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      controller.isComplete ? 'All done' : controller.status,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _MiniStat(
                      icon: LucideIcons.layoutGrid,
                      color: AppColors.iconPurple,
                      value:
                          '${controller.photoCount + controller.videoCount} items',
                      label: 'Being scanned',
                    ),
                    const SizedBox(height: 8),
                    _MiniStat(
                      icon: LucideIcons.clock,
                      color: AppColors.accent,
                      value: controller.isComplete
                          ? 'Done'
                          : '~${controller.estimatedSecondsLeft}s left',
                      label: 'Estimated time',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _Stepper(stages: _stages, stageIndex: controller.stageIndex),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: AppColors.iconChipBg(
              context,
              color,
              color.withValues(alpha: 0.14),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 13, color: color),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.stages, required this.stageIndex});

  final List<String> stages;
  final int stageIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < stages.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Container(
                height: 2,
                color: i <= stageIndex
                    ? AppColors.accent
                    : AppColors.borderFor(context),
              ),
            ),
          Column(
            children: [
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: i < stageIndex
                      ? AppColors.accent
                      : i == stageIndex
                      ? AppColors.iconChipBg(
                          context,
                          AppColors.accent,
                          AppColors.tintTeal,
                        )
                      : AppColors.surfaceTint(context),
                  shape: BoxShape.circle,
                  border: i == stageIndex
                      ? Border.all(color: AppColors.accent, width: 1.5)
                      : null,
                ),
                child: i < stageIndex
                    ? const Icon(
                        LucideIcons.check,
                        size: 12,
                        color: Colors.white,
                      )
                    : Text(
                        '${i + 1}',
                        style: TextStyle(
                          color: i == stageIndex
                              ? AppColors.accent
                              : AppColors.textFaint(context),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ScanRingPainter extends CustomPainter {
  const _ScanRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: size.width / 2 - 7);
    final base = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;
    final fill = Paint()
      ..shader = const SweepGradient(
        colors: [AppColors.accent, AppColors.accentDeep, AppColors.accent],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, size.width / 2 - 7, base);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress.clamp(0, 1),
      false,
      fill,
    );
  }

  @override
  bool shouldRepaint(covariant _ScanRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
