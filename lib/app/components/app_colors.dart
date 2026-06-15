import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor = Color(0xFF0B1221);
  static const Color darkteal = Color(0xFF0C2730);
  static const Color bg = Color(0xFF0B1220);
  static const Color bgDeep = Color(0xFF060810);
  static const Color surface1 = Color(0x0AFFFFFF);
  static const Color surface2 = Color(0x12FFFFFF);
  static const Color border = Color(0x14FFFFFF);
  static const Color borderStrong = Color(0x24FFFFFF);
  static const Color accent = Color(0xFF14B8A6);
  static const Color accentDeep = Color(0xFF0E7C66);
  static const Color amber = Color(0xFFF59E0B);
  static const Color sage = Color(0xFF84A98C);
  static const Color coral = Color(0xFFE76F51);
  static const Color fg = Color(0xFFF4F4F2);
  static const Color fgMuted = Color(0x9EF4F4F2);
  static const Color fgFaint = Color(0x61F4F4F2);
  static const Color lightBg = Color(0xFFFFFBF5);
  static const Color lightFg = Color(0xFF17201B);
  static const Color lightFgMuted = Color(0xFF667085);
  static const Color lightFgFaint = Color(0xFF697486);
  static const Color lightSurface = Colors.white;
  static const Color lightSurfaceTint = Color(0xFFFFF5EA);
  static const Color lightBorder = Color(0xFFE9DDD0);

  // Shimmer / skeleton-loader colors. The dark values match the existing
  // surface tones (so a skeleton sits just above the dark page background); the
  // light values are a warm grey base with a near-white sweep so the effect
  // stays "visible but subtle" on the cream light theme instead of rendering as
  // dark slabs with an imperceptible highlight.
  static const Color shimmerBaseDark = Color(0xFF111929);
  static const Color shimmerHighlightDark = Color(0xFF1C2A3E);
  static const Color shimmerBaseLight = Color(0xFFE3DFD8);
  static const Color shimmerHighlightLight = Color(0xFFF6F4F0);

  static bool isLight(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light;
  }

  static Color shimmerBase(BuildContext context) {
    return isLight(context) ? shimmerBaseLight : shimmerBaseDark;
  }

  static Color shimmerHighlight(BuildContext context) {
    return isLight(context) ? shimmerHighlightLight : shimmerHighlightDark;
  }

  static Color pageBackground(BuildContext context) {
    return isLight(context) ? lightBg : const Color(0xFF071120);
  }

  static Color surface(BuildContext context) {
    return isLight(context) ? lightSurface : const Color(0xFF111929);
  }

  static Color surfaceTint(BuildContext context) {
    return isLight(context) ? lightSurfaceTint : const Color(0xFF111929);
  }

  static Color borderFor(BuildContext context) {
    return isLight(context) ? lightBorder : const Color(0xFF202B3F);
  }

  static Color textPrimary(BuildContext context) {
    return isLight(context) ? lightFg : fg;
  }

  static Color textMuted(BuildContext context) {
    return isLight(context) ? lightFgMuted : const Color(0xFF8B94A3);
  }

  static Color textFaint(BuildContext context) {
    return isLight(context) ? lightFgFaint : const Color(0xFF697486);
  }

  static Color bottomBar(BuildContext context) {
    return isLight(context) ? lightSurface : const Color(0xFF071120);
  }

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentDeep],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient splashGradient = LinearGradient(
    colors: [accent, accentDeep],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient amberGradient = LinearGradient(
    colors: [Color(0xFFFBBF24), amber],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient coralGradient = LinearGradient(
    colors: [Color(0xFFF8927A), coral],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
