import 'package:flutter/material.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/photos/photos_controller.dart';

/// Horizontal "All / year / Older" age filter chips for screenshots.
class ScreenshotYearChips extends StatelessWidget {
  const ScreenshotYearChips({super.key, required this.controller});

  final SimilarPhotosController controller;

  @override
  Widget build(BuildContext context) {
    final years = controller.screenshotYears;
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _chip(context, 'All', null),
          for (final year in years) _chip(context, '$year', year),
          _chip(context, 'Older', 0),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String label, int? value) {
    final active = controller.screenshotYear == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => controller.setScreenshotYear(value),
        borderRadius: BorderRadius.circular(99),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: active ? AppColors.accent : AppColors.surface(context),
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
              color: active ? AppColors.accent : AppColors.borderFor(context),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : AppColors.textMuted(context),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
