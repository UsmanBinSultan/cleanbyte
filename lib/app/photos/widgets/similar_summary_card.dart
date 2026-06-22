import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/photos/photos_controller.dart';
import 'package:sift/core/utils/formatters.dart';

/// Mint summary card at the top of the Similar Photos screen — how many can be
/// deleted plus total / to-delete / savings stats.
class SimilarSummaryCard extends StatelessWidget {
  const SimilarSummaryCard({
    super.key,
    required this.controller,
    required this.groups,
  });

  final SimilarPhotosController controller;
  final List<DuplicatePhotoGroup> groups;

  @override
  Widget build(BuildContext context) {
    final toDelete = controller.deletableDuplicateCount;
    final savings = groups.fold<int>(
      0,
      (sum, g) => sum + controller.groupExtraBytes(g),
    );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.iconChipBg(
          context,
          AppColors.accent,
          AppColors.tintMint,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.copy,
                  color: AppColors.accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$toDelete photos can be deleted',
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'We kept the best from each group',
                      style: TextStyle(
                        color: AppColors.textMuted(context),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _SummaryStat(
                value: '${controller.totalCount}',
                label: 'total',
                color: AppColors.textPrimary(context),
              ),
              _SummaryStat(
                value: '$toDelete',
                label: 'to delete',
                color: AppColors.danger,
              ),
              _SummaryStat(
                value: formatBytes(savings),
                label: 'savings',
                color: AppColors.accentDeep,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textMuted(context),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
