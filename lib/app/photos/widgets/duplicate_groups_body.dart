import 'package:flutter/material.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/photos/photos_controller.dart';
import 'package:sift/app/photos/widgets/ai_pick_note.dart';
import 'package:sift/app/photos/widgets/duplicate_group_card.dart';
import 'package:sift/app/photos/widgets/similar_summary_card.dart';

/// Grouped "Similar Photos" body: a summary card, an AI-pick note and one card
/// per duplicate set.
class DuplicateGroupsBody extends StatelessWidget {
  const DuplicateGroupsBody({super.key, required this.controller});

  final SimilarPhotosController controller;

  @override
  Widget build(BuildContext context) {
    final groups = controller.duplicateGroups;
    return RefreshIndicator(
      color: AppColors.accent,
      backgroundColor: AppColors.surface(context),
      onRefresh: controller.loadAssets,
      // Lazy builder so off-screen group cards (and their thumbnail rows) are
      // not built/decoded until scrolled into view. Index 0 is the header.
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        itemCount: groups.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SimilarSummaryCard(controller: controller, groups: groups),
                const SizedBox(height: 12),
                const AiPickNote(),
                const SizedBox(height: 14),
              ],
            );
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DuplicateGroupCard(
              controller: controller,
              group: groups[index - 1],
              index: index,
            ),
          );
        },
      ),
    );
  }
}
