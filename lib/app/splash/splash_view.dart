import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/splash/splash_controller.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  /// Soft radial glow behind the logo. Dark mode keeps the original teal tones;
  /// light mode uses a faint accent tint so it reads on the light background.
  List<Color> _glowColors(BuildContext context) {
    if (AppColors.isLight(context)) {
      return [
        AppColors.accent.withValues(alpha: 0.16),
        AppColors.accent.withValues(alpha: 0.06),
        Colors.transparent,
      ];
    }
    return const [Color(0xFF0C2832), Color(0x8A0C2832), Colors.transparent];
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(
      autoRemove: false,
      builder: (controller) => Scaffold(
        backgroundColor: AppColors.pageBackground(context),
        body: Stack(
          children: [
            Align(
              alignment: const Alignment(0, -0.35),
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: _glowColors(context),
                    stops: const [0, 0.5, 1],
                  ),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _LogoBadge(),
                  const SizedBox(height: 26),
                  Text(
                    'Clean Byte',
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontSize: 27,
                      height: 1,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Clean storage. Keep memories.',
                    style: TextStyle(
                      color: AppColors.textMuted(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: const Alignment(0, 0.86),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Preparing your space…',
                    style: TextStyle(
                      color: AppColors.textMuted(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The app logo inside a white circle wrapped by a teal accent ring that
/// animates from empty to full on a loop, like a progress fill.
class _LogoBadge extends StatefulWidget {
  const _LogoBadge();

  @override
  State<_LogoBadge> createState() => _LogoBadgeState();
}

class _LogoBadgeState extends State<_LogoBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      height: 112,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => CustomPaint(
              size: const Size.square(112),
              painter: _RingPainter(
                progress: Curves.easeInOut.transform(_controller.value),
              ),
            ),
          ),
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.all(18),
            // Shown at ~48 logical px; decode small instead of at the source
            // 1024² (which would cost ~4 MB as a bitmap for a tiny icon).
            child: Image.asset(
              'assets/icons/cleaner.png',
              fit: BoxFit.contain,
              cacheWidth: 192,
              cacheHeight: 192,
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final base = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final arc = Paint()
      ..shader = const SweepGradient(
        colors: [AppColors.accent, AppColors.accentDeep, AppColors.accent],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, base);
    // Sweep the accent arc from empty to full as the animation progresses.
    canvas.drawArc(
      rect,
      -math.pi / 2,
      (math.pi * 2 * progress).clamp(0.0001, math.pi * 2),
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
