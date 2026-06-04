import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/sift_top_app_bar.dart';
import 'package:sift/app/paywall/paywall_controller.dart';

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
                            _SubscriptionCard(controller: controller),
                            const SizedBox(height: 12),
                            _ActionPanel(
                              rows: [
                                _ActionRowData(
                                  icon: LucideIcons.settings,
                                  title: 'Manage subscription'.tr,
                                  subtitle: controller.manageSubtitle,
                                  trailing: LucideIcons.externalLink,
                                  isLoading: controller.isPurchasing,
                                  onTap: controller.purchaseCleanerPro,
                                ),
                                _ActionRowData(
                                  icon: LucideIcons.x,
                                  title: 'Cancel subscription'.tr,
                                  subtitle: 'One tap. No retention popup.'.tr,
                                ),
                                _ActionRowData(
                                  icon: LucideIcons.undo2,
                                  title: 'Request refund'.tr,
                                  subtitle: 'Restore RevenueCat purchases'.tr,
                                  onTap: controller.restoreCleanerPro,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const _TrustCard(),
                            const SizedBox(height: 16),
                            _SectionLabel('RECENT RECEIPTS'.tr),
                            const SizedBox(height: 9),
                            const _ReceiptTile(),
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

class _SubscriptionCard extends StatelessWidget {
  const _SubscriptionCard({required this.controller});

  final PaywallController controller;

  @override
  Widget build(BuildContext context) {
    final light = AppColors.isLight(context);
    return Container(
      height: 186,
      padding: const EdgeInsets.fromLTRB(15, 12, 15, 13),
      decoration: BoxDecoration(
        color: light ? AppColors.lightSurfaceTint : const Color(0xFF08232D),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: light ? const Color(0xFF9FD8CF) : const Color(0xFF0D5C65),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 25,
                height: 25,
                decoration: const BoxDecoration(
                  color: Color(0xFF18D0B8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.crown,
                  color: Color(0xFF062322),
                  size: 14,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 1),
                    Text(
                      'Clean Byte Pro'.tr,
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 16,
                        height: 1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Yearly subscription'.tr,
                      style: TextStyle(
                        color: AppColors.textMuted(context),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const _ActiveBadge(),
            ],
          ),
          const SizedBox(height: 17),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                controller.price,
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 30,
                  height: 0.9,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  controller.cadence,
                  style: TextStyle(
                    color: AppColors.textMuted(context),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            'That\'s ${controller.weeklyPrice} per week',
            style: TextStyle(
              color: AppColors.textMuted(context),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          const Gap(2),
          Divider(height: 1, color: AppColors.borderFor(context)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _PlanDate(
                  label: 'NEXT RENEWAL'.tr,
                  value: 'Mar 8, 2027',
                ),
              ),
              _PlanDate(label: 'MEMBER SINCE'.tr, value: 'Mar 8, 2026'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActiveBadge extends StatelessWidget {
  const _ActiveBadge();

  @override
  Widget build(BuildContext context) {
    final light = AppColors.isLight(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircleAvatar(radius: 2.5, backgroundColor: Color(0xFF18D0B8)),
        const SizedBox(width: 6),
        Text(
          'ACTIVE'.tr,
          style: TextStyle(
            color: light ? const Color(0xFF0E8F80) : const Color(0xFF4FF0D8),
            fontSize: 7,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _PlanDate extends StatelessWidget {
  const _PlanDate({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textFaint(context),
            fontSize: 7,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _ActionPanel extends StatelessWidget {
  const _ActionPanel({required this.rows});

  final List<_ActionRowData> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            _ActionRow(data: rows[i]),
            if (i != rows.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                color: AppColors.borderFor(context),
                indent: 45,
              ),
          ],
        ],
      ),
    );
  }
}

class _ActionRowData {
  const _ActionRowData({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing = LucideIcons.chevronRight,
    this.isLoading = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final IconData trailing;
  final bool isLoading;
  final VoidCallback? onTap;
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.data});

  final _ActionRowData data;

  @override
  Widget build(BuildContext context) {
    final light = AppColors.isLight(context);
    return InkWell(
      onTap: data.isLoading ? null : data.onTap,
      child: SizedBox(
        height: 60,
        child: Row(
          children: [
            const SizedBox(width: 11),
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: light ? AppColors.lightSurfaceTint : const Color(0xFF1B2334),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderFor(context)),
              ),
              child: Icon(data.icon, color: AppColors.textMuted(context), size: 15),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    data.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textMuted(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            if (data.isLoading)
              const SizedBox(
                width: 15,
                height: 15,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF18D0B8),
                ),
              )
            else
              Icon(data.trailing, color: AppColors.textFaint(context), size: 15),
            const SizedBox(width: 13),
          ],
        ),
      ),
    );
  }
}

class _TrustCard extends StatelessWidget {
  const _TrustCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 13, 13, 13),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.shieldCheck, color: Color(0xFF11A982), size: 17),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No tricks, no traps.'.tr,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 11),
                Text(
                  'We only earn money when you stay because the app is useful. Cancel any time, no hard feelings - and yes, we\'ll refund the year if you change your mind.'
                      .tr,
                  style: TextStyle(
                    color: AppColors.textMuted(context),
                    fontSize: 12,
                    height: 1.42,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: AppColors.textFaint(context),
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 3,
      ),
    );
  }
}

class _ReceiptTile extends StatelessWidget {
  const _ReceiptTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.fromLTRB(11, 10, 11, 9),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Clean Byte Pro - Monthly'.tr,
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mar 8, 2026',
                      style: TextStyle(
                        color: AppColors.textFaint(context),
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '\$4.99',
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const Gap(12),
          Divider(height: 1, color: AppColors.borderFor(context)),
          const Gap(12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Clean Byte Pro - Yearly'.tr,
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mar 8, 2026',
                      style: TextStyle(
                        color: AppColors.textFaint(context),
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '\$34.99',
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
