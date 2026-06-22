import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/asset_thumbnail.dart';
import 'package:sift/app/components/selection_check_mark.dart';
import 'package:sift/app/photos/widgets/keep_badge.dart';
import 'package:sift/app/photos/widgets/media_pill.dart';
import 'package:sift/core/utils/formatters.dart';

/// A single selectable media thumbnail used in the photo/screenshot/video
/// grids — thumbnail, scrim, optional video duration + keep badge, a detail
/// label and a selection check.
class MediaTile extends StatelessWidget {
  const MediaTile({
    super.key,
    required this.asset,
    required this.isVideo,
    required this.byteSize,
    required this.detailLabel,
    required this.selected,
    required this.onTap,
    this.onLongPress,
    this.onToggleSelect,
    this.keep = false,
  });

  final AssetEntity asset;
  final bool isVideo;
  final int? byteSize;
  final String detailLabel;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  /// When set, the corner check-mark becomes its own tap target that toggles
  /// selection independently of [onTap] (used where the tile tap opens a
  /// different action, e.g. the photos swipe-review deck).
  final VoidCallback? onToggleSelect;
  final bool keep;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.borderFor(context),
            width: selected ? 2 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AssetThumbnail(asset: asset),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.05),
                        Colors.black.withValues(alpha: 0.62),
                      ],
                    ),
                  ),
                ),
              ),
              if (isVideo)
                Positioned(
                  left: 7,
                  bottom: 7,
                  child: MediaPill(
                    icon: LucideIcons.play,
                    label: formatDuration(asset.videoDuration),
                  ),
                ),
              if (keep && !selected)
                const Positioned(left: 7, top: 7, child: KeepBadge()),
              Positioned(
                right: onToggleSelect == null ? 7 : 1,
                top: onToggleSelect == null ? 7 : 1,
                child: onToggleSelect == null
                    ? SelectionCheckMark(selected: selected)
                    : GestureDetector(
                        onTap: onToggleSelect,
                        behavior: HitTestBehavior.opaque,
                        // Enlarge the touch target around the small mark while
                        // keeping it visually inset by ~7px.
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: SelectionCheckMark(selected: selected),
                        ),
                      ),
              ),
              Positioned(
                left: 7,
                right: 7,
                bottom: isVideo ? 32 : 8,
                child: Text(
                  detailLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
