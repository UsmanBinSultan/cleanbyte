import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/asset_thumbnail.dart';
import 'package:sift/app/photos/photos_controller.dart';
import 'package:sift/core/utils/formatters.dart';

/// One duplicate set: header pills, a horizontal strip of thumbnails (best +
/// extras) and "Keep best" / "Keep all" actions.
class DuplicateGroupCard extends StatelessWidget {
  const DuplicateGroupCard({
    super.key,
    required this.controller,
    required this.group,
    required this.index,
  });

  final SimilarPhotosController controller;
  final DuplicatePhotoGroup group;
  final int index;

  @override
  Widget build(BuildContext context) {
    final selectedInGroup = group.extras
        .where((e) => controller.isSelected(e))
        .length;
    final allSelected =
        group.extras.isNotEmpty && selectedInGroup == group.extras.length;
    final bytes = controller.groupExtraBytes(group);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderFor(context)),
        boxShadow: AppColors.isLight(context)
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                Text(
                  'Group $index',
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  group.label,
                  style: TextStyle(
                    color: AppColors.textMuted(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                _MiniPill(
                  text: '${group.photoCount} photos',
                  color: AppColors.textMuted(context),
                  bg: AppColors.surfaceTint(context),
                ),
                const SizedBox(width: 6),
                _MiniPill(
                  text: '-${formatBytes(bytes)}',
                  color: AppColors.danger,
                  bg: AppColors.iconChipBg(
                    context,
                    AppColors.danger,
                    AppColors.dangerBg,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 68,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: group.all.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final asset = group.all[i];
                final keeper = controller.isKeeper(group, asset);
                return _GroupThumb(
                  asset: asset,
                  keeper: keeper,
                  selected: !keeper && controller.isSelected(asset),
                  onTap: keeper ? null : () => controller.toggleAsset(asset),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: AppColors.borderFor(context)),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Row(
              children: [
                Expanded(
                  child: _GroupActionButton(
                    label: group.extras.length > 1
                        ? 'Keep best - Delete ${group.extras.length}'
                        : 'Keep best - Delete 1',
                    icon: LucideIcons.checkCircle2,
                    filled: true,
                    active: allSelected,
                    onTap: controller.isDeleting
                        ? null
                        : () => _keepBest(controller, group),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _GroupActionButton(
                    label: 'Keep all',
                    icon: LucideIcons.layers,
                    filled: false,
                    active: selectedInGroup == 0,
                    onTap: () =>
                        controller.setGroupExtrasSelected(group, false),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Keeps the best copy of [group] and deletes its extra duplicates straight
/// away (recycle-bin backed), then reports the result.
Future<void> _keepBest(
  SimilarPhotosController controller,
  DuplicatePhotoGroup group,
) async {
  final deleted = await controller.deleteGroupExtras(group);
  Get.snackbar(
    deleted == 0 ? 'Nothing deleted' : 'Kept best · deleted $deleted',
    deleted == 0
        ? 'The system did not remove any copies.'
        : 'Extra copies removed. The best photo was kept.',
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: const Color(0xFF111929),
    colorText: Colors.white,
    margin: const EdgeInsets.all(16),
  );
}

/// Pill button used in the duplicate-group footer ("Keep best" / "Keep all").
class _GroupActionButton extends StatelessWidget {
  const _GroupActionButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool filled;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const accent = AppColors.accent;
    final bg = filled
        ? (active
              ? accent
              : AppColors.iconChipBg(context, accent, AppColors.tintTeal))
        : AppColors.surface(context);
    final fg = filled
        ? (active ? Colors.white : accent)
        : (active ? accent : AppColors.textMuted(context));

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 40,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: filled
                ? null
                : Border.all(
                    color: active ? accent : AppColors.borderFor(context),
                  ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: fg),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: fg,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
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

class _MiniPill extends StatelessWidget {
  const _MiniPill({required this.text, required this.color, required this.bg});

  final String text;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _GroupThumb extends StatelessWidget {
  const _GroupThumb({
    required this.asset,
    required this.keeper,
    required this.selected,
    required this.onTap,
  });

  final AssetEntity asset;
  final bool keeper;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 58,
        height: 68,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: keeper
                      ? AppColors.accent
                      : selected
                      ? AppColors.danger
                      : AppColors.borderFor(context),
                  width: 2,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: AssetThumbnail(
                asset: asset,
                size: const ThumbnailSize(160, 160),
              ),
            ),
            if (keeper)
              Positioned(
                left: 2,
                top: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: const Text(
                    'Best',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 7,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              )
            else
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.danger
                        : Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.surface(context),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    selected ? LucideIcons.x : LucideIcons.circle,
                    size: 9,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
