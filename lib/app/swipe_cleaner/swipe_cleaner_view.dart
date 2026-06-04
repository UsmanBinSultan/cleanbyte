import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/cleaner_screen_scaffold.dart';
import 'package:sift/app/routes/app_routes.dart';

class SwipeCleanerView extends StatelessWidget {
  const SwipeCleanerView({super.key});

  @override
  Widget build(BuildContext context) {
    return const CleanerScreenScaffold(
      config: CleanerScreenConfig(
        title: 'Swipe through clutter.',
        kicker: '09 - SWIPE CLEANER',
        subtitle:
            'A viral review mode for quick decisions: keep favorites, delete obvious clutter, undo mistakes.',
        icon: LucideIcons.heart,
        route: AppRoutes.swipeCleaner,
        nextRoute: AppRoutes.aiCategories,
        accent: AppColors.coral,
        stats: [
          MetricTile('Stack', '42', AppColors.coral),
          MetricTile('Keep', '18', AppColors.sage),
          MetricTile('Delete', '24', AppColors.amber),
          MetricTile('Saved', '1.2 GB', AppColors.accent),
        ],
        items: [
          FeatureRow(
            'Swipe left',
            'Send weak duplicates to cleanup.',
            LucideIcons.trash,
            AppColors.coral,
          ),
          FeatureRow(
            'Swipe right',
            'Protect the photo as a keeper.',
            LucideIcons.heart,
            AppColors.sage,
          ),
          FeatureRow(
            'Undo',
            'Recover the last decision instantly.',
            LucideIcons.undo2,
            AppColors.amber,
          ),
        ],
      ),
    );
  }
}
