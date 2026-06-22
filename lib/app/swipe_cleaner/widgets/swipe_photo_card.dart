import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/asset_thumbnail.dart';
import 'package:sift/core/utils/formatters.dart';

/// A single swipe-deck photo card: the thumbnail, a date caption and the
/// KEEP / DELETE decision stamps that fade in as the card is dragged.
class SwipePhotoCard extends StatelessWidget {
  const SwipePhotoCard({
    super.key,
    required this.asset,
    required this.interactive,
    this.keepOpacity = 0,
    this.deleteOpacity = 0,
  });

  final AssetEntity asset;
  final bool interactive;
  final double keepOpacity;
  final double deleteOpacity;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        fit: StackFit.expand,
        children: [
          AssetThumbnail(asset: asset, size: const ThumbnailSize(600, 800)),
          // Bottom scrim for legible caption.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.center,
                colors: [Color(0xCC000000), Colors.transparent],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Row(
              children: [
                const Icon(
                  LucideIcons.calendar,
                  size: 14,
                  color: Colors.white70,
                ),
                const SizedBox(width: 6),
                Text(
                  shortDateTimeLabel(asset.createDateTime),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (interactive) ...[
            _DecisionStamp(
              label: 'KEEP',
              color: AppColors.accent,
              alignment: Alignment.topLeft,
              angle: -0.35,
              opacity: keepOpacity,
            ),
            _DecisionStamp(
              label: 'DELETE',
              color: AppColors.danger,
              alignment: Alignment.topRight,
              angle: 0.35,
              opacity: deleteOpacity,
            ),
          ],
        ],
      ),
    );
  }
}

class _DecisionStamp extends StatelessWidget {
  const _DecisionStamp({
    required this.label,
    required this.color,
    required this.alignment,
    required this.angle,
    required this.opacity,
  });

  final String label;
  final Color color;
  final Alignment alignment;
  final double angle;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Opacity(
          opacity: opacity.clamp(0, 1),
          child: Transform.rotate(
            angle: angle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color, width: 3),
                color: color.withValues(alpha: 0.18),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
