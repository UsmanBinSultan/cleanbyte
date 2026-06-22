import 'package:flutter/material.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/whatsapp_cleaner/whatsapp_cleaner_controller.dart';
import 'package:sift/core/utils/formatters.dart';

/// File count + total size header shown above a WhatsApp media list.
class WaMediaSummary extends StatelessWidget {
  const WaMediaSummary({super.key, required this.controller});

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
