import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/sift_top_app_bar.dart';
import 'package:sift/app/recycle_bin/recycle_bin_controller.dart';
import 'package:sift/models/trashed_item.dart';

class RecycleBinView extends StatelessWidget {
  const RecycleBinView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RecycleBinController>(
      builder: (controller) {
        final message = controller.message;
        if (message != null) {
          controller.consumeMessage();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.snackbar(
              'recycle bin'.tr,
              'restored'.tr,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.surface(context),
              colorText: AppColors.textPrimary(context),
              margin: const EdgeInsets.all(16),
            );
          });
        }

        return Scaffold(
          backgroundColor: AppColors.pageBackground(context),
          body: SafeArea(
            child: Column(
              children: [
                _Header(controller: controller),
                Expanded(child: _Body(controller: controller)),
                if (controller.hasSelection)
                  _BottomActions(controller: controller),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.controller});

  final RecycleBinController controller;

  @override
  Widget build(BuildContext context) {
    final allSelected =
        controller.items.isNotEmpty &&
        controller.selectedIds.length == controller.items.length;

    return SiftTopAppBar(
      title: 'recycle bin'.tr,
      trailing: controller.isEmpty
          ? null
          : TextButton(
              onPressed: () => _confirmEmpty(context, controller),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFFF7A5F),
                textStyle: const TextStyle(fontWeight: FontWeight.w800),
              ),
              child: Text(
                controller.hasSelection
                    ? (allSelected ? 'clear'.tr : 'select_all'.tr)
                    : 'empty bin'.tr,
              ),
            ),
      onBack: Get.back,
    );
  }

  Future<void> _confirmEmpty(
    BuildContext context,
    RecycleBinController controller,
  ) async {
    // When a selection is active this button toggles select-all instead.
    if (controller.hasSelection) {
      controller.selectAll();
      return;
    }
    final confirmed = await _confirmDialog(
      context,
      title: 'empty bin'.tr,
      body: 'empty bin confirm'.tr,
      confirmLabel: 'empty bin'.tr,
    );
    if (confirmed) {
      await controller.emptyBin();
    }
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.controller});

  final RecycleBinController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isEmpty) {
      return _EmptyState();
    }

    return Column(
      children: [
        _RetentionNote(days: controller.retentionDays),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: controller.items.length,
            itemBuilder: (context, index) {
              final item = controller.items[index];
              return _TrashedTile(
                item: item,
                selected: controller.isSelected(item),
                daysLeft: item.daysLeft(controller.retentionDays),
                onTap: () => controller.toggleSelect(item),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RetentionNote extends StatelessWidget {
  const _RetentionNote({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF18D0B8).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.info, size: 18, color: Color(0xFF18D0B8)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'auto delete note'.trParams({'days': '$days'}),
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 11.5,
                height: 1.3,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrashedTile extends StatelessWidget {
  const _TrashedTile({
    required this.item,
    required this.selected,
    required this.daysLeft,
    required this.onTap,
  });

  final TrashedItem item;
  final bool selected;
  final int daysLeft;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _Thumbnail(item: item),
            // Darken slightly so the overlays stay legible.
            Container(color: Colors.black.withValues(alpha: 0.06)),
            if (item.type.isVideo)
              const Center(
                child: Icon(
                  LucideIcons.playCircle,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            Positioned(
              left: 6,
              bottom: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'days left'.trParams({'days': '$daysLeft'}),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            if (selected)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF18D0B8),
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            Positioned(
              right: 6,
              top: 6,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF18D0B8)
                      : Colors.black.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: selected
                    ? const Icon(
                        LucideIcons.check,
                        size: 13,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.item});

  final TrashedItem item;

  @override
  Widget build(BuildContext context) {
    if (item.type.isVideo) {
      return Container(
        color: const Color(0xFF1B2537),
        alignment: Alignment.center,
        child: const Icon(
          LucideIcons.video,
          color: Color(0xFF6B7689),
          size: 26,
        ),
      );
    }
    return Image.file(
      File(item.backupPath),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) => Container(
        color: const Color(0xFF1B2537),
        alignment: Alignment.center,
        child: const Icon(
          LucideIcons.imageOff,
          color: Color(0xFF6B7689),
          size: 24,
        ),
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({required this.controller});

  final RecycleBinController controller;

  @override
  Widget build(BuildContext context) {
    final count = controller.selectedIds.length;
    final busy = controller.isBusy;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
      decoration: BoxDecoration(
        color: AppColors.bottomBar(context),
        border: Border(top: BorderSide(color: AppColors.borderFor(context))),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 50,
              child: TextButton.icon(
                onPressed: busy ? null : controller.restoreSelected,
                icon: busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(LucideIcons.undo2, size: 18),
                label: Text('restore'.trParams({'count': '$count'})),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF18D0B8),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFF143F3B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 50,
              child: TextButton.icon(
                onPressed: busy ? null : () => _confirmDelete(context),
                icon: const Icon(LucideIcons.trash2, size: 18),
                label: Text('delete now'.trParams({'count': '$count'})),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7A5F),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFF5A3A33),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await _confirmDialog(
      context,
      title: 'delete now'.trParams({'count': '${controller.selectedIds.length}'}),
      body: 'delete now confirm'.tr,
      confirmLabel: 'delete'.tr,
    );
    if (confirmed) {
      await controller.deleteSelected();
    }
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.trash2,
              size: 46,
              color: AppColors.textFaint(context),
            ),
            const SizedBox(height: 18),
            Text(
              'recycle bin empty'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'recycle bin empty body'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool> _confirmDialog(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
}) async {
  final result = await Get.dialog<bool>(
    AlertDialog(
      backgroundColor: AppColors.surface(context),
      title: Text(
        title,
        style: TextStyle(
          color: AppColors.textPrimary(context),
          fontWeight: FontWeight.w900,
        ),
      ),
      content: Text(
        body,
        style: TextStyle(color: AppColors.textMuted(context)),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: Text('cancel'.tr),
        ),
        TextButton(
          onPressed: () => Get.back(result: true),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFFF7A5F),
          ),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result == true;
}
