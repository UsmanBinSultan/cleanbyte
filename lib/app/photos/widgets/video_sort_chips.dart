import 'package:flutter/material.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/photos/photos_controller.dart';

/// Largest / Oldest / Recent sort chips for the large-videos list.
class VideoSortChips extends StatelessWidget {
  const VideoSortChips({super.key, required this.controller});

  final SimilarPhotosController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _chip(context, 'Largest', VideoSort.largest),
        const SizedBox(width: 8),
        _chip(context, 'Oldest', VideoSort.oldest),
        const SizedBox(width: 8),
        _chip(context, 'Recent', VideoSort.recent),
      ],
    );
  }

  Widget _chip(BuildContext context, String label, VideoSort sort) {
    final active = controller.videoSort == sort;
    return InkWell(
      onTap: () => controller.setVideoSort(sort),
      borderRadius: BorderRadius.circular(99),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
    );
  }
}
