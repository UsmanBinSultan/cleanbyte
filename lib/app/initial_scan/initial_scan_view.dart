import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/initial_scan/initial_scan_controller.dart';
import 'package:sift/app/initial_scan/widgets/ai_sorting_note.dart';
import 'package:sift/app/initial_scan/widgets/category_chips.dart';
import 'package:sift/app/initial_scan/widgets/found_so_far.dart';
import 'package:sift/app/initial_scan/widgets/live_scan_card.dart';
import 'package:sift/app/initial_scan/widgets/scan_actions.dart';
import 'package:sift/app/initial_scan/widgets/scan_top_bar.dart';

/// "Smart Scan" progress screen. Sub-widgets live under `widgets/`.
class InitialScanView extends StatelessWidget {
  const InitialScanView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InitialScanController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.pageBackground(context),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Column(
                  children: [
                    ScanTopBar(controller: controller),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LiveScanCard(controller: controller),
                            const SizedBox(height: 16),
                            CategoryChips(controller: controller),
                            const SizedBox(height: 22),
                            FoundSoFar(controller: controller),
                            const SizedBox(height: 18),
                            ScanActions(controller: controller),
                            const SizedBox(height: 14),
                            const AiSortingNote(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
