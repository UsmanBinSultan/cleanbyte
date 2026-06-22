import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/asset_thumbnail.dart';
import 'package:sift/app/photo_compressor/photo_compressor_controller.dart';
import 'package:sift/core/utils/formatters.dart';

/// One selectable photo row in the compressor list: thumbnail, title, a
/// size (or before → after) line and a selection box.
class CompressorPhotoRow extends StatelessWidget {
  const CompressorPhotoRow({
    super.key,
    required this.photo,
    required this.selected,
    required this.originalSize,
    required this.onTap,
    this.compressed,
  });

  final AssetEntity photo;
  final bool selected;
  final int originalSize;
  final CompressedPhoto? compressed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final subtitle = compressed == null
        ? formatBytes(originalSize)
        : '${formatBytes(compressed!.originalSize)} -> ${formatBytes(compressed!.compressedSize)}';

    return InkWell(
      onTap: onTap,
      child: Container(
        height: 62,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.borderFor(context)),
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 38,
                height: 38,
                child: AssetThumbnail(
                  asset: photo,
                  size: const ThumbnailSize(360, 360),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    photo.title ?? 'Photo',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textMuted(context),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: selected ? AppColors.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: selected
                      ? AppColors.accent
                      : AppColors.borderFor(context),
                ),
              ),
              child: selected
                  ? const Icon(
                      LucideIcons.check,
                      color: Color(0xFF071120),
                      size: 16,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
