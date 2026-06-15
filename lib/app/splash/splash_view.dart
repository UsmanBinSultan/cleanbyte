import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/splash/splash_controller.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _dotsController;

  @override
  void initState() {
    super.initState();
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _dotsController.dispose();
    super.dispose();
  }

  /// Soft radial glow behind the logo. Dark mode keeps the original teal tones;
  /// light mode uses a faint accent tint so it reads on the cream background.
  List<Color> _glowColors(BuildContext context) {
    if (AppColors.isLight(context)) {
      return [
        AppColors.accent.withValues(alpha: 0.16),
        AppColors.accent.withValues(alpha: 0.07),
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
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.pageBackground(context),
          elevation: 0,
        ),
        body: Stack(
          children: [
            Center(
              child: Container(
                width: 230,
                height: 230,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: _glowColors(context),
                    stops: const [0, 0.48, 1],
                  ),
                ),
              ),
            ),
            Center(
              child: Transform.translate(
                offset: const Offset(0, -18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/icons/cleaner.png',
                      width: 80,
                      fit: BoxFit.contain,
                      // color: Colors.transparent,
                      // backgroundColor: Colors.transparent,
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Clean Byte',
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 27,
                        height: 1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 17),
                    Text(
                      'The honest phone cleaner.',
                      style: TextStyle(
                        color: AppColors.textMuted(context),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: const Alignment(0, 0.88),
              child: _SplashDots(animation: _dotsController),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashDots extends StatelessWidget {
  const _SplashDots({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final activeIndex = (animation.value * 3).floor().clamp(0, 2);
        final dotColor = AppColors.textPrimary(context);

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final active = index == activeIndex;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 4,
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: dotColor.withValues(alpha: active ? 0.9 : 0.2),
                shape: BoxShape.circle,
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: dotColor.withValues(alpha: 0.45),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
            );
          }),
        );
      },
    );
  }
}
