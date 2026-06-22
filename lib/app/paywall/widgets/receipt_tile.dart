import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:sift/app/components/app_colors.dart';

/// Recent receipts card showing the monthly and yearly Clean Byte Pro charges.
class ReceiptTile extends StatelessWidget {
  const ReceiptTile({super.key});

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
          _ReceiptRow(
            title: 'Clean Byte Pro - Monthly'.tr,
            date: 'Mar 8, 2026',
            amount: '\$4.99',
          ),
          const Gap(12),
          Divider(height: 1, color: AppColors.borderFor(context)),
          const Gap(12),
          _ReceiptRow(
            title: 'Clean Byte Pro - Yearly'.tr,
            date: 'Mar 8, 2026',
            amount: '\$34.99',
          ),
        ],
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({
    required this.title,
    required this.date,
    required this.amount,
  });

  final String title;
  final String date;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
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
          amount,
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
