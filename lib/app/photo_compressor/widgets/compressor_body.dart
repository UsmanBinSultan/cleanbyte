import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/centered_state_view.dart';
import 'package:sift/app/components/loading_shimmer.dart';
import 'package:sift/app/photo_compressor/photo_compressor_controller.dart';
import 'package:sift/app/photo_compressor/widgets/compressor_photo_row.dart';
import 'package:sift/app/photo_compressor/widgets/compressor_preview_card.dart';
import 'package:sift/app/photo_compressor/widgets/quality_row.dart';
import 'package:sift/app/photo_compressor/widgets/savings_panel.dart';

/// Scrollable compressor body: the before/after preview, quality chips, the
/// savings panel and the selectable photo list — with loading / access / empty
/// states.
class CompressorBody extends StatelessWidget {
  const CompressorBody({super.key, required this.controller});

  final PhotoCompressorController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const MediaGridShimmer();
    }

    if (!controller.hasAccess) {
      return CenteredStateView(
        icon: LucideIcons.image,
        title: 'Photos access needed',
        body: 'Allow photo access to pick images and compress them.',
        primaryLabel: 'Open Settings',
        onPrimary: controller.openSettings,
        secondaryLabel: 'Try Again',
        onSecondary: controller.loadPhotos,
      );
    }

    if (controller.errorMessage != null && controller.photos.isEmpty) {
      return CenteredStateView(
        icon: LucideIcons.imageOff,
        title: 'Photos unavailable',
        body: controller.errorMessage!,
        primaryLabel: 'Try Again',
        onPrimary: controller.loadPhotos,
      );
    }

    if (controller.photos.isEmpty) {
      return CenteredStateView(
        icon: LucideIcons.image,
        title: 'No photos found',
        body: 'Photos from your library will appear here after they are found.',
        primaryLabel: 'Refresh',
        onPrimary: controller.loadPhotos,
      );
    }

    return RefreshIndicator(
      color: AppColors.accent,
      backgroundColor: AppColors.surface(context),
      onRefresh: controller.loadPhotos,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CompressorPreviewCard(controller: controller),
            const SizedBox(height: 22),
            const _SectionLabel('QUALITY'),
            const SizedBox(height: 12),
            QualityRow(controller: controller),
            const SizedBox(height: 16),
            SavingsPanel(controller: controller),
            if (controller.errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                controller.errorMessage!,
                style: const TextStyle(
                  color: AppColors.danger,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
            const SizedBox(height: 22),
            _PhotosHeader(controller: controller),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  for (final photo in controller.photos)
                    CompressorPhotoRow(
                      photo: photo,
                      selected: controller.isSelected(photo),
                      originalSize: controller.originalSizes[photo.id] ?? 0,
                      compressed: controller.compressedBySource[photo.id],
                      onTap: () => controller.togglePhoto(photo),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF697486),
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 2.2,
      ),
    );
  }
}

class _PhotosHeader extends StatelessWidget {
  const _PhotosHeader({required this.controller});

  final PhotoCompressorController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _SectionLabel('PHOTOS'),
        const Spacer(),
        TextButton.icon(
          onPressed: controller.loadPhotos,
          icon: const Icon(LucideIcons.imagePlus, size: 14),
          label: const Text('Pick photos'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.accent,
            textStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        TextButton(
          onPressed: controller.toggleSelectAll,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.accent,
            textStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
          child: Text(
            controller.selectedCount == controller.photos.length
                ? 'Deselect'
                : 'Select all',
          ),
        ),
      ],
    );
  }
}
