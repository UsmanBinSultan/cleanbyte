import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/sift_top_app_bar.dart';
import 'package:sift/app/paywall/paywall_controller.dart';
import 'package:sift/app/paywall/widgets/action_panel.dart';
import 'package:sift/app/paywall/widgets/paywall_section_label.dart';
import 'package:sift/app/paywall/widgets/receipt_tile.dart';
import 'package:sift/app/paywall/widgets/subscription_card.dart';
import 'package:sift/app/paywall/widgets/trust_card.dart';

/// Subscription / paywall screen. Sub-widgets live under `widgets/`.
class PaywallView extends StatelessWidget {
  const PaywallView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PaywallController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.pageBackground(context),
          body: SafeArea(
            child: Column(
              children: [
                SiftTopAppBar(title: 'Subscription'.tr),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 430),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(19, 0, 19, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SubscriptionCard(controller: controller),
                            const SizedBox(height: 12),
                            ActionPanel(
                              rows: [
                                ActionRowData(
                                  icon: LucideIcons.settings,
                                  title: 'Manage subscription'.tr,
                                  subtitle: controller.manageSubtitle,
                                  trailing: LucideIcons.externalLink,
                                  isLoading: controller.isPurchasing,
                                  onTap: controller.purchaseCleanerPro,
                                ),
                                ActionRowData(
                                  icon: LucideIcons.x,
                                  title: 'Cancel subscription'.tr,
                                  subtitle: 'One tap. No retention popup.'.tr,
                                ),
                                ActionRowData(
                                  icon: LucideIcons.undo2,
                                  title: 'Request refund'.tr,
                                  subtitle: 'Restore RevenueCat purchases'.tr,
                                  onTap: controller.restoreCleanerPro,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const TrustCard(),
                            const SizedBox(height: 16),
                            PaywallSectionLabel('RECENT RECEIPTS'.tr),
                            const SizedBox(height: 9),
                            const ReceiptTile(),
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
