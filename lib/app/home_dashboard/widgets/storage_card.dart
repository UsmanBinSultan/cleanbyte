import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/home_dashboard/home_dashboard_controller.dart';
import 'package:sift/app/routes/app_routes.dart';

/// Teal gradient storage card: a usage ring, used/total/free figures and the
/// "Start Smart Scan" entry point.
class StorageCard extends StatelessWidget {
  const StorageCard({super.key, required this.controller});

  final HomeDashboardController controller;

  @override
  Widget build(BuildContext context) {
    final storage = controller.storage;
    final hasData = storage.totalBytes > 0;
    final percent = (storage.usedFraction * 100).round();
    final usedText = _formatStorageBytes(storage.usedBytes);
    final totalText = _formatStorageBytes(storage.totalBytes);
    final freeText = _formatStorageBytes(storage.freeBytes);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.accentGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentDeep.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 66,
                height: 66,
                child: CustomPaint(
                  painter: _UsageRingPainter(
                    progress: hasData ? storage.usedFraction : 0,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          hasData ? '$percent%' : '--',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            height: 1,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Text(
                          'used',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasData ? usedText : 'Calculating…',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        height: 1.1,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (hasData)
                      Text(
                        'of $totalText used',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    const SizedBox(height: 8),
                    if (hasData)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$freeText available',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  controller.isLoadingSummary
                      ? 'Scanning your storage…'
                      : 'Tap to run a smart scan',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              _StartScanButton(controller: controller),
            ],
          ),
        ],
      ),
    );
  }
}

class _StartScanButton extends StatelessWidget {
  const _StartScanButton({required this.controller});

  final HomeDashboardController controller;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(99),
      child: InkWell(
        borderRadius: BorderRadius.circular(99),
        onTap: () async {
          await Get.toNamed(AppRoutes.initialScan);
          await controller.refreshSummary();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                LucideIcons.search,
                size: 14,
                color: AppColors.accentDeep,
              ),
              const SizedBox(width: 6),
              Text(
                'Start Smart Scan',
                style: TextStyle(
                  color: AppColors.accentDeep,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UsageRingPainter extends CustomPainter {
  const _UsageRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final base = Paint()
      ..color = Colors.white.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final fill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, base);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      (math.pi * 2 * progress.clamp(0, 1)).toDouble(),
      false,
      fill,
    );
  }

  @override
  bool shouldRepaint(covariant _UsageRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

String _formatStorageBytes(num bytes) {
  if (bytes <= 0) {
    return '0 GB';
  }
  const kb = 1000;
  const mb = kb * 1000;
  const gb = mb * 1000;
  if (bytes >= gb) {
    final value = bytes / gb;
    return '${value >= 10 ? value.toStringAsFixed(0) : value.toStringAsFixed(1)} GB';
  }
  if (bytes >= mb) {
    final value = bytes / mb;
    return '${value >= 10 ? value.toStringAsFixed(0) : value.toStringAsFixed(1)} MB';
  }
  return '${(bytes / kb).toStringAsFixed(1)} KB';
}
