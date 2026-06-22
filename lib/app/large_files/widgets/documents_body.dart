import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/loading_shimmer.dart';
import 'package:sift/app/large_files/large_files_controller.dart';
import 'package:sift/app/large_files/widgets/centered_file_state.dart';
import 'package:sift/app/large_files/widgets/large_file_row.dart';

/// Body of the document review page: a size-sorted, multi-select list of the
/// currently visible files, plus loading and empty states.
class DocumentsBody extends StatelessWidget {
  const DocumentsBody({
    super.key,
    required this.controller,
    required this.visible,
  });

  final LargeFilesController controller;
  final List<LargeFileItem> visible;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const ListShimmer();
    }

    if (visible.isEmpty) {
      return CenteredFileState(
        icon: LucideIcons.file,
        title: 'Nothing here',
        body: 'No files were found in this category.',
        primaryLabel: 'Refresh',
        onPrimary: controller.loadFiles,
      );
    }

    return RefreshIndicator(
      color: AppColors.accent,
      backgroundColor: AppColors.surface(context),
      onRefresh: controller.loadFiles,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                '${visible.length} ${visible.length == 1 ? 'file' : 'files'} · sorted by size',
                style: TextStyle(
                  color: AppColors.textMuted(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            );
          }
          final file = visible[index - 1];
          return LargeFileRow(
            file: file,
            selected: controller.isSelected(file),
            onTap: () => controller.toggleFile(file),
          );
        },
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemCount: visible.length + 1,
      ),
    );
  }
}
