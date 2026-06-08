import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/sift_top_app_bar.dart';
import 'package:sift/app/initial_scan/initial_scan_controller.dart';
import 'package:sift/app/routes/app_routes.dart';

class InitialScanView extends StatelessWidget {
  const InitialScanView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InitialScanController>(
      builder: (controller) {
        final accent = AppColors.isLight(context)
            ? const Color(0xFF0E8F80)
            : const Color(0xFF18D0B8);
        return Scaffold(
          backgroundColor: AppColors.pageBackground(context),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 8, 28, 8),
                  child: Column(
                    children: [
                      // const _TopHandle(),
                      const SiftTopAppBar(title: ''),
                      const Spacer(flex: 2),
                      _ScanOrb(controller: controller),
                      const SizedBox(height: 38),
                      Text(
                        'ON-DEVICE SCAN',
                        style: TextStyle(
                          color: accent,
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.4,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        controller.isComplete
                            ? 'Your library is ready'
                            : controller.isScanning
                            ? 'Scanning your library'
                            : 'Scan your library',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textPrimary(context),
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        controller.errorMessage ??
                            (controller.isComplete
                                ? '${controller.photoCount} photos, ${controller.videoCount} videos, ${controller.albumCount} albums scanned.'
                                : controller.isScanning
                                ? 'Analyzing your library...'
                                : 'Tap the scanner to begin on-device cleanup.'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textMuted(context),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(flex: 3),
                      _ProgressFooter(controller: controller),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// class _TopHandle extends StatelessWidget {
//   const _TopHandle();

//   @override
//   Widget build(BuildContext context) {
//     // return Container(
//     //   width: 54,
//     //   height: 4,
//     //   decoration: BoxDecoration(
//     //     color: AppColors.borderFor(context),
//     //     borderRadius: BorderRadius.circular(999),
//     //   ),
//     // );
//   }
// }

class _ScanOrb extends StatefulWidget {
  const _ScanOrb({required this.controller});

  final InitialScanController controller;

  @override
  State<_ScanOrb> createState() => _ScanOrbState();
}

class _ScanOrbState extends State<_ScanOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation;

  @override
  void initState() {
    super.initState();
    _animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.controller.startScan,
      child: SizedBox(
        width: 168,
        height: 168,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              painter: _ScanOrbPainter(
                tick: _animation.value,
                progress: widget.controller.progress,
                active: widget.controller.isScanning,
                complete: widget.controller.isComplete,
              ),
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF18D0B8),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF18D0B8).withValues(alpha: 0.35),
                        blurRadius: widget.controller.isScanning ? 34 : 18,
                        spreadRadius: widget.controller.isScanning ? 8 : 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.controller.isComplete
                        ? LucideIcons.check
                        : LucideIcons.droplet,
                    color: const Color(0xFF0B4450),
                    size: 26,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ScanOrbPainter extends CustomPainter {
  const _ScanOrbPainter({
    required this.tick,
    required this.progress,
    required this.active,
    required this.complete,
  });

  final double tick;
  final double progress;
  final bool active;
  final bool complete;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final pulse = active ? math.sin(tick * math.pi * 2) : 0.0;
    final outerRadius = 70.0 + pulse * 4;
    final middleRadius = 53.0;
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = const Color(0xFF18D0B8).withValues(alpha: 0.22);
    final glowPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF18D0B8).withValues(alpha: 0.08);
    final dashPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF18D0B8).withValues(alpha: 0.5);
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = complete ? const Color(0xFF5CFFB0) : const Color(0xFF18D0B8);

    canvas.drawCircle(center, middleRadius + 16, glowPaint);
    canvas.drawCircle(center, middleRadius, ringPaint);
    canvas.drawCircle(center, 40, ringPaint);

    const dashCount = 28;
    for (var i = 0; i < dashCount; i++) {
      final start = (i / dashCount) * math.pi * 2 + tick * math.pi * 2;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: outerRadius),
        start,
        0.055,
        false,
        dashPaint,
      );
    }

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: middleRadius),
        -math.pi / 2,
        math.pi * 2 * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ScanOrbPainter oldDelegate) {
    return oldDelegate.tick != tick ||
        oldDelegate.progress != progress ||
        oldDelegate.active != active ||
        oldDelegate.complete != complete;
  }
}

class _ProgressFooter extends StatelessWidget {
  const _ProgressFooter({required this.controller});

  final InitialScanController controller;

  @override
  Widget build(BuildContext context) {
    final percent = (controller.progress * 100).round().clamp(0, 100);

    return Column(
      children: [
        Row(
          children: [
            Text(
              controller.isComplete ? 'Complete' : controller.status,
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            Text(
              '$percent%',
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: controller.progress,
            minHeight: 4,
            backgroundColor: AppColors.isLight(context)
                ? AppColors.lightBorder
                : const Color(0xFF222B3C),
            valueColor: const AlwaysStoppedAnimation(Color(0xFF18D0B8)),
          ),
        ),
        const SizedBox(height: 18),
        TextButton(
          onPressed: controller.isComplete
              ? () => Get.toNamed(AppRoutes.aiCategories)
              : () => Get.back(),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textFaint(context),
            textStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
          child: Text(controller.isComplete ? '' : 'Skip and clean later'),
        ),
      ],
    );
  }
}
