import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sift/app/components/app_colors.dart';

/// Bottom sheet listing the help / FAQ entries.
class FaqSheet extends StatelessWidget {
  const FaqSheet({super.key});

  static const _faqs = [
    (
      'Are my photos uploaded anywhere?',
      'No. All scanning happens on your device — nothing is ever uploaded to a server.',
    ),
    (
      'Where do deleted items go?',
      'To the Recycle Bin for 30 days, so you can restore anything you change your mind about.',
    ),
    (
      'Will cleaning delete my originals?',
      'Only the copies you confirm. For similar photos, the best of each group is always kept.',
    ),
    (
      'How does Smart Scan work?',
      'It groups similar photos, screenshots and large files locally so you can review and free space safely.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(14),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.borderFor(context)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Help & FAQs',
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _faqs.length,
                separatorBuilder: (_, _) =>
                    Divider(height: 22, color: AppColors.borderFor(context)),
                itemBuilder: (context, index) {
                  final faq = _faqs[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        faq.$1,
                        style: TextStyle(
                          color: AppColors.textPrimary(context),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        faq.$2,
                        style: TextStyle(
                          color: AppColors.textMuted(context),
                          fontSize: 13,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: Get.back,
                child: Text(
                  'Close',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
