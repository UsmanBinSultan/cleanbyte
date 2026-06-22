import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';

/// The "We only look" hero: three rows of individually-tilted real photos with
/// detection badges, plus a centred scan ring + sweep line — matching Figma.
class PhotoGridArt extends StatelessWidget {
  const PhotoGridArt({super.key});

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
