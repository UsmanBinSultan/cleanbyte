import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/cleanup_action.dart';
import 'package:sift/app/components/sift_top_app_bar.dart';
import 'package:sift/app/home_dashboard/home_dashboard_controller.dart';

/// "Review & Delete" — the summary reached from Smart Scan's "Review Results".
/// Each category found can be marked "Delete all" or "Keep all". Marking only
/// records intent; the actual deletion happens inside each category's own
/// review screen (via the recycle bin) — nothing is removed from this screen
/// directly, honouring the "nothing deleted until you approve" rule.
class ReviewDeleteView extends StatefulWidget {
  const ReviewDeleteView({super.key});

  @override
  State<ReviewDeleteView> createState() => _ReviewDeleteViewState();
}

class _ReviewDeleteViewState extends State<ReviewDeleteView> {
  /// Categories marked "Delete all". Nothing is marked by default.
  final Set<String> _marked = <String>{};

  HomeDashboardController? get _home =>
      Get.isRegistered<HomeDashboardController>()
      ? HomeDashboardController.instance
      : null;

  List<CleanupAction> get _items => kCleanupActions
      .where((a) => (_home?.metric(a.metricKey).count ?? 0) > 0)
      .toList();

  int _bytes(CleanupAction a) => _home?.metric(a.metricKey).bytes ?? 0;
  int _count(CleanupAction a) => _home?.metric(a.metricKey).count ?? 0;

  Future<void> _open(CleanupAction action) async {
    await Get.toNamed(action.route);
    await _home?.refreshSummary();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    final markedItems = items.where((a) => _marked.contains(a.metricKey));
    final markedBytes = markedItems.fold<int>(0, (s, a) => s + _bytes(a));
    final markedCount = markedItems.fold<int>(0, (s, a) => s + _count(a));

    return Scaffold(
      backgroundColor: AppColors.pageBackground(context),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                SiftTopAppBar(
                  title: 'Review & Delete',
                  subtitle: items.isEmpty
                      ? 'Nothing to review yet'
                      : '$markedCount items marked',
                  trailing: items.isEmpty
                      ? null
                      : TextButton(
                          onPressed: () => setState(() {
                            if (_marked.length == items.length) {
                              _marked.clear();
                            } else {
                              _marked
                                ..clear()
                                ..addAll(items.map((a) => a.metricKey));
                            }
                          }),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.accent,
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          child: Text(
                            _marked.length == items.length
                                ? 'Clear'
                                : 'Select all',
                          ),
                        ),
                ),
                Expanded(
                  child: items.isEmpty
                      ? _EmptyReview()
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                          children: [
                            const _SafetyBanner(),
                            const SizedBox(height: 14),
                            for (final action in items)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _CategoryCard(
                                  action: action,
                                  subtitle: _home?.metricSubtitle(
                                    action.metricKey,
                                  ),
                                  marked: _marked.contains(action.metricKey),
                                  onMark: () => setState(
                                    () => _marked.add(action.metricKey),
                                  ),
                                  onKeep: () => setState(
                                    () => _marked.remove(action.metricKey),
                                  ),
                                  onViewAll: () => _open(action),
                                ),
                              ),
                          ],
                        ),
                ),
                if (items.isNotEmpty)
                  _ConfirmBar(
                    markedBytes: markedBytes,
                    markedCount: markedCount,
                    enabled: _marked.isNotEmpty,
                    onConfirm: () {
                      final first = markedItems.isEmpty
                          ? null
                          : markedItems.first;
                      if (first != null) _open(first);
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SafetyBanner extends StatelessWidget {
  const _SafetyBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.iconChipBg(context, AppColors.accent, AppColors.tintTeal),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.shieldCheck, size: 16, color: AppColors.accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Nothing is deleted until you confirm. Mark each category to '
              'delete or keep.',
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.action,
    required this.subtitle,
    required this.marked,
    required this.onMark,
    required this.onKeep,
    required this.onViewAll,
  });

  final CleanupAction action;
  final String? subtitle;
  final bool marked;
  final VoidCallback onMark;
  final VoidCallback onKeep;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: marked ? AppColors.danger : AppColors.borderFor(context),
          width: marked ? 1.5 : 1,
        ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.iconChipBg(
                      context,
                      action.iconColor,
                      action.tint,
                    ),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(action.icon, color: action.iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textPrimary(context),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle ?? 'Ready to review',
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
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Row(
              children: [
                Expanded(
                  child: _MarkButton(
                    label: 'Review all',
                    icon: LucideIcons.eye,
                    color: AppColors.danger,
                    tint: AppColors.dangerBg,
                    active: marked,
                    onTap: onMark,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MarkButton(
                    label: 'Keep all',
                    icon: LucideIcons.check,
                    color: AppColors.accentDeep,
                    tint: AppColors.tintTeal,
                    active: !marked,
                    onTap: onKeep,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.borderFor(context)),
          InkWell(
            onTap: onViewAll,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'View all items',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    LucideIcons.chevronRight,
                    size: 15,
                    color: AppColors.accent,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MarkButton extends StatelessWidget {
  const _MarkButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.tint,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color tint;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active
              ? AppColors.iconChipBg(context, color, tint)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? color : AppColors.borderFor(context),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: active ? color : AppColors.textMuted(context),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: active ? color : AppColors.textMuted(context),
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmBar extends StatelessWidget {
  const _ConfirmBar({
    required this.markedBytes,
    required this.markedCount,
    required this.enabled,
    required this.onConfirm,
  });

  final int markedBytes;
  final int markedCount;
  final bool enabled;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
      decoration: BoxDecoration(
        color: AppColors.bottomBar(context),
        border: Border(top: BorderSide(color: AppColors.borderFor(context))),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Marked for Review: '
                  '${HomeDashboardController.formatBytes(markedBytes)}',
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '$markedCount items',
                style: TextStyle(
                  color: AppColors.textMuted(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: TextButton.icon(
              onPressed: enabled ? onConfirm : null,
              icon: const Icon(LucideIcons.eye, size: 18),
              label: Text(
                'Confirm & Review · '
                '${HomeDashboardController.formatBytes(markedBytes)}',
              ),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.surfaceTint(context),
                disabledForegroundColor: AppColors.textFaint(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyReview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.iconChipBg(
                  context,
                  AppColors.accent,
                  AppColors.tintTeal,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.checkCircle2,
                size: 34,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              "You're all clean!",
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Run a Smart Scan to find more to review.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
