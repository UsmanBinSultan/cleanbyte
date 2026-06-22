import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/home_dashboard/home_dashboard_controller.dart';
import 'package:sift/app/routes/app_routes.dart';

/// "Today's Suggestions" — a card of up to four recommended actions derived
/// from the live cleanup metrics, with a count badge.
class TodaysSuggestions extends StatelessWidget {
  const TodaysSuggestions({super.key, required this.controller});

  final HomeDashboardController controller;

  List<_Suggestion> _build() {
    final suggestions = <_Suggestion>[];
    void add(
      String key,
      String Function(int count) title,
      IconData icon,
      Color color,
      Color tint,
      String route,
    ) {
      final metric = controller.metric(key);
      if (metric.count <= 0) return;
      final savings = metric.bytes > 0
          ? '~${HomeDashboardController.formatBytes(metric.bytes)} potential savings'
          : '${metric.count} to review';
      suggestions.add(
        _Suggestion(
          title: title(metric.count),
          subtitle: savings,
          icon: icon,
          color: color,
          tint: tint,
          route: route,
        ),
      );
    }

    add(
      HomeDashboardController.similarPhotosKey,
      (c) => 'Review $c photos',
      LucideIcons.search,
      AppColors.accent,
      AppColors.tintMint,
      AppRoutes.similarPhotos,
    );
    add(
      HomeDashboardController.largeVideosKey,
      (c) => 'Delete $c large videos',
      LucideIcons.video,
      AppColors.iconAmber,
      AppColors.tintAmber,
      AppRoutes.largeVideos,
    );
    add(
      HomeDashboardController.screenshotsKey,
      (c) => 'Delete $c old screenshots',
      LucideIcons.smartphone,
      AppColors.iconPurple,
      AppColors.tintPurple,
      AppRoutes.screenshots,
    );
    add(
      HomeDashboardController.duplicateContactsKey,
      (c) => 'Merge $c duplicate contacts',
      LucideIcons.users,
      AppColors.iconBlue,
      AppColors.tintBlue,
      AppRoutes.duplicateContacts,
    );
    return suggestions.take(4).toList();
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = _build();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Today's Suggestions",
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const Spacer(),
            if (suggestions.isNotEmpty)
              Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.iconChipBg(
                    context,
                    AppColors.accent,
                    AppColors.tintTeal,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${suggestions.length}',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderFor(context)),
            boxShadow: AppColors.isLight(context)
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: suggestions.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      controller.isLoadingSummary
                          ? 'Looking for things to clean…'
                          : "You're all caught up 🎉",
                      style: TextStyle(
                        color: AppColors.textMuted(context),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              : Column(
                  children: [
                    for (var i = 0; i < suggestions.length; i++) ...[
                      if (i > 0)
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: AppColors.borderFor(context),
                          indent: 16,
                          endIndent: 16,
                        ),
                      _SuggestionRow(
                        suggestion: suggestions[i],
                        controller: controller,
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _Suggestion {
  const _Suggestion({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.tint,
    required this.route,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color tint;
  final String route;
}

class _SuggestionRow extends StatelessWidget {
  const _SuggestionRow({required this.suggestion, required this.controller});

  final _Suggestion suggestion;
  final HomeDashboardController controller;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await Get.toNamed(suggestion.route);
        await controller.refreshSummary();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.iconChipBg(
                  context,
                  suggestion.color,
                  suggestion.tint,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(suggestion.icon, color: suggestion.color, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suggestion.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    suggestion.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              size: 15,
              color: AppColors.textFaint(context),
            ),
          ],
        ),
      ),
    );
  }
}
