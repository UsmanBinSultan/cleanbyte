import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:get/get.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/centered_state_view.dart';
import 'package:sift/app/components/loading_shimmer.dart';
import 'package:sift/app/whatsapp_cleaner/whatsapp_cleaner_controller.dart';
import 'package:sift/app/whatsapp_cleaner/widgets/wa_grid_item.dart';
import 'package:sift/app/whatsapp_cleaner/widgets/wa_list_item.dart';
import 'package:sift/app/whatsapp_cleaner/widgets/wa_media_delete_button.dart';
import 'package:sift/app/whatsapp_cleaner/widgets/wa_media_header.dart';
import 'package:sift/app/whatsapp_cleaner/widgets/wa_media_summary.dart';
import 'package:sift/app/whatsapp_cleaner/widgets/wa_media_type_visuals.dart';

/// The selectable WhatsApp media list for a single [WhatsappMediaType],
/// rendered as a grid (images/videos) or a list (voice notes/documents).
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
                WaMediaHeader(controller: controller),
                Expanded(child: _MediaBody(controller: controller)),
                WaMediaDeleteButton(controller: controller),
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
        icon: whatsappTypeIcon(controller.type),
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
              child: WaMediaSummary(controller: controller),
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
                    child: WaGridItem(
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
                  return WaListItem(
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
