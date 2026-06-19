import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';

enum OnboardingArtType { library, privacy, permission }

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({
    super.key,
    required this.step,
    required this.title,
    required this.highlight,
    required this.body,
    required this.primaryLabel,
    required this.onPrimary,
    required this.artType,
    this.eyebrow,
    this.skipRoute,
    this.secondaryLabel,
    this.onSecondary,
    this.footer,
    this.linkLabel,
    this.onLink,
    this.artBadgeLabel,
    this.bullets = const [],
  });

  final int step;
  final String title;
  final String? highlight;
  final String body;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final OnboardingArtType artType;
  final String? eyebrow;
  final String? skipRoute;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final String? footer;
  final String? linkLabel;
  final VoidCallback? onLink;
  final String? artBadgeLabel;
  final List<OnboardingBullet> bullets;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.height < 760;
    final firstPage = step == 0;

    return Scaffold(
      backgroundColor: firstPage
          ? AppColors.mintBg
          : AppColors.pageBackground(context),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, compact ? 8 : 10, 20, 14),
              child: Column(
                children: [
                  _FakeStatusBar(skipRoute: skipRoute),
                  SizedBox(
                    height: firstPage
                        ? (compact ? 8 : 18)
                        : (compact ? 20 : 34),
                  ),
                  _OnboardingArt(type: artType, badgeLabel: artBadgeLabel),
                  SizedBox(height: firstPage ? 24 : (compact ? 22 : 38)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: firstPage
                          ? CrossAxisAlignment.center
                          : CrossAxisAlignment.start,
                      children: [
                        if (eyebrow != null) ...[
                          Text(
                            eyebrow!,
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 3.0,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        _OnboardingTitle(title: title, highlight: highlight),
                        SizedBox(height: firstPage ? 16 : 16),
                        if (body.isNotEmpty) ...[
                          Text(
                            body,
                            textAlign: firstPage
                                ? TextAlign.center
                                : TextAlign.start,
                            style: TextStyle(
                              color: AppColors.textMuted(context),
                              fontSize: firstPage ? 14 : 13,
                              height: firstPage ? 1.65 : 1.55,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        if (bullets.isNotEmpty) ...[
                          SizedBox(height: firstPage ? 24 : 18),
                          firstPage
                              ? _BulletCard(bullets: bullets)
                              : Column(
                                  children: [
                                    for (final bullet in bullets)
                                      _BulletRow(bullet: bullet),
                                  ],
                                ),
                        ],
                        if (linkLabel != null) ...[
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: onLink ?? () {},
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(10, 24),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              foregroundColor: AppColors.accent,
                            ),
                            icon: Text(
                              linkLabel!,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            label: const Icon(LucideIcons.arrowRight, size: 13),
                          ),
                        ],
                        const Spacer(),
                        _Dots(activeIndex: step),
                        SizedBox(height: compact ? 16 : 22),
                        _PrimaryButton(
                          label: primaryLabel,
                          onPressed: onPrimary,
                        ),
                        if (secondaryLabel != null) ...[
                          const SizedBox(height: 10),
                          _SecondaryButton(
                            label: secondaryLabel!,
                            onPressed: onSecondary ?? () => Get.back(),
                          ),
                        ],
                        if (footer != null) ...[
                          const SizedBox(height: 10),
                          Center(
                            child: Text(
                              footer!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textFaint(context),
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingBullet {
  const OnboardingBullet({required this.title, required this.subtitle});

  final String title;
  final String subtitle;
}

class _FakeStatusBar extends StatelessWidget {
  const _FakeStatusBar({this.skipRoute});

  final String? skipRoute;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: skipRoute == null
                ? const SizedBox(width: 40, height: 28)
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () => Get.offAllNamed(skipRoute!),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(40, 28),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'skip'.tr,
                          style: TextStyle(
                            color: AppColors.textFaint(context),
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingArt extends StatelessWidget {
  const _OnboardingArt({required this.type, this.badgeLabel});

  final OnboardingArtType type;
  final String? badgeLabel;

  @override
  Widget build(BuildContext context) {
    final isLight = AppColors.isLight(context);
    return SizedBox(
      width: double.infinity,
      height: type == OnboardingArtType.privacy
          ? 370
          : type == OnboardingArtType.permission
          ? 138
          : 174,
      child: CustomPaint(
        painter: switch (type) {
          OnboardingArtType.library => _LibraryArtPainter(
            badgeLabel: badgeLabel ?? '12,400+',
            isLight: isLight,
          ),
          OnboardingArtType.privacy => _PrivacyArtPainter(isLight: isLight),
          OnboardingArtType.permission => _PermissionArtPainter(
            isLight: isLight,
          ),
        },
      ),
    );
  }
}

/// Picks a theme-appropriate colour for the onboarding illustrations. The dark
/// values are the originals (so dark mode is unchanged); the light values are
/// tuned to read on the cream light background.
Color _artColor(bool isLight, Color light, Color dark) =>
    isLight ? light : dark;

class _OnboardingTitle extends StatelessWidget {
  const _OnboardingTitle({required this.title, required this.highlight});

  final String title;
  final String? highlight;

  @override
  Widget build(BuildContext context) {
    final highlightedCount = highlight == null
        ? null
        : RegExp(r'^\d[\d,]*').firstMatch(highlight!);
    final children = <TextSpan>[
      TextSpan(text: title),
      if (highlightedCount != null)
        TextSpan(
          text: '\n${highlightedCount.group(0)} ',
          style: TextStyle(color: AppColors.amber),
        ),
      if (highlightedCount != null)
        TextSpan(
          text: highlight!.substring(highlightedCount.end).trimLeft(),
          style: TextStyle(color: AppColors.textMuted(context)),
        ),
      if (highlight != null && highlightedCount == null)
        TextSpan(
          text: '\n$highlight',
          style: const TextStyle(color: AppColors.accent),
        ),
    ];

    return Text.rich(
      TextSpan(children: children),
      textAlign: TextAlign.center,
      style: TextStyle(
        color: AppColors.textPrimary(context),
        fontSize: 28,
        height: 1.18,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.7,
      ),
    );
  }
}

class _BulletCard extends StatelessWidget {
  const _BulletCard({required this.bullets});

  final List<OnboardingBullet> bullets;

  @override
  Widget build(BuildContext context) {
    final icons = [
      LucideIcons.search,
      LucideIcons.image,
      LucideIcons.shieldCheck,
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var i = 0; i < bullets.length; i++)
            Expanded(
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8FFF4),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icons[i], color: AppColors.accent, size: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    bullets[i].title.tr,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.lightFg,
                      fontSize: 10,
                      height: 1.1,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _BulletRow extends StatelessWidget {
  const _BulletRow({required this.bullet});

  final OnboardingBullet bullet;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.check,
              size: 12,
              color: Color(0xFF061019),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bullet.title.tr,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  bullet.subtitle.tr,
                  style: TextStyle(
                    color: AppColors.textMuted(context),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.activeIndex});

  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          final active = index == activeIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: active ? 24 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: active ? AppColors.accent : const Color(0xFFE2F0EE),
              borderRadius: BorderRadius.circular(999),
            ),
          );
        }),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

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
        onPressed: onPressed,
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
            Text(label),
            const SizedBox(width: 6),
            const Icon(LucideIcons.arrowRight, size: 18),
          ],
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 34,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: AppColors.surfaceTint(context),
          foregroundColor: AppColors.textPrimary(context),
          side: BorderSide(color: AppColors.borderFor(context)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
          textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
        ),
        child: Text(label),
      ),
    );
  }
}

class _LibraryArtPainter extends CustomPainter {
  const _LibraryArtPainter({required this.badgeLabel, required this.isLight});

  final String badgeLabel;
  final bool isLight;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 6);
    final card = Rect.fromCenter(
      center: center,
      width: size.width - 40,
      height: 172,
    );
    final border = Paint()
      ..color = const Color(0xFF1C6B73).withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final fill = Paint()
      ..color = _artColor(
        isLight,
        const Color(0xFFFFFFFF),
        const Color(0xFF0B2330).withValues(alpha: 0.42),
      );
    canvas.drawRRect(
      RRect.fromRectAndRadius(card, const Radius.circular(22)),
      fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(card, const Radius.circular(22)),
      border,
    );

    final stackPaint = Paint()
      ..color = _artColor(
        isLight,
        const Color(0xFFE7E0D5),
        const Color(0xFF152033).withValues(alpha: 0.72),
      );
    for (var i = 0; i < 5; i++) {
      final r = Rect.fromCenter(
        center: Offset(center.dx - 4 + i * 5, center.dy - 12 + i * 4),
        width: 86,
        height: 62,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(6)),
        stackPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(6)),
        Paint()
          ..color = _artColor(
            isLight,
            Colors.black.withValues(alpha: 0.05),
            Colors.white.withValues(alpha: 0.05),
          )
          ..style = PaintingStyle.stroke,
      );
    }

    final front = Rect.fromCenter(center: center, width: 88, height: 62);
    canvas.drawRRect(
      RRect.fromRectAndRadius(front, const Radius.circular(6)),
      Paint()
        ..color = _artColor(
          isLight,
          const Color(0xFFDAD2C5),
          const Color(0xFF1A2D3F),
        ),
    );
    final path = Path()
      ..moveTo(front.left + 12, front.bottom - 10)
      ..lineTo(front.left + 35, front.top + 30)
      ..lineTo(front.left + 50, front.bottom - 10)
      ..lineTo(front.left + 68, front.top + 20)
      ..lineTo(front.right - 8, front.bottom - 10)
      ..close();
    canvas.drawPath(
      path,
      Paint()..color = AppColors.accent.withValues(alpha: 0.74),
    );
    canvas.drawCircle(
      Offset(front.left + 23, front.top + 17),
      5,
      Paint()..color = AppColors.amber,
    );

    final pill = RRect.fromRectAndRadius(
      Rect.fromLTWH(front.right - 18, front.top - 18, 54, 18),
      const Radius.circular(12),
    );
    canvas.drawRRect(pill, Paint()..color = AppColors.accent);
    _drawText(
      canvas,
      badgeLabel,
      Offset(front.right + 9, front.top - 9),
      7,
      Colors.white,
      TextAlign.center,
    );
  }

  @override
  bool shouldRepaint(covariant _LibraryArtPainter oldDelegate) {
    return oldDelegate.badgeLabel != badgeLabel ||
        oldDelegate.isLight != isLight;
  }
}

class _PrivacyArtPainter extends CustomPainter {
  const _PrivacyArtPainter({required this.isLight});

  final bool isLight;

  @override
  void paint(Canvas canvas, Size size) {
    final cardPaints = [
      const LinearGradient(colors: [Color(0xFF60A5FA), Color(0xFF14B8A6)]),
      const LinearGradient(colors: [Color(0xFFFCA5A5), Color(0xFFF472B6)]),
      const LinearGradient(colors: [Color(0xFF38BDF8), Color(0xFF22C55E)]),
      const LinearGradient(colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)]),
      const LinearGradient(colors: [Color(0xFF67E8F9), Color(0xFF0EA5A4)]),
      const LinearGradient(colors: [Color(0xFF94A3B8), Color(0xFF22C55E)]),
      const LinearGradient(colors: [Color(0xFF2DD4BF), Color(0xFFFDE68A)]),
      const LinearGradient(colors: [Color(0xFF93C5FD), Color(0xFFF9A8D4)]),
      const LinearGradient(colors: [Color(0xFF4ADE80), Color(0xFFEAB308)]),
    ];
    final positions = [
      const Offset(8, 20),
      const Offset(112, 20),
      const Offset(216, 20),
      const Offset(320, 20),
      const Offset(-6, 140),
      const Offset(98, 140),
      const Offset(202, 140),
      const Offset(306, 140),
      const Offset(22, 260),
      const Offset(126, 260),
      const Offset(230, 260),
      const Offset(334, 260),
    ];

    final linePaint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.38)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final center = Offset(size.width / 2, 185);
    canvas.drawCircle(center, 115, linePaint);
    canvas.drawLine(Offset(0, 185), Offset(size.width, 185), linePaint);

    for (var i = 0; i < positions.length; i++) {
      final rect = Rect.fromLTWH(positions[i].dx, positions[i].dy, 88, 108);
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(28));
      canvas.save();
      canvas.rotate((i % 3 - 1) * 0.025);
      canvas.drawRRect(rrect, Paint()..color = Colors.white);
      canvas.drawRRect(
        rrect.deflate(2),
        Paint()..shader = cardPaints[i % cardPaints.length].createShader(rect),
      );
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      canvas.restore();
    }

    _drawBadge(canvas, 'Similar', const Offset(112, 140));
    _drawBadge(canvas, 'Similar', const Offset(216, 140));
    _drawBadge(canvas, 'Blur', const Offset(126, 260));
    _drawBadge(canvas, 'Duplicate', const Offset(334, 260));
  }

  @override
  bool shouldRepaint(covariant _PrivacyArtPainter oldDelegate) =>
      oldDelegate.isLight != isLight;
}

