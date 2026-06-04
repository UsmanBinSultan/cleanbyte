import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/cleaner_screen_scaffold.dart';
import 'package:sift/app/routes/app_routes.dart';

class SubscriptionView extends StatelessWidget {
  const SubscriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    return const CleanerScreenScaffold(
      config: CleanerScreenConfig(
        title: 'No tricks, no traps.',
        kicker: '16 - SUBSCRIPTION',
        subtitle:
            'A trust-first subscription screen with real manage, cancel, refund, and receipt areas.',
        icon: LucideIcons.crown,
        route: AppRoutes.subscription,
        nextRoute: null,
        accent: AppColors.accent,
        primaryAction: 'Back to dashboard',
        stats: [
          MetricTile('Plan', 'Pro', AppColors.accent),
          MetricTile('Yearly', '\$34.99', AppColors.amber),
          MetricTile('Renewal', 'Mar 2027', AppColors.fg),
          MetricTile('Status', 'Active', AppColors.sage),
        ],
        items: [
          FeatureRow(
            'Manage subscription',
            'Opens platform subscriptions.',
            LucideIcons.settings,
            AppColors.accent,
          ),
          FeatureRow(
            'Cancel subscription',
            'One tap. No retention popup.',
            LucideIcons.x,
            AppColors.coral,
          ),
          FeatureRow(
            'Request refund',
            'In-app form with clear expectations.',
            LucideIcons.undo2,
            AppColors.sage,
          ),
        ],
      ),
    );
  }
}
