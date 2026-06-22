import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/photos/widgets/ai_delete_badge.dart';
import 'package:sift/core/utils/formatters.dart';

/// The large swipeable photo card: full-bleed image, bottom scrim with date +
/// detail, an AI-suggests-delete badge and the drag KEEP/DELETE stamps.
class SwipePhotoCard extends StatelessWidget {
  const SwipePhotoCard({
    super.key,
    required this.asset,
    required this.subtitle,
    this.keepOpacity = 0,
    this.deleteOpacity = 0,
  });

  final AssetEntity asset;
  final String subtitle;
  final double keepOpacity;
  final double deleteOpacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.borderFor(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(27),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _ReviewPhoto(asset: asset),
            // Scrim so the caption stays legible over the photo.
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 130,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0xCC000000), Colors.transparent],
                  ),
                ),
              ),
            ),
            const Positioned(left: 12, top: 12, child: AiDeleteBadge()),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shortDateTimeLabel(asset.createDateTime),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            _DecisionStamp(
              label: 'DELETE',
              color: AppColors.danger,
              angle: -0.25,
              opacity: deleteOpacity,
            ),
            _DecisionStamp(
              label: 'KEEP',
              color: AppColors.accent,
              angle: 0.25,
              opacity: keepOpacity,
            ),
          ],
        ),
      ),
    );
  }
}

class _DecisionStamp extends StatelessWidget {
  const _DecisionStamp({
    required this.label,
    required this.color,
    required this.angle,
    required this.opacity,
  });

  final String label;
  final Color color;
  final double angle;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Opacity(
        opacity: opacity.clamp(0, 1),
        child: Transform.rotate(
          angle: angle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color, width: 3),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewPhoto extends StatefulWidget {
  const _ReviewPhoto({required this.asset});

  final AssetEntity asset;

  @override
  State<_ReviewPhoto> createState() => _ReviewPhotoState();
}

class _ReviewPhotoState extends State<_ReviewPhoto> {
  late Future<Uint8List?> _photo;

  @override
  void initState() {
    super.initState();
    _photo = _load();
  }

  @override
  void didUpdateWidget(_ReviewPhoto oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The swipe pane rebuilds on every drag delta; only reload when the
    // reviewed asset actually changes so the full-size image isn't decoded
    // again on each frame.
    if (oldWidget.asset.id != widget.asset.id) {
      _photo = _load();
    }
  }

  Future<Uint8List?> _load() => widget.asset.thumbnailDataWithSize(
    const ThumbnailSize(900, 1200),
    quality: 92,
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _photo,
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (bytes == null) {
          return const ColoredBox(
            color: Color(0xFF347E62),
            child: Center(
              child: Icon(
                LucideIcons.image,
                color: Color(0xFF9ED1C2),
                size: 42,
              ),
            ),
          );
        }

        return Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true);
      },
    );
  }
}
