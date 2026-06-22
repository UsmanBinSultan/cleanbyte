import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/large_files/large_files_controller.dart';
import 'package:sift/app/large_files/widgets/large_file_row.dart';

/// Results list for the file search page — shows a hint while empty, a no-match
/// state, or the selectable matching rows.
class SearchResults extends StatelessWidget {
  const SearchResults({
    super.key,
    required this.controller,
    required this.query,
    required this.results,
  });

  final LargeFilesController controller;
  final String query;
  final List<LargeFileItem> results;

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return _SearchHint(
        icon: LucideIcons.search,
        text: 'Type to search ${controller.files.length} scanned files.',
      );
    }
    if (results.isEmpty) {
      return _SearchHint(
        icon: LucideIcons.fileX,
        text: 'No files match "$query".',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: results.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '${results.length} ${results.length == 1 ? 'result' : 'results'}',
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          );
        }
        final file = results[index - 1];
        return LargeFileRow(
          file: file,
          selected: controller.isSelected(file),
          onTap: () => controller.toggleFile(file),
        );
      },
    );
  }
}

class _SearchHint extends StatelessWidget {
  const _SearchHint({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 36, color: AppColors.textFaint(context)),
            const SizedBox(height: 14),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
