import 'package:flutter/material.dart';
import 'package:sift/app/components/app_colors.dart';

/// The illustration variant shown at the top of an onboarding page.
enum OnboardingArtType { library, privacy, permission }

/// Renders the onboarding illustration for the given [type] via a CustomPaint.
class OnboardingArt extends StatelessWidget {
  const OnboardingArt({super.key, required this.type, this.badgeLabel});

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
