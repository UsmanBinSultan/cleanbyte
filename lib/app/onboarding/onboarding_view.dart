import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/onboarding/onboarding_controller.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OnboardingController>(
      autoRemove: false,
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.pageBackground(context),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: PageView(
                  controller: controller.pageController,
                  onPageChanged: controller.onPageChanged,
                  children: [
                    _WeLookPage(controller: controller),
                    _FindSpacePage(controller: controller),
                    _PrivacyPage(controller: controller),
                    _PermissionsPage(controller: controller),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ===========================================================================
// Shared chrome
// ===========================================================================
class _TopBar extends StatelessWidget {
  const _TopBar({required this.onSkip});

  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: Row(
        children: [
          const Spacer(),
          TextButton(
            onPressed: onSkip,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(40, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Skip',
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RichTitle extends StatelessWidget {
  const _RichTitle({required this.title, required this.highlight});

  final String title;
  final String highlight;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: title),
          TextSpan(
            text: highlight,
            style: const TextStyle(color: AppColors.accent),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      style: TextStyle(
        color: AppColors.textPrimary(context),
        fontSize: 26,
        height: 1.2,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
    );
  }
}

class _Subtitle extends StatelessWidget {
  const _Subtitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: AppColors.textMuted(context),
        fontSize: 15,
        height: 1.55,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.active});

  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(OnboardingController.pageCount, (index) {
        final on = index == active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: on ? 22 : 7,
          height: 7,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: on ? AppColors.accent : AppColors.borderFor(context),
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.onTap,
    this.icon,
    this.leadingIcon,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final IconData? leadingIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        gradient: AppColors.accentGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leadingIcon != null) ...[
              Icon(leadingIcon, size: 18),
              const SizedBox(width: 8),
            ],
            Text(label),
            if (icon != null) ...[
              const SizedBox(width: 6),
              Icon(icon, size: 18),
            ],
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// Page 0 — We only look, never delete
// ===========================================================================
class _WeLookPage extends StatelessWidget {
  const _WeLookPage({required this.controller});

  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    final chips = [
      (LucideIcons.search, 'We inspect your\nlibrary'),
      (LucideIcons.image, 'We highlight what\nmatters'),
      (LucideIcons.shieldCheck, "You're always in\ncontrol"),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _TopBar(onSkip: controller.skip),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _PhotoGridArt(),
            ),
            const SizedBox(height: 0),
            const _RichTitle(
              title: 'We only look,\n',
              highlight: 'never delete.',
            ),
            const SizedBox(height: 14),
            const _Subtitle(
              'We scan your photos to find duplicates, blurred shots '
              'and similar images. Your photos stay safe.',
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderFor(context)),
                boxShadow: AppColors.isLight(context)
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  for (final chip in chips)
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.iconChipBg(
                                context,
                                AppColors.accent,
                                AppColors.tintTeal,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              chip.$1,
                              color: AppColors.accent,
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            chip.$2,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textPrimary(context),
                              fontSize: 10,
                              height: 1.2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _Dots(active: controller.currentPage),
            const SizedBox(height: 20),
            _GradientButton(
              label: 'Get Started',
              icon: LucideIcons.arrowRight,
              onTap: controller.next,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// The "We only look" hero: three slightly-tilted rows of real photos with
/// detection badges, plus a centred scan ring + sweep line — matching Figma.
class _PhotoGridArt extends StatelessWidget {
  const _PhotoGridArt();

  // Each tile is placed and tilted individually (photo, badge, angle, dy) so
  // the collage looks scattered like the Figma — not aligned rows.
  static const _rows = <List<(String, String?, double, double)>>[
    [
      ('photo1', null, -0.06, 6),
      ('photo2', null, 0.03, -8),
      ('photo3', null, -0.04, 8),
      ('photo4', null, 0.05, 2),
    ],
    [
      ('photo1', null, -0.05, 2),
      ('photo5', 'Similar', 0.0, -6),
      ('photo6', 'Similar', 0.015, -10),
      ('photo7', null, 0.05, 6),
    ],
    [
      ('photo8', null, -0.04, 4),
      ('photo9', 'Blur', 0.04, 12),
      ('photo10', null, -0.025, -2),
      ('photo11', 'Duplicate', 0.05, 2),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    const rowHeight = 110.0;
    // Middle row's vertical centre — the scan line + ring anchor here.
    const middle = 6 + rowHeight + 50;
    return SizedBox(
      // Tall enough to fully contain the bottom row (incl. its downward
      // stagger) so the photos never overlap the title beneath the grid.
      height: 352,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          for (var r = 0; r < _rows.length; r++)
            Positioned(
              top: 6 + r * rowHeight,
              left: 0,
              right: 0,
              child: _CollageRow(tiles: _rows[r]),
            ),
          // Horizontal scan sweep line across the middle.
          const Positioned(left: 0, right: 0, top: middle, child: _ScanLine()),
          // Scan ring + magnifier, centred on the middle row.
          const Positioned(
            top: middle - 105,
            left: 0,
            right: 0,
            child: Center(child: _ScanRing()),
          ),
        ],
      ),
    );
  }
}

class _CollageRow extends StatelessWidget {
  const _CollageRow({required this.tiles});

  /// (photo asset, optional badge, rotation radians, vertical offset) per card.
  final List<(String, String?, double, double)> tiles;

  @override
  Widget build(BuildContext context) {
    // Four equal-width cards that always fit the row, but each is tilted and
    // nudged vertically on its own so the collage looks scattered like Figma.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < tiles.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: Transform.translate(
              offset: Offset(0, tiles[i].$4),
              child: Transform.rotate(
                angle: tiles[i].$3,
                child: _CollageCard(
                  asset: 'assets/onboarding/${tiles[i].$1}.jpg',
                  badge: tiles[i].$2,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _CollageCard extends StatelessWidget {
  const _CollageCard({required this.asset, this.badge});

  final String asset;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final flagged = badge != null;
    return SizedBox(
      height: 100,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: flagged ? AppColors.accent : Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: flagged
                        ? AppColors.accent.withValues(alpha: 0.35)
                        : Colors.black.withValues(alpha: 0.08),
                    blurRadius: flagged ? 16 : 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(asset, fit: BoxFit.cover),
            ),
          ),
          if (flagged)
            Positioned(
              left: 0,
              right: 0,
              top: -6,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(99),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.45),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        badge!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(
                        LucideIcons.check,
                        size: 9,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ScanLine extends StatelessWidget {
  const _ScanLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withValues(alpha: 0),
            AppColors.accent,
            AppColors.accent,
            AppColors.accent.withValues(alpha: 0),
          ],
          stops: const [0, 0.28, 0.72, 1],
        ),
      ),
    );
  }
}

class _ScanRing extends StatelessWidget {
  const _ScanRing();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: 210,
        height: 210,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.45),
                  width: 2,
                ),
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent.withValues(alpha: 0.08),
                    AppColors.accent.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.25),
                    blurRadius: 14,
                  ),
                ],
              ),
              child: const Icon(
                LucideIcons.search,
                size: 20,
                color: AppColors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// Page 1 — Find what's taking up space
// ===========================================================================
class _FindSpacePage extends StatelessWidget {
  const _FindSpacePage({required this.controller});

  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        children: [
          _TopBar(onSkip: controller.skip),
          const Spacer(flex: 2),
          const _StorageMockup(),
          const Spacer(flex: 2),
          const _RichTitle(
            title: "Find what's taking up\n",
            highlight: 'space.',
          ),
          const SizedBox(height: 14),
          const _Subtitle(
            'Clean Byte scans your photos, videos, and files '
            'to help you safely free storage.',
          ),
          const Spacer(flex: 3),
          _Dots(active: controller.currentPage),
          const SizedBox(height: 20),
          _GradientButton(label: 'Next', onTap: controller.next),
        ],
      ),
    );
  }
}

class _StorageMockup extends StatelessWidget {
  const _StorageMockup();

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

// ===========================================================================
// Page 2 — Your photos stay private
// ===========================================================================
class _PrivacyPage extends StatelessWidget {
  const _PrivacyPage({required this.controller});

  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    final cards = [
      (
        LucideIcons.search,
        'Scan runs on your device',
        'No data ever leaves your phone. Everything is processed locally.',
        'On-device',
      ),
      (
        LucideIcons.cloudOff,
        'No uploads, ever',
        'Your photos and videos are never uploaded to any server.',
        'Zero uploads',
      ),
      (
        LucideIcons.shieldCheck,
        'You approve every deletion',
        'Nothing is removed without your explicit tap. You are always in control.',
        'You decide',
      ),
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        children: [
          _TopBar(onSkip: controller.skip),
          const SizedBox(height: 12),
          const _PrivacyMockup(),
          const SizedBox(height: 18),
          const _RichTitle(title: 'Your photos\n', highlight: 'stay private.'),
          const SizedBox(height: 12),
          const _Subtitle(
            'Clean Byte never sees your media. Everything happens '
            'on your device, with your permission.',
          ),
          const SizedBox(height: 20),
          for (final card in cards) ...[
            _PrivacyCard(
              icon: card.$1,
              title: card.$2,
              body: card.$3,
              tag: card.$4,
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 8),
          _Dots(active: controller.currentPage),
          const SizedBox(height: 20),
          _GradientButton(label: 'Next', onTap: controller.next),
        ],
      ),
    );
  }
}

class _PrivacyCard extends StatelessWidget {
  const _PrivacyCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.tag,
  });

  final IconData icon;
  final String title;
  final String body;
  final String tag;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderFor(context)),
        boxShadow: AppColors.isLight(context)
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.iconChipBg(
                context,
                AppColors.accent,
                AppColors.tintMint,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 17, color: AppColors.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: TextStyle(
                    color: AppColors.textMuted(context),
                    fontSize: 11.5,
                    height: 1.4,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.iconChipBg(
                context,
                AppColors.accent,
                AppColors.tintTeal,
              ),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              tag,
              style: const TextStyle(
                color: AppColors.accentDeep,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyMockup extends StatelessWidget {
  const _PrivacyMockup();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      width: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 132,
            height: 196,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 6,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 5,
                          crossAxisSpacing: 5,
                          childAspectRatio: 0.9,
                        ),
                    itemBuilder: (context, index) {
                      // Cells 1, 2 and 5 are "flagged" in the design (dimmed
                      // with a small marker).
                      const flagged = {1, 2, 5};
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              'assets/onboarding/priv${index + 1}.jpg',
                              fit: BoxFit.cover,
                            ),
                            if (flagged.contains(index))
                              ColoredBox(
                                color: const Color(
                                  0xFF0F172A,
                                ).withValues(alpha: 0.55),
                                child: const Center(
                                  child: Icon(
                                    LucideIcons.eyeOff,
                                    size: 11,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: AppColors.accent),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          LucideIcons.shield,
                          size: 11,
                          color: AppColors.accent,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Protected',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 2,
            child: _floatPill(LucideIcons.eyeOff, 'No tracking'),
          ),
          Positioned(
            bottom: 6,
            left: 0,
            child: _floatPill(LucideIcons.lock, 'Stays on device'),
          ),
        ],
      ),
    );
  }

  Widget _floatPill(IconData icon, String label) {
    return Builder(
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(99),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: AppColors.accent),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// Page 3 — One last step (permissions)
// ===========================================================================
class _PermissionsPage extends StatelessWidget {
  const _PermissionsPage({required this.controller});

  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const _PermissionsHeader(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                  child: Column(
                    children: [
                      _PermissionRow(
                        step: 1,
                        icon: LucideIcons.image,
                        iconColor: AppColors.accent,
                        tint: AppColors.tintTeal,
                        title: 'Photos & Videos',
                        tag: 'Required',
                        tagColor: AppColors.accentDeep,
                        body:
                            'Scan for duplicates, blurry shots & large videos. '
                            'Read-only — we never touch your library.',
                        granted: controller.photosGranted,
                        loading: controller.requestingPhotos,
                        onAllow: controller.requestPhotos,
                        onManage: controller.openSystemSettings,
                      ),
                      _PermissionRow(
                        step: 2,
                        icon: LucideIcons.folder,
                        iconColor: AppColors.iconBlue,
                        tint: AppColors.tintBlue,
                        title: 'Files & Downloads',
                        tag: 'Optional',
                        tagColor: AppColors.iconBlue,
                        body:
                            'Find large or unused downloaded files. '
                            'You always pick what gets removed.',
                        granted: controller.filesGranted,
                        loading: controller.requestingFiles,
                        onAllow: controller.requestFiles,
                        onManage: controller.openSystemSettings,
                      ),
                      _PermissionRow(
                        step: 3,
                        icon: LucideIcons.users,
                        iconColor: AppColors.iconPurple,
                        tint: AppColors.tintPurple,
                        title: 'Contacts',
                        tag: 'Optional',
                        tagColor: AppColors.iconPurple,
                        body:
                            'Detect duplicate or incomplete entries. '
                            'Nothing is sent to any server, 100% local.',
                        granted: controller.contactsGranted,
                        loading: controller.requestingContacts,
                        onAllow: controller.requestContacts,
                        onManage: controller.openSystemSettings,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
          child: Column(
            children: [
              TextButton(
                onPressed: controller.skip,
                child: Text(
                  'Or try Demo Mode without permissions',
                  style: TextStyle(
                    color: AppColors.textMuted(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              _GradientButton(
                label: 'Start My First Scan',
                leadingIcon: LucideIcons.search,
                onTap: controller.startFirstScan,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PermissionsHeader extends StatelessWidget {
  const _PermissionsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0B1220), Color(0xFF0F2A2E)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 6),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
              ),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.35),
                    width: 1,
                  ),
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.search,
                  color: AppColors.accent,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'One last step\n',
                  style: TextStyle(color: Colors.white),
                ),
                TextSpan(
                  text: 'before your scan',
                  style: TextStyle(color: AppColors.accent),
                ),
              ],
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              height: 1.25,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              _HeaderChip('On-device'),
              SizedBox(width: 8),
              _HeaderChip('No uploads'),
              SizedBox(width: 8),
              _HeaderChip('You decide'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.check, size: 11, color: AppColors.accent),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({
    required this.step,
    required this.icon,
    required this.iconColor,
    required this.tint,
    required this.title,
    required this.tag,
    required this.tagColor,
    required this.body,
    required this.granted,
    required this.loading,
    required this.onAllow,
    required this.onManage,
    this.isLast = false,
  });

  final int step;
  final IconData icon;
  final Color iconColor;
  final Color tint;
  final String title;
  final String tag;
  final Color tagColor;
  final String body;
  final bool granted;
  final bool loading;
  final VoidCallback onAllow;
  final VoidCallback onManage;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.iconChipBg(context, iconColor, tint),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$step',
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: AppColors.borderFor(context),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderFor(context)),
                  boxShadow: AppColors.isLight(context)
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
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
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.iconChipBg(
                              context,
                              iconColor,
                              tint,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(icon, color: iconColor, size: 19),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  title,
                                  style: TextStyle(
                                    color: AppColors.textPrimary(context),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: tagColor.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: Text(
                                  tag,
                                  style: TextStyle(
                                    color: tagColor,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      body,
                      style: TextStyle(
                        color: AppColors.textMuted(context),
                        fontSize: 11.5,
                        height: 1.4,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 38,
                      child: TextButton(
                        onPressed: loading
                            ? null
                            : (granted ? onManage : onAllow),
                        style: TextButton.styleFrom(
                          backgroundColor: granted
                              ? AppColors.iconChipBg(
                                  context,
                                  AppColors.accent,
                                  AppColors.tintTeal,
                                )
                              : tagColor.withValues(alpha: 0.12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (loading)
                              const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            else
                              Icon(
                                granted
                                    ? LucideIcons.settings2
                                    : LucideIcons.check,
                                size: 15,
                                color: granted
                                    ? AppColors.accentDeep
                                    : tagColor,
                              ),
                            const SizedBox(width: 6),
                            Text(
                              granted ? 'Allowed · Manage' : 'Allow Access',
                              style: TextStyle(
                                color: granted
                                    ? AppColors.accentDeep
                                    : tagColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
