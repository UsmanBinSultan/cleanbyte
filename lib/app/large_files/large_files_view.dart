import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/loading_shimmer.dart';
import 'package:sift/app/components/sift_top_app_bar.dart';
import 'package:sift/app/large_files/large_files_controller.dart';
import 'package:sift/core/utils/formatters.dart';

class LargeFilesView extends StatelessWidget {
  const LargeFilesView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LargeFilesController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.pageBackground(context),
          body: SafeArea(
            child: Column(
              children: [
                _LargeFilesHeader(controller: controller),
                Expanded(child: _LargeFilesBody(controller: controller)),
                _LargeFilesBottomAction(controller: controller),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LargeFilesBody extends StatelessWidget {
  const _LargeFilesBody({required this.controller});

  final LargeFilesController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const ListShimmer();
    }

    if (!controller.hasAccess || controller.errorMessage != null) {
      return _CenteredFileState(
        icon: LucideIcons.fileSearch,
        title: 'File access needed',
        body:
            controller.errorMessage ??
            'Allow file access to show documents from largest to smallest.',
        primaryLabel: 'Open Settings',
        onPrimary: controller.openSettings,
        secondaryLabel: 'Try Again',
        onSecondary: controller.loadFiles,
      );
    }

    if (controller.files.isEmpty) {
      return _CenteredFileState(
        icon: LucideIcons.file,
        title: 'No large documents found',
        body:
            'Documents from Downloads, Documents, and WhatsApp will appear here.',
        primaryLabel: 'Refresh',
        onPrimary: controller.loadFiles,
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF18D0B8),
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? AppColors.surface(context)
          : AppColors.surface(context),
      onRefresh: controller.loadFiles,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _LargeFilesSummary(controller: controller);
          }
          final file = controller.files[index - 1];
          return _LargeFileRow(
            file: file,
            selected: controller.isSelected(file),
            onTap: () => controller.toggleFile(file),
          );
        },
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemCount: controller.files.length + 1,
      ),
    );
  }
}

class _LargeFilesSummary extends StatelessWidget {
  const _LargeFilesSummary({required this.controller});

  final LargeFilesController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${controller.files.length} documents',
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Sorted from largest to smallest',
            style: TextStyle(
              color: AppColors.textMuted(context),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _LargeFileRow extends StatelessWidget {
  const _LargeFileRow({
    required this.file,
    required this.selected,
    required this.onTap,
  });

  final LargeFileItem file;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.light
              ? AppColors.surface(context)
              : AppColors.surface(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? const Color(0xFF18D0B8)
                : AppColors.borderFor(context),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF18D0B8).withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  file.extension,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF18D0B8),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${formatBytes(file.size)} - ${formatShortDate(file.modified)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textMuted(context),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _FileSelectionMark(selected: selected),
          ],
        ),
      ),
    );
  }
}

class _FileSelectionMark extends StatelessWidget {
  const _FileSelectionMark({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF18D0B8) : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? const Color(0xFF18D0B8) : const Color(0xFF697385),
        ),
      ),
      child: selected
          ? const Icon(LucideIcons.check, size: 14, color: Color(0xFF062322))
          : null,
    );
  }
}

class _CenteredFileState extends StatelessWidget {
  const _CenteredFileState({
    required this.icon,
    required this.title,
    required this.body,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  final IconData icon;
  final String title;
  final String body;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF18D0B8), size: 42),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 22),
            TextButton(
              onPressed: onPrimary,
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF18D0B8),
                foregroundColor: const Color(0xFF062322),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.w900),
              ),
              child: Text(primaryLabel),
            ),
            if (secondaryLabel != null && onSecondary != null) ...[
              const SizedBox(height: 10),
              TextButton(
                onPressed: onSecondary,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF18D0B8),
                  textStyle: const TextStyle(fontWeight: FontWeight.w800),
                ),
                child: Text(secondaryLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LargeFilesHeader extends StatelessWidget {
  const _LargeFilesHeader({required this.controller});

  final LargeFilesController controller;

  @override
  Widget build(BuildContext context) {
    final allSelected =
        controller.files.isNotEmpty &&
        controller.selectedPaths.length == controller.files.length;

    return SiftTopAppBar(
      title: 'large_files'.tr,
      trailing: TextButton(
        onPressed: controller.files.isEmpty ? null : controller.toggleSelectAll,
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF18D0B8),
          disabledForegroundColor: const Color(0xFF4A5362),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
        child: Text(allSelected ? 'clear'.tr : 'select_all'.tr),
      ),
    );
  }
}

class _LargeFilesBottomAction extends StatelessWidget {
  const _LargeFilesBottomAction({required this.controller});

  final LargeFilesController controller;

  @override
  Widget build(BuildContext context) {
    final selectedCount = controller.selectedCount;
    final enabled = selectedCount > 0 && !controller.isDeleting;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: BoxDecoration(
        color: AppColors.bottomBar(context),
        border: Border(top: BorderSide(color: AppColors.borderFor(context))),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: TextButton.icon(
          onPressed: enabled ? () => _confirmAndDelete(controller) : null,
          icon: controller.isDeleting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(LucideIcons.trash, size: 18),
          label: Text(
            controller.isDeleting
                ? 'Deleting...'
                : 'Delete selected ($selectedCount)',
          ),
          style: TextButton.styleFrom(
            disabledBackgroundColor: const Color(0xFF111929),
            disabledForegroundColor: const Color(0xFF586274),
            backgroundColor: const Color(0xFFFF7A5F),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmAndDelete(LargeFilesController controller) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: const Color(0xFF111929),
        title: const Text(
          'Delete selected?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        content: Text(
          'This will delete ${controller.selectedCount} selected files from your phone.',
          style: const TextStyle(color: Color(0xFFC2CAD6)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF7A5F),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    final deleted = await controller.deleteSelected();
    Get.snackbar(
      deleted == 0 ? 'Nothing deleted' : 'Deleted $deleted',
      deleted == 0
          ? 'No files were removed. Some files may be protected.'
          : 'The selected files have been removed.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF111929),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }
}

