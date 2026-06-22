import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/cleanup_action.dart';
import 'package:sift/app/components/sift_top_app_bar.dart';
import 'package:sift/app/home_dashboard/home_dashboard_controller.dart';
import 'package:sift/app/review_delete/widgets/category_card.dart';
import 'package:sift/app/review_delete/widgets/confirm_bar.dart';
import 'package:sift/app/review_delete/widgets/empty_review.dart';
import 'package:sift/app/review_delete/widgets/safety_banner.dart';

/// "Review & Delete" — the summary reached from Smart Scan's "Review Results".
/// Each category found can be marked "Review all" or "Keep all". Marking only
/// records intent; the actual deletion happens inside each category's own
/// review screen (via the recycle bin) — nothing is removed from this screen
/// directly, honouring the "nothing deleted until you approve" rule.
class ReviewDeleteView extends StatefulWidget {
  const ReviewDeleteView({super.key});

  @override
  State<ReviewDeleteView> createState() => _ReviewDeleteViewState();
}

class _ReviewDeleteViewState extends State<ReviewDeleteView> {
  /// Categories marked "Review all". Nothing is marked by default.
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
                      ? const EmptyReview()
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                          children: [
                            const SafetyBanner(),
                            const SizedBox(height: 14),
                            for (final action in items)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: CategoryCard(
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
                  ConfirmBar(
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
