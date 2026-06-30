import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/sift_top_app_bar.dart';
import 'package:sift/app/whatsapp_cleaner/whatsapp_cleaner_controller.dart';

/// App bar for a WhatsApp media list with a select-all / clear toggle.
class WaMediaHeader extends StatelessWidget {
  const WaMediaHeader({super.key, required this.controller});

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
        child: Text(allSelected ? 'clear'.tr : 'select all'.tr),
      ),
    );
  }
}
