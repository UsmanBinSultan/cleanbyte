import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/loading_shimmer.dart';
import 'package:sift/app/components/sift_bottom_nav_bar.dart';
import 'package:sift/app/components/sift_top_app_bar.dart';
import 'package:sift/app/large_files/audio_files_page.dart';
import 'package:sift/app/large_files/large_files_controller.dart';
import 'package:sift/app/routes/app_routes.dart';
import 'package:sift/core/utils/formatters.dart';

/// "Files" — a browse hub: a device-storage donut, quick source shortcuts and
/// a category grid. Every number is real (device storage, photo library counts
/// and the on-device document scan). Tapping a category opens either a media
/// cleaner or the document review page below.
class LargeFilesView extends StatelessWidget {
  const LargeFilesView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LargeFilesController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.pageBackground(context),
          body: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                Column(
                  children: [
                    SiftTopAppBar(
                      title: 'Files',
                      showBack: false,
                      trailing: _CircleIconButton(
                        icon: LucideIcons.search,
                        onTap: () => Get.to(() => const FileSearchPage()),
                      ),
                    ),
                    Expanded(child: _FilesHubBody(controller: controller)),
                  ],
                ),
                const Align(
                  alignment: Alignment.bottomCenter,
                  child: SiftBottomNavBar(activeIndex: 2),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

void _openDocuments(
  LargeFilesController controller, {
  String title = 'Large Files',
  bool Function(LargeFileItem)? filter,
}) {
  Get.to(() => LargeFilesDocumentsPage(title: title, filter: filter));
}

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
                _SearchBar(
                  controller: _queryController,
                  onChanged: (value) => setState(() => _query = value),
                  onClear: () => setState(() {
                    _query = '';
                    _queryController.clear();
                  }),
                ),
                Expanded(
                  child: _SearchResults(
                    controller: controller,
                    query: _query.trim(),
                    results: results,
                  ),
                ),
                _DeleteSelectedBar(controller: controller),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: Get.back,
            icon: Icon(
              LucideIcons.arrowLeft,
              color: AppColors.textPrimary(context),
            ),
          ),
          Expanded(
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderFor(context)),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.search,
                    size: 18,
                    color: AppColors.textMuted(context),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: onChanged,
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                        hintText: 'Search files by name',
                        hintStyle: TextStyle(
                          color: AppColors.textFaint(context),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  if (controller.text.isNotEmpty)
                    GestureDetector(
                      onTap: onClear,
                      child: Icon(
                        LucideIcons.x,
                        size: 18,
                        color: AppColors.textMuted(context),
                      ),
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

class _SearchResults extends StatelessWidget {
  const _SearchResults({
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
        return _LargeFileRow(
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

class _FilesHubBody extends StatelessWidget {
  const _FilesHubBody({required this.controller});

  final LargeFilesController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const ListShimmer();
    }

    final hasSources =
        controller.files.isNotEmpty &&
        (controller.sourceBytes(LargeFilesController.sourceDownloads) > 0 ||
            controller.sourceBytes(LargeFilesController.sourceDocuments) > 0 ||
            controller.sourceBytes(LargeFilesController.sourceWhatsApp) > 0 ||
            controller.recentBytes > 0);

    return RefreshIndicator(
      color: AppColors.accent,
      backgroundColor: AppColors.surface(context),
      onRefresh: controller.loadFiles,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 104),
        children: [
          if (controller.hasStorageStats) ...[
            _StorageDonutCard(controller: controller),
            const SizedBox(height: 16),
          ],
          if (hasSources) ...[
            _SourceGrid(controller: controller),
            const SizedBox(height: 22),
          ],
          Text(
            'Browse by Category',
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 14),
          _CategoryGrid(controller: controller),
          const SizedBox(height: 24),
          _BrowseAllButton(controller: controller),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Source shortcuts (2x2)
// ---------------------------------------------------------------------------

class _SourceGrid extends StatelessWidget {
  const _SourceGrid({required this.controller});

  final LargeFilesController controller;

  @override
  Widget build(BuildContext context) {
    final sources = <_SourceData>[
      _SourceData(
        label: 'Downloads',
        bytes: controller.sourceBytes(LargeFilesController.sourceDownloads),
        icon: LucideIcons.download,
        color: AppColors.iconAmber,
        tint: AppColors.tintAmber,
        onTap: () => _openDocuments(
          controller,
          title: 'Downloads',
          filter: (f) => f.source == LargeFilesController.sourceDownloads,
        ),
      ),
      _SourceData(
        label: 'Documents',
        bytes: controller.sourceBytes(LargeFilesController.sourceDocuments),
        icon: LucideIcons.folder,
        color: AppColors.accent,
        tint: AppColors.tintTeal,
        onTap: () => _openDocuments(
          controller,
          title: 'Documents',
          filter: (f) => f.source == LargeFilesController.sourceDocuments,
        ),
      ),
      // _SourceData(
      //   label: 'WhatsApp',
      //   bytes: controller.sourceBytes(LargeFilesController.sourceWhatsApp),
      //   icon: LucideIcons.messageCircle,
      //   color: AppColors.whatsapp,
      //   tint: AppColors.tintGreen,
      //   onTap: () => _openDocuments(
      //     controller,
      //     title: 'WhatsApp',
      //     filter: (f) => f.source == LargeFilesController.sourceWhatsApp,
      //   ),
      // ),
      _SourceData(
        label: 'Recently Added',
        bytes: controller.recentBytes,
        icon: LucideIcons.clock,
        color: AppColors.iconPink,
        tint: AppColors.tintPink,
        onTap: () => _openDocuments(
          controller,
          title: 'Recently Added',
          filter: (f) => f.modified.isAfter(
            DateTime.now().subtract(const Duration(days: 30)),
          ),
        ),
      ),
    ].where((s) => s.bytes > 0).toList();

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.45,
      children: [for (final s in sources) _SourceCard(data: s)],
    );
  }
}

class _SourceData {
  const _SourceData({
    required this.label,
    required this.bytes,
    required this.icon,
    required this.color,
    required this.tint,
    required this.onTap,
  });

  final String label;
  final int bytes;
  final IconData icon;
  final Color color;
  final Color tint;
  final VoidCallback onTap;
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({required this.data});

  final _SourceData data;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface(context),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: data.onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderFor(context)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.iconChipBg(context, data.color, data.tint),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(data.icon, size: 19, color: data.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      data.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      formatBytes(data.bytes),
                      style: TextStyle(
                        color: AppColors.textMuted(context),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Category grid (4 columns)
// ---------------------------------------------------------------------------

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.controller});

  final LargeFilesController controller;

  int _sourceCount(String label) =>
      controller.files.where((f) => f.source == label).length;

  @override
  Widget build(BuildContext context) {
    final tiles = <_CategoryData>[
      _CategoryData(
        label: 'Images',
        count: controller.imageCount,
        icon: LucideIcons.image,
        color: AppColors.accent,
        tint: AppColors.tintMint,
        onTap: () => Get.toNamed(AppRoutes.similarPhotos),
      ),
      _CategoryData(
        label: 'Videos',
        count: controller.videoCount,
        icon: LucideIcons.video,
        color: AppColors.iconPurple,
        tint: AppColors.tintPurple,
        onTap: () => Get.toNamed(AppRoutes.largeVideos),
      ),
      _CategoryData(
        label: 'Audio',
        count: controller.audioCount,
        icon: LucideIcons.music,
        color: AppColors.iconPink,
        tint: AppColors.tintPink,
        onTap: () => Get.to(() => const AudioFilesPage()),
      ),
      _CategoryData(
        label: 'Documents',
        count: controller.documentsCount,
        icon: LucideIcons.fileText,
        color: AppColors.iconBlue,
        tint: AppColors.tintBlue,
        onTap: () => _openDocuments(
          controller,
          title: 'Documents',
          filter: (f) => !_isArchive(f.name),
        ),
      ),
      _CategoryData(
        label: 'Archives',
        count: controller.archivesCount,
        icon: LucideIcons.archive,
        color: AppColors.iconAmber,
        tint: AppColors.tintAmber,
        onTap: () => _openDocuments(
          controller,
          title: 'Archives',
          filter: (f) => _isArchive(f.name),
        ),
      ),
      _CategoryData(
        label: 'Large Files',
        count: controller.largeFilesCount,
        icon: LucideIcons.alertCircle,
        color: AppColors.danger,
        tint: AppColors.dangerBg,
        onTap: () => _openDocuments(
          controller,
          title: 'Large Files',
          filter: (f) => controller.largeFiles.contains(f),
        ),
      ),
      _CategoryData(
        label: 'Downloads',
        count: _sourceCount(LargeFilesController.sourceDownloads),
        icon: LucideIcons.download,
        color: AppColors.accent,
        tint: AppColors.tintGreen,
        onTap: () => _openDocuments(
          controller,
          title: 'Downloads',
          filter: (f) => f.source == LargeFilesController.sourceDownloads,
        ),
      ),
      // _CategoryData(
      //   label: 'WhatsApp',
      //   count: _sourceCount(LargeFilesController.sourceWhatsApp),
      //   icon: LucideIcons.messageCircle,
      //   color: AppColors.whatsapp,
      //   tint: AppColors.tintGreen,
      //   onTap: () => _openDocuments(
      //     controller,
      //     title: 'WhatsApp',
      //     filter: (f) => f.source == LargeFilesController.sourceWhatsApp,
      //   ),
      // ),
    ];

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.74,
      children: [for (final t in tiles) _CategoryTile(data: t)],
    );
  }
}

bool _isArchive(String name) {
  final lower = name.toLowerCase();
  const archives = ['.zip', '.rar', '.7z', '.apk'];
  return archives.any(lower.endsWith);
}

class _CategoryData {
  const _CategoryData({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
    required this.tint,
    this.onTap,
  });

  final String label;
  final int count;
  final IconData icon;
  final Color color;
  final Color tint;
  final VoidCallback? onTap;
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.data});

  final _CategoryData data;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface(context),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: data.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderFor(context)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.iconChipBg(context, data.color, data.tint),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(data.icon, size: 19, color: data.color),
              ),
              const SizedBox(height: 5),
              Text(
                data.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                formatCount(data.count),
                style: TextStyle(
                  color: AppColors.textMuted(context),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Groups thousands with a comma, e.g. 12458 -> "12,458".
String formatCount(int value) {
  final digits = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

// ---------------------------------------------------------------------------
// "Browse all files" action (sits at the end of the hub content)
// ---------------------------------------------------------------------------

class _BrowseAllButton extends StatelessWidget {
  const _BrowseAllButton({required this.controller});

  final LargeFilesController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.accentGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentDeep.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: TextButton.icon(
          onPressed: () => _openDocuments(controller),
          icon: const Icon(LucideIcons.folderPlus, size: 18),
          label: const Text('Browse All Files'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface(context),
      shape: CircleBorder(
        side: BorderSide(color: AppColors.borderFor(context)),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(icon, size: 18, color: AppColors.textPrimary(context)),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Storage donut card
// ---------------------------------------------------------------------------

/// White storage summary card — a teal usage donut on the left and a
/// Used / Available legend on the right, mirroring the Figma design. Driven by
/// real device stats from [LargeFilesController].
class _StorageDonutCard extends StatelessWidget {
  const _StorageDonutCard({required this.controller});

  final LargeFilesController controller;

  @override
  Widget build(BuildContext context) {
    final fraction = controller.storageUsedFraction.clamp(0.0, 1.0);
    final usedGb = _formatGb(controller.storageUsedBytes);
    final freeGb = _formatGb(controller.storageFreeBytes);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderFor(context)),
        boxShadow: AppColors.isLight(context)
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 84,
                height: 84,
                child: CustomPaint(
                  painter: _StorageRingPainter(
                    progress: fraction,
                    track: AppColors.borderFor(context),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Used',
                          style: TextStyle(
                            color: AppColors.textMuted(context),
                            fontSize: 10,
                            height: 1,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          usedGb,
                          style: TextStyle(
                            color: AppColors.textPrimary(context),
                            fontSize: 15,
                            height: 1,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  children: [
                    _StorageLegendRow(
                      color: AppColors.accent,
                      label: 'Used',
                      value: '$usedGb GB',
                      labelColor: AppColors.textPrimary(context),
                      valueColor: AppColors.textPrimary(context),
                    ),
                    const SizedBox(height: 12),
                    _StorageLegendRow(
                      color: AppColors.borderFor(context),
                      label: 'Available',
                      value: '$freeGb GB',
                      labelColor: AppColors.textMuted(context),
                      valueColor: AppColors.textMuted(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: AppColors.borderFor(context)),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Clean Byte-managed storage',
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StorageLegendRow extends StatelessWidget {
  const _StorageLegendRow({
    required this.color,
    required this.label,
    required this.value,
    required this.labelColor,
    required this.valueColor,
  });

  final Color color;
  final String label;
  final String value;
  final Color labelColor;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _StorageRingPainter extends CustomPainter {
  const _StorageRingPainter({required this.progress, required this.track});

  final double progress;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final base = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;
    final fill = Paint()
      ..shader = AppColors.accentGradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, base);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress.clamp(0, 1),
      false,
      fill,
    );
  }

  @override
  bool shouldRepaint(covariant _StorageRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.track != track;
}

/// Formats bytes as a GB number (no unit suffix), e.g. 189.4.
String _formatGb(int bytes) {
  if (bytes <= 0) {
    return '0';
  }
  const gb = 1000 * 1000 * 1000;
  return (bytes / gb).toStringAsFixed(1);
}

// ---------------------------------------------------------------------------
// Document review page (the original large-files list + delete)
// ---------------------------------------------------------------------------

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
                  child: _DocumentsBody(
                    controller: controller,
                    visible: visible,
                  ),
                ),
                _DeleteSelectedBar(controller: controller),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DocumentsBody extends StatelessWidget {
  const _DocumentsBody({required this.controller, required this.visible});

  final LargeFilesController controller;
  final List<LargeFileItem> visible;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const ListShimmer();
    }

    // if (!controller.hasAccess || controller.errorMessage != null) {
    //   return _CenteredFileState(
    //     icon: LucideIcons.fileSearch,
    //     title: 'File access needed',
    //     body:
    //         controller.errorMessage ??
    //         'Allow file access to show documents from largest to smallest.',
    //     primaryLabel: 'Open Settings',
    //     onPrimary: controller.openSettings,
    //     secondaryLabel: 'Try Again',
    //     onSecondary: controller.loadFiles,
    //   );
    // }

    if (visible.isEmpty) {
      return _CenteredFileState(
        icon: LucideIcons.file,
        title: 'Nothing here',
        body: 'No files were found in this category.',
        primaryLabel: 'Refresh',
        onPrimary: controller.loadFiles,
      );
    }

    return RefreshIndicator(
      color: AppColors.accent,
      backgroundColor: AppColors.surface(context),
      onRefresh: controller.loadFiles,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                '${visible.length} ${visible.length == 1 ? 'file' : 'files'} · sorted by size',
                style: TextStyle(
                  color: AppColors.textMuted(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            );
          }
          final file = visible[index - 1];
          return _LargeFileRow(
            file: file,
            selected: controller.isSelected(file),
            onTap: () => controller.toggleFile(file),
          );
        },
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemCount: visible.length + 1,
      ),
    );
  }
}

class _LargeFileRow extends StatelessWidget {
  const _LargeFileRow({
    required this.file,
    required this.selected,
    required this.onTap,
  });

  final LargeFileItem file;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.borderFor(context),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  file.extension,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${formatBytes(file.size)} - ${formatShortDate(file.modified)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textMuted(context),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _FileSelectionMark(selected: selected),
          ],
        ),
      ),
    );
  }
}

class _FileSelectionMark extends StatelessWidget {
  const _FileSelectionMark({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: selected ? AppColors.accent : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.accent : const Color(0xFF697385),
        ),
      ),
      child: selected
          ? const Icon(LucideIcons.check, size: 14, color: Color(0xFF062322))
          : null,
    );
  }
}

class _CenteredFileState extends StatelessWidget {
  const _CenteredFileState({
    required this.icon,
    required this.title,
    required this.body,
    required this.primaryLabel,
    required this.onPrimary,
  });

  final IconData icon;
  final String title;
  final String body;
  final String primaryLabel;
  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.accent, size: 42),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 22),
            TextButton(
              onPressed: onPrimary,
              style: TextButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: const Color(0xFF062322),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.w900),
              ),
              child: Text(primaryLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteSelectedBar extends StatelessWidget {
  const _DeleteSelectedBar({required this.controller});

  final LargeFilesController controller;

  @override
  Widget build(BuildContext context) {
    final selectedCount = controller.selectedCount;
    final enabled = selectedCount > 0 && !controller.isDeleting;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: BoxDecoration(
        color: AppColors.bottomBar(context),
        border: Border(top: BorderSide(color: AppColors.borderFor(context))),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: TextButton.icon(
          onPressed: enabled ? () => _confirmAndDelete(controller) : null,
          icon: controller.isDeleting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(LucideIcons.trash, size: 18),
          label: Text(
            controller.isDeleting
                ? 'Deleting...'
                : 'Delete selected ($selectedCount)',
          ),
          style: TextButton.styleFrom(
            disabledBackgroundColor: AppColors.surfaceTint(context),
            disabledForegroundColor: AppColors.textFaint(context),
            backgroundColor: AppColors.danger,
            foregroundColor: Colors.white,
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
    );
  }

  Future<void> _confirmAndDelete(LargeFilesController controller) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text(
          'Delete selected?',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: Text(
          'This will delete ${controller.selectedCount} selected files from your phone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    final deleted = await controller.deleteSelected();
    Get.snackbar(
      deleted == 0 ? 'Nothing deleted' : 'Deleted $deleted',
      deleted == 0
          ? 'No files were removed. Some files may be protected.'
          : 'The selected files have been removed.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF111929),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }
}
