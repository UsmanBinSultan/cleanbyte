import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/sift_bottom_nav_bar.dart';
import 'package:sift/app/components/sift_top_app_bar.dart';
import 'package:sift/app/whatsapp_cleaner/whatsapp_cleaner_controller.dart';
import 'package:sift/app/whatsapp_cleaner/widgets/wa_section_header.dart';
import 'package:sift/app/whatsapp_cleaner/widgets/wa_summary_card.dart';
import 'package:sift/app/whatsapp_cleaner/widgets/wa_top_storage_list.dart';
import 'package:sift/app/whatsapp_cleaner/widgets/wa_type_card.dart';
import 'package:sift/app/whatsapp_cleaner/widgets/wa_type_data.dart';

/// WhatsApp cleaner hub: a storage hero card, the per-type storage ranking and
/// cleanup-insight cards. Sub-widgets live under `widgets/`; the per-type media
/// list lives in `whatsapp_media_view.dart`.
class WhatsappCleanerView extends StatelessWidget {
  const WhatsappCleanerView({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      WaTypeData(
        'images',
        'open whatsapp photos',
        LucideIcons.image,
        const Color(0xFFD7B451),
        WhatsappMediaType.images,
      ),
      WaTypeData(
        'videos',
        'open whatsapp videos',
        LucideIcons.video,
        const Color(0xFFE36F64),
        WhatsappMediaType.videos,
      ),
      WaTypeData(
        'voice notes',
        'open voice notes',
        LucideIcons.mic,
        const Color(0xFF9B4FC7),
        WhatsappMediaType.voiceNotes,
      ),
      WaTypeData(
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
        final foundCount = items
            .where((item) => (controller.bytesByType[item.type] ?? 0) > 0)
            .length;

        return Scaffold(
          backgroundColor: AppColors.pageBackground(context),
          bottomNavigationBar: fromNav
              ? const SiftBottomNavBar(activeIndex: 3)
              : null,
          body: SafeArea(
            bottom: !fromNav,
            child: Column(
              children: [
                SiftTopAppBar(title: 'WhatsApp Cleaner', showBack: !fromNav),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, fromNav ? 96 : 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: controller.loadSummary,
                          borderRadius: BorderRadius.circular(18),
                          child: WaSummaryCard(controller: controller),
                        ),
                        const SizedBox(height: 18),
                        WaSectionHeader(
                          title: 'Top chats by storage',
                          action: '$foundCount found',
                        ),
                        const SizedBox(height: 10),
                        WaTopStorageList(items: items, controller: controller),
                        const SizedBox(height: 18),
                        WaSectionHeader(
                          title: 'Cleanup Insights',
                          action: '$foundCount found',
                        ),
                        const SizedBox(height: 10),
                        for (final item in items) ...[
                          WaTypeCard(data: item, controller: controller),
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
