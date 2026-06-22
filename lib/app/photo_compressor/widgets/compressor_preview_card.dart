import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/asset_thumbnail.dart';
import 'package:sift/app/photo_compressor/photo_compressor_controller.dart';

/// Before / after preview header: the source thumbnail, an arrow, the
/// compressed result with its savings percentage and a summary line.
class CompressorPreviewCard extends StatelessWidget {
  const CompressorPreviewCard({super.key, required this.controller});

  final PhotoCompressorController controller;

  @override
  Widget build(BuildContext context) {
    final photo = controller.previewPhoto;
    final previewCompressed = controller.previewCompressed;
    final percent = controller.estimatedSavingsPercent;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ImagePreview(asset: photo),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Icon(
                  LucideIcons.arrowRight,
                  color: AppColors.accent,
                  size: 32,
                ),
              ),
              Column(
                children: [
                  _ImagePreview(asset: photo, compressed: previewCompressed),
                  const SizedBox(height: 6),
                  Text(
                    '-$percent%',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Compress selected photos',
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            controller.showsLastCompressedHint
                ? 'Last compressed photo is saved to your gallery.'
                : controller.selectedCount == 0
                ? 'Pick images below to create smaller JPEG copies.'
                : '${controller.selectedCount} selected - originals stay untouched.',
            style: TextStyle(
              color: AppColors.textMuted(context),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({this.asset, this.compressed});

  final AssetEntity? asset;
  final CompressedPhoto? compressed;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 94,
        height: 70,
        decoration: BoxDecoration(
          color: AppColors.surfaceTint(context),
          border: Border.all(color: AppColors.borderFor(context), width: 2),
        ),
        child: compressed == null
            ? asset == null
                  ? const Icon(
                      LucideIcons.imageOff,
                      color: Color(0xFF687384),
                      size: 22,
                    )
                  : AssetThumbnail(
                      asset: asset!,
                      size: const ThumbnailSize(360, 360),
                    )
            : Image.file(File(compressed!.outputPath), fit: BoxFit.cover),
      ),
    );
  }
}
