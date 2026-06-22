import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/core/utils/formatters.dart';

/// Header of the swipe review pane: back/restore buttons, the date + "Pic X of
/// N" label, a progress bar and a saved-bytes readout.
class SwipeReviewHeader extends StatelessWidget {
  const SwipeReviewHeader({
    super.key,
    required this.asset,
    required this.reviewed,
    required this.total,
    required this.progress,
    required this.savedBytes,
    required this.onBack,
  });

  final AssetEntity asset;
  final int reviewed;
  final int total;
  final double progress;
  final int savedBytes;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _ReviewCircleButton(icon: LucideIcons.chevronLeft, onTap: onBack),
            Expanded(
              child: Column(
                children: [
                  Text(
                    monthYearLabel(asset.createDateTime),
                    style: TextStyle(
                      color: AppColors.textFaint(context),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Pic $reviewed of $total',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            _ReviewCircleButton(icon: LucideIcons.rotateCcw, onTap: onBack),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            color: AppColors.accent,
            backgroundColor: AppColors.surfaceTint(context),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '$reviewed of $total reviewed',
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '${formatBytes(savedBytes)} saved',
              style: const TextStyle(
                color: AppColors.accent,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ReviewCircleButton extends StatelessWidget {
  const _ReviewCircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderFor(context)),
        ),
        child: Icon(icon, size: 16, color: AppColors.textMuted(context)),
      ),
    );
  }
}
