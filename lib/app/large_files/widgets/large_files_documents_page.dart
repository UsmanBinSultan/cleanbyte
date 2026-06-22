import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/sift_top_app_bar.dart';
import 'package:sift/app/large_files/large_files_controller.dart';
import 'package:sift/app/large_files/widgets/delete_selected_bar.dart';
import 'package:sift/app/large_files/widgets/documents_body.dart';

/// Opens the document review page for a filtered slice of the scanned files.
void openLargeFilesDocuments(
  LargeFilesController controller, {
  String title = 'Large Files',
  bool Function(LargeFileItem)? filter,
}) {
  Get.to(() => LargeFilesDocumentsPage(title: title, filter: filter));
}

/// The actionable file list reached from the hub's category tiles and the
/// browse button. Shows a filtered slice of the scanned files with multi-select
/// and recycle-bin delete.
class LargeFilesDocumentsPage extends StatelessWidget {
  const LargeFilesDocumentsPage({
    super.key,
    this.title = 'Large Files',
    this.filter,
  });

  final String title;
  final bool Function(LargeFileItem)? filter;

  List<LargeFileItem> _visible(LargeFilesController c) =>
      filter == null ? c.files : c.files.where(filter!).toList();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LargeFilesController>(
      builder: (controller) {
        final visible = _visible(controller);
        final allSelected =
            visible.isNotEmpty &&
            visible.every((f) => controller.isSelected(f));

        return Scaffold(
          backgroundColor: AppColors.pageBackground(context),
          body: SafeArea(
            child: Column(
              children: [
                SiftTopAppBar(
                  title: title,
                  trailing: TextButton(
                    onPressed: visible.isEmpty
                        ? null
                        : () {
                            if (allSelected) {
                              for (final f in visible) {
                                if (controller.isSelected(f)) {
                                  controller.toggleFile(f);
                                }
                              }
                            } else {
                              for (final f in visible) {
                                if (!controller.isSelected(f)) {
                                  controller.toggleFile(f);
                                }
                              }
                            }
                          },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      disabledForegroundColor: const Color(0xFF4A5362),
                      textStyle: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    child: Text(allSelected ? 'Clear' : 'Select all'),
                  ),
                ),
                Expanded(
                  child: DocumentsBody(
                    controller: controller,
                    visible: visible,
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
