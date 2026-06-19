import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/centered_state_view.dart';
import 'package:sift/app/components/loading_shimmer.dart';
import 'package:sift/app/components/selection_check_mark.dart';
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
              ? const SiftBottomNavBar(activeIndex: 3)
              : null,
          body: SafeArea(
            bottom: !fromNav,
            child: Column(
              children: [
                _Header(title: 'WhatsApp Cleaner', showBack: !fromNav),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, fromNav ? 96 : 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: controller.loadSummary,
                          borderRadius: BorderRadius.circular(18),
                          child: _WaSummaryCard(controller: controller),
                        ),
                        const SizedBox(height: 18),
                        _SectionHeader(
                          title: 'Top chats by storage',
                          action:
                              '${items.where((item) => (controller.bytesByType[item.type] ?? 0) > 0).length} found',
                        ),
                        const SizedBox(height: 10),
                        _TopStorageList(items: items, controller: controller),
                        const SizedBox(height: 18),
                        _SectionHeader(
                          title: 'Cleanup Insights',
                          action:
                              '${items.where((item) => (controller.bytesByType[item.type] ?? 0) > 0).length} found',
                        ),
                        const SizedBox(height: 10),
                        for (final item in items) ...[
                          _WaTypeCard(data: item, controller: controller),
                          const SizedBox(height: 12),
                        ],
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              LucideIcons.shieldCheck,
                              size: 12,
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Nothing is deleted until you approve',
                              style: TextStyle(
                                color: AppColors.textMuted(context),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        // const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
                // _WaCleanButton(controller: controller),
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF064E3B), Color(0xFF065F46)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF064E3B).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: controller.isLoadingSummary
                    ? const LoadingShimmer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SummaryBlock(width: 120, height: 14),
                            SizedBox(height: 10),
                            _SummaryBlock(width: 92, height: 34),
                          ],
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'WHATSAPP IS USING',
                            style: TextStyle(
                              color: Color(0x8CFFFFFF),
                              fontSize: 11,
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            formatBytes(controller.totalBytes),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              height: 1.1,
                              letterSpacing: -1,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text.rich(
                            TextSpan(
                              text: 'Clean Byte can recover up to ',
                              children: [
                                TextSpan(
                                  text: formatBytes(controller.totalBytes),
                                  style: const TextStyle(
                                    color: Color(0xFF4ADE80),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            style: const TextStyle(
                              color: Color(0x99FFFFFF),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
              ),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: const Icon(
                  LucideIcons.messageCircle,
                  color: Color(0xFF4ADE80),
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _WaSegmentBar(controller: controller),
          const SizedBox(height: 8),
          Row(
            children: const [
              _LegendDot(color: Color(0xFFEF4444), label: 'Videos'),
              SizedBox(width: 16),
              _LegendDot(color: Color(0xFFF59E0B), label: 'Images'),
              SizedBox(width: 16),
              _LegendDot(color: Color(0xFF8B5CF6), label: 'Voice'),
              SizedBox(width: 16),
              _LegendDot(color: Color(0xFF3B82F6), label: 'Docs'),
            ],
          ),
        ],
      ),
    );
  }
}

class _WaSegmentBar extends StatelessWidget {
  const _WaSegmentBar({required this.controller});

  final WhatsappCleanerController controller;

  @override
  Widget build(BuildContext context) {
    final total = controller.totalBytes <= 0 ? 1 : controller.totalBytes;
    final colors = {
      WhatsappMediaType.videos: const Color(0xFFEF4444),
      WhatsappMediaType.images: const Color(0xFFF59E0B),
      WhatsappMediaType.voiceNotes: const Color(0xFF8B5CF6),
      WhatsappMediaType.documents: const Color(0xFF3B82F6),
    };
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: Row(
        children: [
          for (final type in [
            WhatsappMediaType.videos,
            WhatsappMediaType.images,
            WhatsappMediaType.voiceNotes,
            WhatsappMediaType.documents,
          ])
            Expanded(
              flex: ((controller.bytesByType[type] ?? 0) / total * 100)
                  .round()
                  .clamp(4, 100),
              child: Container(height: 6, color: colors[type]),
            ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: Color(0x8CFFFFFF), fontSize: 9),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.action});

  final String title;
  final String action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          action,
          style: const TextStyle(
            color: AppColors.whatsapp,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _TopStorageList extends StatelessWidget {
  const _TopStorageList({required this.items, required this.controller});

  final List<_WaTypeData> items;
  final WhatsappCleanerController controller;

  @override
  Widget build(BuildContext context) {
    final sorted = [...items]
      ..sort(
        (a, b) => (controller.bytesByType[b.type] ?? 0).compareTo(
          controller.bytesByType[a.type] ?? 0,
        ),
      );
    final maxBytes = sorted
        .map((item) => controller.bytesByType[item.type] ?? 0)
        .fold<int>(1, (max, value) => value > max ? value : max);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < sorted.length; i++) ...[
            _TopStorageRow(
              data: sorted[i],
              bytes: controller.bytesByType[sorted[i].type] ?? 0,
              count: controller.countByType[sorted[i].type] ?? 0,
              maxBytes: maxBytes,
            ),
            if (i != sorted.length - 1)
              Divider(
                height: 1,
                indent: 64,
                color: AppColors.borderFor(context),
              ),
          ],
        ],
      ),
    );
  }
}

class _TopStorageRow extends StatelessWidget {
  const _TopStorageRow({
    required this.data,
    required this.bytes,
    required this.count,
    required this.maxBytes,
  });

  final _WaTypeData data;
  final int bytes;
  final int count;
  final int maxBytes;

  @override
  Widget build(BuildContext context) {
    final progress = maxBytes <= 0 ? 0.0 : (bytes / maxBytes).clamp(0.05, 1.0);
    return InkWell(
      onTap: () => Get.to(() => WhatsappMediaView(type: data.type)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: data.color.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(data.icon, color: data.color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          data.title.tr,
                          style: TextStyle(
                            color: AppColors.textPrimary(context),
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        formatBytes(bytes),
                        style: const TextStyle(
                          color: AppColors.danger,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                      color: AppColors.whatsapp,
                      backgroundColor: AppColors.surfaceTint(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    count > 0 ? '$count files' : 'No files found',
                    style: TextStyle(
                      color: AppColors.textFaint(context),
                      fontSize: 10,
                    ),
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
  const _WaTypeCard({required this.data, required this.controller});

  final _WaTypeData data;
  final WhatsappCleanerController controller;

  @override
  Widget build(BuildContext context) {
    final bytes = controller.bytesByType[data.type] ?? 0;
    final count = controller.countByType[data.type] ?? 0;
    final title = switch (data.type) {
      WhatsappMediaType.videos => '$count group & chat videos',
      WhatsappMediaType.images => '$count saved & forwarded images',
      WhatsappMediaType.voiceNotes => '$count voice messages',
      WhatsappMediaType.documents => '$count PDFs & documents received',
    };
    final body = switch (data.type) {
      WhatsappMediaType.videos =>
        'Videos and downloaded media can pile up fast. Review before cleaning.',
      WhatsappMediaType.images =>
        'Repeated forwarded images found across chats. Keep what matters.',
      WhatsappMediaType.voiceNotes =>
        'Old voice notes are safe to review and clear when you are ready.',
      WhatsappMediaType.documents =>
        'Invoices, menus, flyers, and random files received through chat.',
    };
    final chip = switch (data.type) {
      WhatsappMediaType.videos => 'Heavy Media',
      WhatsappMediaType.images => 'Duplicates',
      WhatsappMediaType.voiceNotes => 'Voice Notes',
      WhatsappMediaType.documents => 'Documents',
    };
    return InkWell(
      onTap: () => Get.to(() => WhatsappMediaView(type: data.type)),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderFor(context)),
          boxShadow: AppColors.isLight(context)
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: data.color.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    chip,
                    style: TextStyle(
                      color: data.color,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '-${formatBytes(bytes)}',
                  style: const TextStyle(
                    color: AppColors.danger,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: data.color.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Icon(data.icon, color: data.color, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        count > 0 ? title : data.subtitle.tr,
                        style: TextStyle(
                          color: AppColors.textPrimary(context),
                          fontSize: 13,
                          height: 1.35,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        body,
                        style: TextStyle(
                          color: AppColors.textMuted(context),
                          fontSize: 12,
                          height: 1.35,
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
                Expanded(
                  child: _MiniActionButton(
                    label: 'Review',
                    icon: LucideIcons.eye,
                    foreground: AppColors.textMuted(context),
                    background: AppColors.surfaceTint(context),
                    border: AppColors.borderFor(context),
                    onTap: () =>
                        Get.to(() => WhatsappMediaView(type: data.type)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MiniActionButton(
                    label: 'Clean',
                    icon: LucideIcons.check,
                    foreground: const Color(0xFF16A34A),
                    background: const Color(0xFFDCFCE7),
                    onTap: () =>
                        Get.to(() => WhatsappMediaView(type: data.type)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniActionButton extends StatelessWidget {
  const _MiniActionButton({
    required this.label,
    required this.icon,
    required this.foreground,
    required this.background,
    required this.onTap,
    this.border,
  });

  final String label;
  final IconData icon;
  final Color foreground;
  final Color background;
  final Color? border;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: TextButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 13),
        label: Text(label),
        style: TextButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          side: border == null ? null : BorderSide(color: border!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

// class _WaCleanButton extends StatelessWidget {
//   const _WaCleanButton({required this.controller});

//   final WhatsappCleanerController controller;

//   @override
//   Widget build(BuildContext context) {
// return Container(
//   padding: const EdgeInsets.fromLTRB(16, 13, 16, 16),
//   decoration: BoxDecoration(
//     color: AppColors.bottomBar(context),
//     border: Border(top: BorderSide(color: AppColors.borderFor(context))),
//     boxShadow: const [
//       BoxShadow(
//         color: Color(0x10000000),
//         blurRadius: 10,
//         offset: Offset(0, -4),
//       ),
//     ],
//   ),
//   child: SizedBox(
//     height: 52,
//     width: double.infinity,
//     child: TextButton.icon(
//       onPressed: () => Get.to(
//         () => const WhatsappMediaView(type: WhatsappMediaType.videos),
//       ),
//       icon: const Icon(LucideIcons.messageCircle, size: 16),
//       label: Text(
//         'Clean WhatsApp - Free ${formatBytes(controller.totalBytes)}',
//       ),
//       style: TextButton.styleFrom(
//         backgroundColor: AppColors.whatsapp,
//         foregroundColor: Colors.white,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(28),
//         ),
//         textStyle: const TextStyle(
//           fontSize: 14,
//           fontWeight: FontWeight.w800,
//         ),
//       ),
//     ),
//   ),
// );
// }
// }

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
      return CenteredStateView(
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
      return CenteredStateView(
        icon: _typeIcon(controller.type),
        title: 'No ${controller.type.title.toLowerCase()} found',
        body:
            'WhatsApp ${controller.type.title.toLowerCase()} will appear here when found on this phone.',
        primaryLabel: 'Refresh',
        onPrimary: controller.loadItems,
      );
    }

    return RefreshIndicator(
      color: AppColors.accent,
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
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: (MediaQuery.sizeOf(context).width / 130)
                      .floor()
                      .clamp(3, 6),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.78,
                ),
                itemBuilder: (context, index) {
                  final item = controller.items[index];
                  return RepaintBoundary(
                    child: _WaGridItem(
                      item: item,
                      type: controller.type,
                      selected: controller.isSelected(item),
                      onTap: () => controller.toggleItem(item),
                    ),
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
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.borderFor(context),
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
                _WaVideoThumb(path: item.path),
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
                child: SelectionCheckMark(selected: selected),
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

/// Renders a thumbnail frame for a WhatsApp video file. Frames are generated
/// once per path and cached, with a video-icon placeholder while loading or if
/// a frame can't be produced.
class _WaVideoThumb extends StatefulWidget {
  const _WaVideoThumb({required this.path});

  final String path;

  @override
  State<_WaVideoThumb> createState() => _WaVideoThumbState();
}

class _WaVideoThumbState extends State<_WaVideoThumb> {
  static final Map<String, Uint8List?> _cache = <String, Uint8List?>{};

  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    if (_cache.containsKey(widget.path)) {
      _bytes = _cache[widget.path];
    } else {
      _generate();
    }
  }

  Future<void> _generate() async {
    Uint8List? data;
    try {
      data = await VideoThumbnail.thumbnailData(
        video: widget.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 256,
        quality: 60,
      );
    } catch (_) {
      data = null;
    }
    _cache[widget.path] = data;
    if (!mounted) {
      return;
    }
    setState(() => _bytes = data);
  }

  @override
  Widget build(BuildContext context) {
    if (_bytes != null) {
      return Image.memory(_bytes!, fit: BoxFit.cover, gaplessPlayback: true);
    }
    return const ColoredBox(
      color: Color(0xFF172133),
      child: Center(
        child: Icon(LucideIcons.video, color: Color(0xFFE36F64), size: 28),
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
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.borderFor(context),
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
            SelectionCheckMark(selected: selected),
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
          foregroundColor: AppColors.accent,
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
            disabledBackgroundColor: AppColors.surfaceTint(context),
            disabledForegroundColor: AppColors.textFaint(context),
            backgroundColor: AppColors.danger,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmAndDelete(WhatsappMediaController controller) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text(
          'Delete selected?',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: Text(
          'This will delete ${controller.selectedCount} WhatsApp ${controller.type.title.toLowerCase()} from your phone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
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
