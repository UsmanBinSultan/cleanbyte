import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/large_files/large_files_controller.dart';
import 'package:sift/app/large_files/widgets/large_files_documents_page.dart';
import 'package:sift/core/utils/formatters.dart';

/// 2x2 grid of quick source shortcuts (Downloads, Documents, Recently Added).
/// Only sources with bytes on disk are shown.
class SourceGrid extends StatelessWidget {
  const SourceGrid({super.key, required this.controller});

  final LargeFilesController controller;

  @override
  Widget build(BuildContext context) {
    final sources = <_SourceData>[
      _SourceData(
        label: 'Downloads',
        bytes: controller.sourceBytes(LargeFilesController.sourceDownloads),
        icon: LucideIcons.download,
        color: AppColors.iconAmber,
        tint: AppColors.tintAmber,
        onTap: () => openLargeFilesDocuments(
          controller,
          title: 'Downloads',
          filter: (f) => f.source == LargeFilesController.sourceDownloads,
        ),
      ),
      _SourceData(
        label: 'Documents',
        bytes: controller.sourceBytes(LargeFilesController.sourceDocuments),
        icon: LucideIcons.folder,
        color: AppColors.accent,
        tint: AppColors.tintTeal,
        onTap: () => openLargeFilesDocuments(
          controller,
          title: 'Documents',
          filter: (f) => f.source == LargeFilesController.sourceDocuments,
        ),
      ),
      _SourceData(
        label: 'Recently Added',
        bytes: controller.recentBytes,
        icon: LucideIcons.clock,
        color: AppColors.iconPink,
        tint: AppColors.tintPink,
        onTap: () => openLargeFilesDocuments(
          controller,
          title: 'Recently Added',
          filter: (f) => f.modified.isAfter(
            DateTime.now().subtract(const Duration(days: 30)),
          ),
        ),
      ),
    ].where((s) => s.bytes > 0).toList();

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.1,
      children: [for (final s in sources) _SourceCard(data: s)],
    );
  }
}

class _SourceData {
  const _SourceData({
    required this.label,
    required this.bytes,
    required this.icon,
    required this.color,
    required this.tint,
    required this.onTap,
  });

  final String label;
  final int bytes;
  final IconData icon;
  final Color color;
  final Color tint;
  final VoidCallback onTap;
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({required this.data});

  final _SourceData data;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface(context),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: data.onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderFor(context)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.iconChipBg(context, data.color, data.tint),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(data.icon, size: 19, color: data.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      data.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      formatBytes(data.bytes),
                      style: TextStyle(
                        color: AppColors.textMuted(context),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
