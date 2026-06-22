import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sift/app/battery_manager/battery_manager_controller.dart';
import 'package:sift/app/battery_manager/widgets/apply_button.dart';
import 'package:sift/app/battery_manager/widgets/battery_card.dart';
import 'package:sift/app/battery_manager/widgets/battery_section_label.dart';
import 'package:sift/app/battery_manager/widgets/battery_tips.dart';
import 'package:sift/app/battery_manager/widgets/extra_battery_card.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/sift_top_app_bar.dart';

/// Battery Manager: health summary, estimated savings, care tips and an
/// apply-all action. Sub-widgets live under `widgets/`.
class BatteryManagerView extends StatelessWidget {
  const BatteryManagerView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BatteryManagerController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.pageBackground(context),
          body: SafeArea(
            child: Column(
              children: [
                SiftTopAppBar(
                  title: 'battery_manager'.tr,
                  subtitle: 'Health & Optimisations',
                ),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: RefreshIndicator(
                        color: AppColors.accent,
                        backgroundColor: AppColors.surface(context),
                        onRefresh: controller.loadBattery,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                          children: [
                            BatteryCard(controller: controller),
                            const SizedBox(height: 14),
                            ExtraBatteryCard(controller: controller),
                            const SizedBox(height: 22),
                            BatterySectionLabel(label: 'Battery Tips'),
                            const SizedBox(height: 10),
                            const BatteryTips(),
                            const SizedBox(height: 22),
                            ApplyButton(controller: controller),
                            const SizedBox(height: 8),
                            Center(
                              child: Text(
                                'Settings can be changed at any time',
                                style: TextStyle(
                                  color: AppColors.textFaint(context),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
