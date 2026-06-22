import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/whatsapp_cleaner/whatsapp_cleaner_controller.dart';
import 'package:sift/app/whatsapp_cleaner/widgets/wa_type_data.dart';
import 'package:sift/app/whatsapp_cleaner/whatsapp_media_view.dart';
import 'package:sift/core/utils/formatters.dart';

/// Card listing the WhatsApp media types ranked by storage, each with a usage
/// bar. Tapping a row opens that type's media list.
class WaTopStorageList extends StatelessWidget {
  const WaTopStorageList({
    super.key,
    required this.items,
    required this.controller,
  });

  final List<WaTypeData> items;
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

  final WaTypeData data;
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
