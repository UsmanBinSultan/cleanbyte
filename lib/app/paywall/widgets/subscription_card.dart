import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/paywall/paywall_controller.dart';

/// The Clean Byte Pro plan summary card: crown header, price, weekly breakdown
/// and the renewal / member-since dates.
class SubscriptionCard extends StatelessWidget {
  const SubscriptionCard({super.key, required this.controller});

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
                  color: AppColors.accent,
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
        const CircleAvatar(radius: 2.5, backgroundColor: AppColors.accent),
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
