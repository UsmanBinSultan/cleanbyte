import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/large_files/large_files_controller.dart';
import 'package:sift/app/large_files/widgets/delete_selected_bar.dart';
import 'package:sift/app/large_files/widgets/file_search_input.dart';
import 'package:sift/app/large_files/widgets/search_results.dart';

/// Live search across every scanned file by name. Results are selectable and
/// can be deleted with the same recycle-bin flow as the document list.
class FileSearchPage extends StatefulWidget {
  const FileSearchPage({super.key});

  @override
  State<FileSearchPage> createState() => _FileSearchPageState();
}

class _FileSearchPageState extends State<FileSearchPage> {
  final TextEditingController _queryController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  List<LargeFileItem> _results(LargeFilesController c) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) {
      return const [];
    }
    return c.files.where((f) => f.name.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LargeFilesController>(
      builder: (controller) {
        final results = _results(controller);
        return Scaffold(
          backgroundColor: AppColors.pageBackground(context),
          body: SafeArea(
            child: Column(
              children: [
                FileSearchInput(
                  controller: _queryController,
                  onChanged: (value) => setState(() => _query = value),
                  onClear: () => setState(() {
                    _query = '';
                    _queryController.clear();
                  }),
                ),
                Expanded(
                  child: SearchResults(
                    controller: controller,
                    query: _query.trim(),
                    results: results,
                  ),
                ),
                DeleteSelectedBar(controller: controller),
              ],
            ),
          ),
        );
      },
    );
  }
}