void _drawBadge(Canvas canvas, String label, Offset cardOffset) {
  final rect = Rect.fromLTWH(
    cardOffset.dx + 8,
    cardOffset.dy + 8,
    label.length > 5 ? 66 : 46,
    20,
  );
  final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(99));
  canvas.drawRRect(rrect, Paint()..color = AppColors.accent);
  _drawText(canvas, label, rect.center, 9, Colors.white, TextAlign.center);
}

class _PermissionArtPainter extends CustomPainter {
  const _PermissionArtPainter({required this.isLight});

  final bool isLight;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final panel = Rect.fromCenter(center: center, width: 150, height: 106);
    canvas.drawRRect(
      RRect.fromRectAndRadius(panel, const Radius.circular(12)),
      Paint()
        ..color = _artColor(
          isLight,
          const Color(0xFFFFFFFF),
          const Color(0xFF121D31),
        ),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(panel, const Radius.circular(12)),
      Paint()
        ..color = _artColor(
          isLight,
          const Color(0xFFD3C9BA),
          const Color(0xFF2B3850),
        )
        ..style = PaintingStyle.stroke,
    );

    final cells = [
      Rect.fromLTWH(panel.left + 12, panel.top + 14, 42, 38),
      Rect.fromLTWH(panel.left + 60, panel.top + 14, 42, 38),
      Rect.fromLTWH(panel.left + 108, panel.top + 14, 42, 38),
      Rect.fromLTWH(panel.left + 12, panel.top + 58, 42, 38),
      Rect.fromLTWH(panel.left + 60, panel.top + 58, 42, 38),
    ];
    for (final cell in cells) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(cell, const Radius.circular(4)),
        Paint()
          ..color = _artColor(
            isLight,
            const Color(0xFFEDE6DB),
            const Color(0xFF1D293D),
          ),
      );
      final mountain = Path()
        ..moveTo(cell.left + 7, cell.bottom - 8)
        ..lineTo(cell.left + 18, cell.top + 22)
        ..lineTo(cell.left + 28, cell.bottom - 8)
        ..lineTo(cell.right - 6, cell.top + 14)
        ..lineTo(cell.right - 3, cell.bottom - 8)
        ..close();
      canvas.drawPath(
        mountain,
        Paint()
          ..color = _artColor(
            isLight,
            const Color(0xFFBFC5CF),
            const Color(0xFF3A465A),
          ),
      );
      canvas.drawCircle(
        Offset(cell.right - 8, cell.top + 9),
        3,
        Paint()
          ..color = _artColor(
            isLight,
            const Color(0xFF99A1AE),
            const Color(0xFF667085),
          ),
      );
    }

    final selectedPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(cells[1], const Radius.circular(4)),
      selectedPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(cells[2], const Radius.circular(4)),
      selectedPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(cells[4], const Radius.circular(4)),
      selectedPaint,
    );

    canvas.drawCircle(
      center + const Offset(14, 18),
      42,
      Paint()
        ..color = AppColors.accent.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawLine(
      center + const Offset(43, 48),
      center + const Offset(65, 70),
      Paint()
        ..color = AppColors.accent
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      center + const Offset(43, 48),
      center + const Offset(65, 70),
      Paint()
        ..color = const Color(0xFF0C5961)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _PermissionArtPainter oldDelegate) =>
      oldDelegate.isLight != isLight;
}

void _drawText(
  Canvas canvas,
  String text,
  Offset offset,
  double size,
  Color color,
  TextAlign align,
) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: size,
        fontWeight: FontWeight.w900,
      ),
    ),
    textDirection: TextDirection.ltr,
    textAlign: align,
  )..layout();
  painter.paint(canvas, offset - Offset(painter.width / 2, painter.height / 2));
}
