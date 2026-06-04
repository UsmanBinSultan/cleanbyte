import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_button.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/routes/app_routes.dart';

class CleanerScreenConfig {
  const CleanerScreenConfig({
    required this.title,
    required this.kicker,
    required this.subtitle,
    required this.icon,
    required this.route,
    required this.nextRoute,
    required this.accent,
    required this.stats,
    required this.items,
    this.primaryAction = 'Continue',
    this.showBack = true,
  });

  final String title;
  final String kicker;
  final String subtitle;
  final IconData icon;
  final String route;
  final String? nextRoute;
  final Color accent;
  final List<MetricTile> stats;
  final List<FeatureRow> items;
  final String primaryAction;
  final bool showBack;
}

class MetricTile {
  const MetricTile(this.label, this.value, this.tone);

  final String label;
  final String value;
  final Color tone;
}

class FeatureRow {
  const FeatureRow(this.title, this.subtitle, this.icon, this.tone);

  final String title;
  final String subtitle;
  final IconData icon;
  final Color tone;
}

class CleanerScreenScaffold extends StatelessWidget {
  const CleanerScreenScaffold({super.key, required this.config});

  final CleanerScreenConfig config;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final maxWidth = math.min(width, 520).toDouble();
    final light = AppColors.isLight(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -1.0),
            radius: 1.15,
            colors: light
                ? const [Color(0xFFFFFFFF), AppColors.lightBg]
                : const [Color(0xFF0D1424), AppColors.bgDeep],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _TopBar(config: config)),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
                    sliver: SliverList.list(
                      children: [
                        _HeroPanel(config: config),
                        const SizedBox(height: 16),
                        _MetricGrid(stats: config.stats),
                        const SizedBox(height: 18),
                        _SectionLabel(config.kicker),
                        const SizedBox(height: 10),
                        _FeatureList(items: config.items),
                        const SizedBox(height: 18),
                        AppButton(
                          label: config.primaryAction,
                          icon: config.nextRoute == null
                              ? LucideIcons.check
                              : LucideIcons.arrowRight,
                          onPressed: () {
                            if (config.nextRoute == null) {
                              Get.offAllNamed(AppRoutes.homeDashboard);
                            } else {
                              Get.toNamed(config.nextRoute!);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.config});

  final CleanerScreenConfig config;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: config.showBack ? Get.back : null,
            icon: Icon(
              config.showBack ? LucideIcons.chevronLeft : LucideIcons.sparkles,
              color: config.showBack ? AppColors.accent : config.accent,
            ),
          ),
          Expanded(
            child: Text(
              config.kicker,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.isLight(context)
                    ? AppColors.lightFgFaint
                    : AppColors.fgFaint,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.9,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.subscription),
            icon: const Icon(LucideIcons.settings, color: AppColors.accent),
          ),
        ],
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.config});

  final CleanerScreenConfig config;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.isLight(context)
              ? AppColors.lightBorder
              : AppColors.borderStrong,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.isLight(context)
              ? [
                  config.accent.withValues(alpha: 0.12),
                  AppColors.lightSurface,
                  AppColors.lightSurfaceTint,
                ]
              : [
                  config.accent.withValues(alpha: 0.18),
                  AppColors.surface1,
                  AppColors.bg.withValues(alpha: 0.8),
                ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [config.accent, config.accent.withValues(alpha: 0.55)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(config.icon, color: AppColors.bgDeep, size: 32),
          ),
          const SizedBox(height: 26),
          Text(
            config.title,
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 38,
              height: 0.98,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            config.subtitle,
            style: TextStyle(
              color: AppColors.isLight(context)
                  ? AppColors.lightFgMuted
                  : AppColors.fgMuted,
              fontSize: 15,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.stats});

  final List<MetricTile> stats;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.55,
      ),
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.isLight(context)
                ? AppColors.lightSurface
                : AppColors.surface1,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.isLight(context)
                  ? AppColors.lightBorder
                  : AppColors.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                stat.label.toUpperCase(),
                style: TextStyle(
                  color: AppColors.isLight(context)
                      ? AppColors.lightFgFaint
                      : AppColors.fgFaint,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                stat.value,
                style: TextStyle(
                  color: stat.tone,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: AppColors.isLight(context)
            ? AppColors.lightFgFaint
            : AppColors.fgFaint,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.8,
      ),
    );
  }
}

class _FeatureList extends StatelessWidget {
  const _FeatureList({required this.items});

  final List<FeatureRow> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.isLight(context)
            ? AppColors.lightSurface
            : AppColors.surface1,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.isLight(context)
              ? AppColors.lightBorder
              : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            _FeatureItem(item: items[index]),
            if (index != items.length - 1)
              Divider(height: 1, color: AppColors.borderFor(context)),
          ],
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({required this.item});

  final FeatureRow item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: item.tone.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: item.tone.withValues(alpha: 0.28)),
            ),
            child: Icon(item.icon, color: item.tone, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: TextStyle(
                    color: AppColors.isLight(context)
                        ? AppColors.lightFgMuted
                        : AppColors.fgMuted,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Directionality.of(context) == TextDirection.rtl
                ? LucideIcons.chevronLeft
                : LucideIcons.chevronRight,
            color: AppColors.isLight(context)
                ? AppColors.lightFgFaint
                : AppColors.fgFaint,
            size: 17,
          ),
        ],
      ),
    );
  }
}
