import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/cleanup_action.dart';
import 'package:sift/app/components/sift_bottom_nav_bar.dart';
import 'package:sift/app/components/sift_top_app_bar.dart';
import 'package:sift/app/home_dashboard/home_dashboard_controller.dart';

enum _ActionFilter { all, highImpact, quickWin }

/// "All Actions" — every cleanup category in one scrollable list, with
/// High Impact / Quick Win filters. Reads live metrics from the home
/// controller so counts and sizes match the dashboard.
class AllActionsView extends StatefulWidget {
  const AllActionsView({super.key});

  @override
  State<AllActionsView> createState() => _AllActionsViewState();
}

class _AllActionsViewState extends State<AllActionsView> {
  static const int _highImpactBytes = 1000 * 1000 * 1000; // 1 GB

  _ActionFilter _filter = _ActionFilter.all;

  HomeDashboardController? get _home =>
      Get.isRegistered<HomeDashboardController>()
      ? HomeDashboardController.instance
      : null;

  DashboardMetric? _metric(CleanupAction action) =>
      _home?.metric(action.metricKey);

  bool _isHighImpact(CleanupAction a) =>
      (_metric(a)?.bytes ?? 0) >= _highImpactBytes;
  bool _hasItems(CleanupAction a) => (_metric(a)?.count ?? 0) > 0;
  bool _isQuickWin(CleanupAction a) => _hasItems(a) && !_isHighImpact(a);

  Future<void> _open(CleanupAction action) async {
    await Get.toNamed(action.route);
    await _home?.refreshSummary();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final highCount = kCleanupActions.where(_isHighImpact).length;
    final quickCount = kCleanupActions.where(_isQuickWin).length;
    final withData = kCleanupActions.where(_hasItems).toList();
    final totalBytes = withData.fold<int>(
      0,
      (sum, a) => sum + (_metric(a)?.bytes ?? 0),
    );

    final visible = kCleanupActions.where((a) {
      switch (_filter) {
        case _ActionFilter.all:
          return true;
        case _ActionFilter.highImpact:
          return _isHighImpact(a);
        case _ActionFilter.quickWin:
          return _isQuickWin(a);
      }
    }).toList();

    final args = Get.arguments;
    final fromNav = args is Map && args['fromNav'] == true;

    return Scaffold(
      backgroundColor: AppColors.pageBackground(context),
      bottomNavigationBar: fromNav
          ? const SiftBottomNavBar(activeIndex: 2)
          : null,
      body: SafeArea(
        bottom: !fromNav,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                SiftTopAppBar(
                  title: 'All Actions',
                  showBack: !fromNav,
                  subtitle: withData.isEmpty
                      ? 'Run a scan to see what can be cleaned'
                      : '${withData.length} categories · up to '
                            '${HomeDashboardController.formatBytes(totalBytes)} recoverable',
                ),
                _FilterBar(
                  filter: _filter,
                  allCount: kCleanupActions.length,
                  highCount: highCount,
                  quickCount: quickCount,
                  onChanged: (f) => setState(() => _filter = f),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                    children: [
                      for (final action in visible)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ActionTile(
                            action: action,
                            subtitle: _home?.metricSubtitle(action.metricKey),
                            highImpact: _isHighImpact(action),
                            quickWin: _isQuickWin(action),
                            onTap: () => _open(action),
                          ),
                        ),
                      const SizedBox(height: 4),
                      const _ApproveFooter(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.filter,
    required this.allCount,
    required this.highCount,
    required this.quickCount,
    required this.onChanged,
  });

  final _ActionFilter filter;
  final int allCount;
  final int highCount;
  final int quickCount;
  final ValueChanged<_ActionFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          _Chip(
            label: 'High Impact',
            count: highCount,
            color: AppColors.danger,
            active: filter == _ActionFilter.highImpact,
            onTap: () => onChanged(_ActionFilter.highImpact),
          ),
          const SizedBox(width: 8),
          _Chip(
            label: 'Quick Win',
            count: quickCount,
            color: AppColors.accent,
            active: filter == _ActionFilter.quickWin,
            onTap: () => onChanged(_ActionFilter.quickWin),
          ),
          const SizedBox(width: 8),
          _Chip(
            label: 'All',
            count: allCount,
            color: AppColors.textMuted(context),
            active: filter == _ActionFilter.all,
            onTap: () => onChanged(_ActionFilter.all),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.count,
    required this.color,
    required this.active,
    required this.onTap,
  });

  final String label;
  final int count;
  final Color color;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? color : AppColors.surface(context),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: active ? color : AppColors.borderFor(context),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: active ? Colors.white : color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : AppColors.textPrimary(context),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              '$count',
              style: TextStyle(
                color: active
                    ? Colors.white.withValues(alpha: 0.85)
                    : AppColors.textMuted(context),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.action,
    required this.subtitle,
    required this.highImpact,
    required this.quickWin,
    required this.onTap,
  });

  final CleanupAction action;
  final String? subtitle;
  final bool highImpact;
  final bool quickWin;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderFor(context)),
          boxShadow: AppColors.isLight(context)
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.iconChipBg(
                  context,
                  action.iconColor,
                  action.tint,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(action.icon, color: action.iconColor, size: 21),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          action.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textPrimary(context),
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (highImpact || quickWin) ...[
                        const SizedBox(width: 8),
                        _Badge(highImpact: highImpact),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle ?? 'Tap to review',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textMuted(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              size: 16,
              color: AppColors.textFaint(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.highImpact});

  final bool highImpact;

  @override
  Widget build(BuildContext context) {
    final color = highImpact ? AppColors.danger : AppColors.accentDeep;
    final tint = highImpact ? AppColors.dangerBg : AppColors.tintTeal;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.iconChipBg(context, color, tint),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        highImpact ? 'High Impact' : 'Quick Win',
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ApproveFooter extends StatelessWidget {
  const _ApproveFooter();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.shieldCheck,
            size: 13,
            color: AppColors.textFaint(context),
          ),
          const SizedBox(width: 6),
          Text(
            'Nothing is deleted until you approve',
            style: TextStyle(
              color: AppColors.textFaint(context),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
