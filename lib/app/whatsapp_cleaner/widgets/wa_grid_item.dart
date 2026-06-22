import 'package:flutter/material.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/selection_check_mark.dart';
import 'package:sift/app/whatsapp_cleaner/whatsapp_cleaner_controller.dart';
import 'package:sift/app/whatsapp_cleaner/widgets/wa_video_thumb.dart';
import 'package:sift/core/utils/formatters.dart';

/// Grid tile for an image/video WhatsApp item: a thumbnail with a dark scrim,
/// a selection mark and the file size.
class WaGridItem extends StatelessWidget {
  const WaGridItem({
    super.key,
    required this.item,
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final WhatsappMediaItem item;
  final WhatsappMediaType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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
              if (type == WhatsappMediaType.images)
                Image.file(item.file, fit: BoxFit.cover)
              else
                WaVideoThumb(path: item.path),
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
              Positioned(
                right: 7,
                top: 7,
                child: SelectionCheckMark(selected: selected),
              ),
              Positioned(
                left: 7,
                right: 7,
                bottom: 8,
                child: Text(
                  formatBytes(item.size),
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
