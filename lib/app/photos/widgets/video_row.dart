import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/asset_thumbnail.dart';
import 'package:sift/app/components/selection_check_mark.dart';
import 'package:sift/core/utils/formatters.dart';

/// A single large-video row: thumbnail with duration, name, date · size, a
/// selection check and a delete action.
class VideoRow extends StatelessWidget {
  const VideoRow({
    super.key,
    required this.asset,
    required this.size,
    required this.selected,
    required this.onTap,
    required this.onDelete,
  });

  final AssetEntity asset;
  final int? size;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final name = (asset.title?.trim().isNotEmpty ?? false)
        ? asset.title!.trim()
        : 'Video';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected ? AppColors.accent : AppColors.borderFor(context),
          width: selected ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 84,
                    height: 60,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        AssetThumbnail(
                          asset: asset,
                          size: const ThumbnailSize(240, 200),
                        ),
                        const Center(
                          child: Icon(
                            LucideIcons.playCircle,
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                        Positioned(
                          left: 4,
                          bottom: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              formatDuration(asset.videoDuration),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textPrimary(context),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            formatShortDate(
                              asset.createDateTime,
                              recentBefore2000: true,
                            ),
                            style: TextStyle(
                              color: AppColors.textMuted(context),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '  ·  ',
                            style: TextStyle(
                              color: AppColors.textFaint(context),
                            ),
                          ),
                          Text(
                            formatBytes(size),
                            style: const TextStyle(
                              color: AppColors.danger,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SelectionCheckMark(selected: selected),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _VideoActionButton(
            label: 'Delete',
            icon: LucideIcons.trash2,
            color: AppColors.danger,
            tint: AppColors.dangerBg,
            onTap: onDelete,
          ),
        ],
      ),
    );
  }
}

class _VideoActionButton extends StatelessWidget {
  const _VideoActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.tint,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.iconChipBg(context, color, tint),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 42,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
