import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/initial_scan/initial_scan_controller.dart';

/// Row of category icons (photos/files/screenshots/videos/contacts) that gain a
/// check badge as the scan progresses through each stage.
class CategoryChips extends StatelessWidget {
  const CategoryChips({super.key, required this.controller});

  final InitialScanController controller;

  @override
  Widget build(BuildContext context) {
    final chips = [
      (LucideIcons.image, 'Photos', AppColors.accent, AppColors.tintTeal),
      (LucideIcons.folder, 'Files', AppColors.iconBlue, AppColors.tintBlue),
      (
        LucideIcons.smartphone,
        'Screenshots',
        AppColors.iconPurple,
        AppColors.tintPurple,
      ),
      (LucideIcons.video, 'Videos', AppColors.iconAmber, AppColors.tintAmber),
      (LucideIcons.users, 'Contacts', AppColors.iconPink, AppColors.tintPink),
    ];
    final done = controller.stageIndex;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var i = 0; i < chips.length; i++)
          Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.iconChipBg(
                        context,
                        chips[i].$3,
                        chips[i].$4,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(chips[i].$1, color: chips[i].$3, size: 20),
                  ),
                  if (i < done + 1)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.pageBackground(context),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          LucideIcons.check,
                          size: 8,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                chips[i].$2,
                style: TextStyle(
                  color: AppColors.textMuted(context),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
