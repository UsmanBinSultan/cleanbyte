import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/large_files/audio_files_page.dart';
import 'package:sift/app/large_files/large_files_controller.dart';
import 'package:sift/app/large_files/widgets/large_files_documents_page.dart';
import 'package:sift/app/routes/app_routes.dart';
import 'package:sift/core/utils/formatters.dart';

/// 4-column grid of file categories. Media categories open the matching cleaner
/// route; document categories open a filtered document review page.
class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key, required this.controller});

  final LargeFilesController controller;

  int _sourceCount(String label) =>
      controller.files.where((f) => f.source == label).length;

  @override
  Widget build(BuildContext context) {
    final tiles = <_CategoryData>[
      _CategoryData(
        label: 'Images',
        count: controller.imageCount,
        icon: LucideIcons.image,
        color: AppColors.accent,
        tint: AppColors.tintMint,
        onTap: () => Get.toNamed(AppRoutes.similarPhotos),
      ),
      _CategoryData(
        label: 'Videos',
        count: controller.videoCount,
        icon: LucideIcons.video,
        color: AppColors.iconPurple,
        tint: AppColors.tintPurple,
        onTap: () => Get.toNamed(AppRoutes.largeVideos),
      ),
      _CategoryData(
        label: 'Audio',
        count: controller.audioCount,
        icon: LucideIcons.music,
        color: AppColors.iconPink,
        tint: AppColors.tintPink,
        onTap: () => Get.to(() => const AudioFilesPage()),
      ),
      _CategoryData(
        label: 'Documents',
        count: controller.documentsCount,
        icon: LucideIcons.fileText,
        color: AppColors.iconBlue,
        tint: AppColors.tintBlue,
        onTap: () => openLargeFilesDocuments(
          controller,
          title: 'Documents',
          filter: (f) => !isArchiveFile(f.name),
        ),
      ),
      _CategoryData(
        label: 'Archives',
        count: controller.archivesCount,
        icon: LucideIcons.archive,
        color: AppColors.iconAmber,
        tint: AppColors.tintAmber,
        onTap: () => openLargeFilesDocuments(
          controller,
          title: 'Archives',
          filter: (f) => isArchiveFile(f.name),
        ),
      ),
      _CategoryData(
        label: 'Large Files',
        count: controller.largeFilesCount,
        icon: LucideIcons.alertCircle,
        color: AppColors.danger,
        tint: AppColors.dangerBg,
        onTap: () => openLargeFilesDocuments(
          controller,
          title: 'Large Files',
          filter: (f) => controller.largeFiles.contains(f),
        ),
      ),
      _CategoryData(
        label: 'Downloads',
        count: _sourceCount(LargeFilesController.sourceDownloads),
        icon: LucideIcons.download,
        color: AppColors.accent,
        tint: AppColors.tintGreen,
        onTap: () => openLargeFilesDocuments(
          controller,
          title: 'Downloads',
          filter: (f) => f.source == LargeFilesController.sourceDownloads,
        ),
      ),
    ];

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.64,
      children: [for (final t in tiles) _CategoryTile(data: t)],
    );
  }
}

/// Whether [name] looks like an archive (zip/rar/7z/apk).
bool isArchiveFile(String name) {
  final lower = name.toLowerCase();
  const archives = ['.zip', '.rar', '.7z', '.apk'];
  return archives.any(lower.endsWith);
}

class _CategoryData {
  const _CategoryData({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
    required this.tint,
    this.onTap,
  });

  final String label;
  final int count;
  final IconData icon;
  final Color color;
  final Color tint;
  final VoidCallback? onTap;
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.data});

  final _CategoryData data;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface(context),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: data.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderFor(context)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.iconChipBg(context, data.color, data.tint),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(data.icon, size: 19, color: data.color),
              ),
              const SizedBox(height: 5),
              Text(
                data.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                formatThousands(data.count),
                style: TextStyle(
                  color: AppColors.textMuted(context),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
