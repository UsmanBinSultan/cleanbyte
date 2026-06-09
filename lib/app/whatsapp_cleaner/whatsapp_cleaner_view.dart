import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/loading_shimmer.dart';
import 'package:sift/app/components/sift_bottom_nav_bar.dart';
import 'package:sift/app/components/sift_top_app_bar.dart';
import 'package:sift/app/whatsapp_cleaner/whatsapp_cleaner_controller.dart';
import 'package:sift/core/utils/formatters.dart';

class WhatsappCleanerView extends StatelessWidget {
  const WhatsappCleanerView({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _WaTypeData(
        'images',
        'open whatsapp photos',
        LucideIcons.image,
        const Color(0xFFD7B451),
        WhatsappMediaType.images,
      ),
      _WaTypeData(
        'videos',
        'open whatsapp videos',
        LucideIcons.video,
        const Color(0xFFE36F64),
        WhatsappMediaType.videos,
      ),
      _WaTypeData(
        'voice notes',
        'open voice notes',
        LucideIcons.mic,
        const Color(0xFF9B4FC7),
        WhatsappMediaType.voiceNotes,
      ),
      _WaTypeData(
        'documents',
        'open documents',
        LucideIcons.fileText,
        const Color(0xFF5D78B8),
        WhatsappMediaType.documents,
      ),
    ];

    final args = Get.arguments;
    final fromNav = args is Map && args['fromNav'] == true;

    return GetBuilder<WhatsappCleanerController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.pageBackground(context),
          bottomNavigationBar: fromNav
              ? const SiftBottomNavBar(activeIndex: 2)
              : null,
          body: SafeArea(
            bottom: !fromNav,
            child: Column(
              children: [
                _Header(title: 'wa cleaner'.tr, showBack: !fromNav),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: controller.loadSummary,
                          borderRadius: BorderRadius.circular(18),
                          child: _WaSummaryCard(controller: controller),
                        ),
                        const SizedBox(height: 26),
                        Text(
                          'by type'.tr,
                          style: const TextStyle(
                            color: Color(0xFF697486),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GridView.builder(
                          itemCount: items.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 1.2,
                              ),
                          itemBuilder: (context, index) {
                            return _WaTypeCard(data: items[index]);
                          },
                        ),
                        const SizedBox(height: 22),
                        Text(
                          'whatsapp note'.tr,
                          style: const TextStyle(
                            color: Color(0xFF6F7887),
                            fontSize: 11,
                            height: 1.45,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WaSummaryCard extends StatelessWidget {
  const _WaSummaryCard({required this.controller});

  final WhatsappCleanerController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? AppColors.surface(context)
            : AppColors.surface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF334252),
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Icon(
              LucideIcons.messageCircle,
              color: Color(0xFFFFD34D),
              size: 17,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: controller.isLoadingSummary
                ? const LoadingShimmer(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SummaryBlock(width: 90, height: 24),
                        SizedBox(height: 8),
                        _SummaryBlock(width: 150, height: 10),
                      ],
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatBytes(controller.totalBytes),
                        style: TextStyle(
                          color: AppColors.textPrimary(context),
                          fontSize: 25,
                          height: 1,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${controller.totalCount} ${'whatsapp media found'.tr}',
                        style: TextStyle(
                          color: AppColors.textMuted(context),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
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

class _SummaryBlock extends StatelessWidget {
  const _SummaryBlock({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class _WaTypeData {
  const _WaTypeData(
    this.title,
    this.subtitle,
    this.icon,
    this.color,
    this.type,
  );

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final WhatsappMediaType type;
}

class _WaTypeCard extends StatelessWidget {
  const _WaTypeCard({required this.data});

  final _WaTypeData data;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.to(() => WhatsappMediaView(type: data.type)),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.light
              ? AppColors.surface(context)
              : AppColors.surface(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderFor(context)),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: data.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(data.icon, color: data.color, size: 17),
                ),
                const Spacer(),
                Text(
                  data.title.tr,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  data.subtitle.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textMuted(context),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? LucideIcons.chevronLeft
                    : LucideIcons.chevronRight,
                size: 17,
                color: const Color(0xFF697486),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WhatsappMediaView extends StatelessWidget {
  const WhatsappMediaView({super.key, required this.type});

  final WhatsappMediaType type;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WhatsappMediaController>(
      tag: type.name,
      init: WhatsappMediaController(type: type),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.pageBackground(context),
          body: SafeArea(
            child: Column(
              children: [
                _MediaHeader(controller: controller),
                Expanded(child: _MediaBody(controller: controller)),
                _MediaDeleteButton(controller: controller),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MediaBody extends StatelessWidget {
  const _MediaBody({required this.controller});

  final WhatsappMediaController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const ListShimmer();
    }

    if (!controller.hasAccess || controller.errorMessage != null) {
      return _WaCenteredState(
        icon: LucideIcons.folderOpen,
        title: 'File access needed',
        body:
            controller.errorMessage ??
            'Allow file access to show WhatsApp ${controller.type.title.toLowerCase()}.',
        primaryLabel: 'Open Settings',
        onPrimary: controller.openSettings,
        secondaryLabel: 'Try Again',
        onSecondary: controller.loadItems,
      );
    }

    if (controller.items.isEmpty) {
      return _WaCenteredState(
        icon: _typeIcon(controller.type),
        title: 'No ${controller.type.title.toLowerCase()} found',
        body:
            'WhatsApp ${controller.type.title.toLowerCase()} will appear here when found on this phone.',
        primaryLabel: 'Refresh',
        onPrimary: controller.loadItems,
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF18D0B8),
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : const Color(0xFF111929),
      onRefresh: controller.loadItems,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            sliver: SliverToBoxAdapter(
              child: _WaMediaSummary(controller: controller),
            ),
          ),
          if (controller.type.usesGrid)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              sliver: SliverGrid.builder(
                itemCount: controller.items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.78,
                ),
                itemBuilder: (context, index) {
                  final item = controller.items[index];
                  return _WaGridItem(
                    item: item,
                    type: controller.type,
                    selected: controller.isSelected(item),
                    onTap: () => controller.toggleItem(item),
                  );
                },
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              sliver: SliverList.separated(
                itemCount: controller.items.length,
                itemBuilder: (context, index) {
                  final item = controller.items[index];
                  return _WaListItem(
                    item: item,
                    type: controller.type,
                    selected: controller.isSelected(item),
                    onTap: () => controller.toggleItem(item),
                  );
                },
                separatorBuilder: (_, _) => const SizedBox(height: 10),
              ),
            ),
        ],
      ),
    );
  }
}

class _WaMediaSummary extends StatelessWidget {
  const _WaMediaSummary({required this.controller});

  final WhatsappMediaController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${controller.items.length} files',
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontSize: 25,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${formatBytes(controller.totalBytes)} - tap items to select and delete',
          style: TextStyle(
            color: AppColors.textMuted(context),
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _WaGridItem extends StatelessWidget {
  const _WaGridItem({
    required this.item,
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final WhatsappMediaItem item;
  final WhatsappMediaType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.light
              ? AppColors.surface(context)
              : AppColors.surface(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? const Color(0xFF18D0B8)
                : AppColors.borderFor(context),
            width: selected ? 2 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (type == WhatsappMediaType.images)
                Image.file(item.file, fit: BoxFit.cover)
              else
                const ColoredBox(
                  color: Color(0xFF172133),
                  child: Center(
                    child: Icon(
                      LucideIcons.video,
                      color: Color(0xFFE36F64),
                      size: 28,
                    ),
                  ),
                ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.05),
                        Colors.black.withValues(alpha: 0.62),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 7,
                top: 7,
                child: _WaSelectionMark(selected: selected),
              ),
              Positioned(
                left: 7,
                right: 7,
                bottom: 8,
                child: Text(
                  formatBytes(item.size),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
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

class _WaListItem extends StatelessWidget {
  const _WaListItem({
    required this.item,
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final WhatsappMediaItem item;
  final WhatsappMediaType type;
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
                color: _typeColor(type).withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_typeIcon(type), color: _typeColor(type), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
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
                    '${formatBytes(item.size)} - ${formatShortDate(item.modified)}',
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
            _WaSelectionMark(selected: selected),
          ],
        ),
      ),
    );
  }
}

class _WaSelectionMark extends StatelessWidget {
  const _WaSelectionMark({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFF18D0B8)
            : Colors.black.withValues(alpha: 0.45),
        shape: BoxShape.circle,
        border: Border.all(
          color: selected
              ? const Color(0xFF18D0B8)
              : Colors.white.withValues(alpha: 0.65),
        ),
      ),
      child: selected
          ? const Icon(LucideIcons.check, size: 14, color: Color(0xFF062322))
          : null,
    );
  }
}

class _WaCenteredState extends StatelessWidget {
  const _WaCenteredState({
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

class _MediaHeader extends StatelessWidget {
  const _MediaHeader({required this.controller});

  final WhatsappMediaController controller;

  @override
  Widget build(BuildContext context) {
    final allSelected =
        controller.items.isNotEmpty &&
        controller.selectedPaths.length == controller.items.length;

    return SiftTopAppBar(
      title: controller.type.title.toLowerCase().tr,
      trailing: TextButton(
        onPressed: controller.items.isEmpty ? null : controller.toggleSelectAll,
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

class _MediaDeleteButton extends StatelessWidget {
  const _MediaDeleteButton({required this.controller});

  final WhatsappMediaController controller;

  @override
  Widget build(BuildContext context) {
    final enabled = controller.selectedCount > 0 && !controller.isDeleting;

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
                : 'Delete selected (${controller.selectedCount})',
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

  Future<void> _confirmAndDelete(WhatsappMediaController controller) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: const Color(0xFF111929),
        title: const Text(
          'Delete selected?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        content: Text(
          'This will delete ${controller.selectedCount} WhatsApp ${controller.type.title.toLowerCase()} from your phone.',
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
          : 'The selected WhatsApp files have been removed.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF111929),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }
}

IconData _typeIcon(WhatsappMediaType type) {
  switch (type) {
    case WhatsappMediaType.images:
      return LucideIcons.image;
    case WhatsappMediaType.videos:
      return LucideIcons.video;
    case WhatsappMediaType.voiceNotes:
      return LucideIcons.mic;
    case WhatsappMediaType.documents:
      return LucideIcons.fileText;
  }
}

Color _typeColor(WhatsappMediaType type) {
  switch (type) {
    case WhatsappMediaType.images:
      return const Color(0xFFD7B451);
    case WhatsappMediaType.videos:
      return const Color(0xFFE36F64);
    case WhatsappMediaType.voiceNotes:
      return const Color(0xFF9B4FC7);
    case WhatsappMediaType.documents:
      return const Color(0xFF5D78B8);
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, this.showBack = true});

  final String title;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return SiftTopAppBar(title: title, showBack: showBack);
  }
}
