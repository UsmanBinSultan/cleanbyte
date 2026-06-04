import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/cleaner_screen_scaffold.dart';
import 'package:sift/app/routes/app_routes.dart';

class ProcessManagerView extends StatelessWidget {
  const ProcessManagerView({super.key});

  @override
  Widget build(BuildContext context) {
    return const CleanerScreenScaffold(
      config: CleanerScreenConfig(
        title: 'Process manager.',
        kicker: '11 - TOOLS',
        subtitle:
            'A careful utility screen that explains what can be stopped and why.',
        icon: LucideIcons.cpu,
        route: AppRoutes.processManager,
        nextRoute: AppRoutes.whatsappCleaner,
        accent: AppColors.sage,
        stats: [
          MetricTile('Running', '18', AppColors.fg),
          MetricTile('Idle', '7', AppColors.amber),
          MetricTile('Memory', '1.9 GB', AppColors.accent),
          MetricTile('Risk', 'Low', AppColors.sage),
        ],
        items: [
          FeatureRow(
            'Background helpers',
            'Review low-priority processes.',
            LucideIcons.circle,
            AppColors.amber,
          ),
          FeatureRow(
            'Memory view',
            'See estimated memory pressure.',
            LucideIcons.activity,
            AppColors.accent,
          ),
          FeatureRow(
            'No fake speed claims',
            'The screen stays honest about limits.',
            LucideIcons.shield,
            AppColors.sage,
          ),
        ],
      ),
    );
  }
}
