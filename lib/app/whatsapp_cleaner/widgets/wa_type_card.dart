import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/whatsapp_cleaner/whatsapp_cleaner_controller.dart';
import 'package:sift/app/whatsapp_cleaner/widgets/wa_type_data.dart';
import 'package:sift/app/whatsapp_cleaner/whatsapp_media_view.dart';
import 'package:sift/core/utils/formatters.dart';

/// Cleanup-insight card for one WhatsApp media type: a category chip, recoverable
/// size, descriptive copy and Review / Clean actions.
class WaTypeCard extends StatelessWidget {
  const WaTypeCard({super.key, required this.data, required this.controller});

  final WaTypeData data;
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
