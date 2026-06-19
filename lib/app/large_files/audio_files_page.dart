import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/loading_shimmer.dart';
import 'package:sift/app/components/sift_top_app_bar.dart';
import 'package:sift/core/utils/formatters.dart';

/// A single audio track read from the device media library.
class _AudioItem {
  const _AudioItem({
    required this.title,
    required this.size,
    required this.duration,
  });

  final String title;
  final int size;
  final Duration duration;
}

/// Lists the audio files stored on the phone (music, recordings, voice notes),
/// largest first. Reached from the Files hub "Audio" tile. Read-only browse —
/// real data from `photo_manager`, no fabricated entries.
class AudioFilesPage extends StatefulWidget {
  const AudioFilesPage({super.key});

  @override
  State<AudioFilesPage> createState() => _AudioFilesPageState();
}

class _AudioFilesPageState extends State<AudioFilesPage> {
  static const int _maxItems = 500;

  bool _loading = true;
  bool _hasAccess = false;
  List<_AudioItem> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    final permission = await PhotoManager.requestPermissionExtend(
      requestOption: const PermissionRequestOption(
        androidPermission: AndroidPermission(
          type: RequestType.audio,
          mediaLocation: false,
        ),
      ),
    );
    _hasAccess = permission.hasAccess;

    if (!_hasAccess) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _items = const [];
      });
      return;
    }

    final items = <_AudioItem>[];
    try {
      final paths = await PhotoManager.getAssetPathList(
        type: RequestType.audio,
        onlyAll: true,
        filterOption: FilterOptionGroup(
          audioOption: const FilterOption(needTitle: true),
          orders: const [
            OrderOption(type: OrderOptionType.createDate, asc: false),
          ],
        ),
      );
      if (paths.isNotEmpty) {
        final count = await paths.first.assetCountAsync;
        final assets = await paths.first.getAssetListRange(
          start: 0,
          end: count < _maxItems ? count : _maxItems,
        );
        for (final asset in assets) {
          final file = await asset.file;
          final size = file == null ? 0 : await file.length();
          items.add(
            _AudioItem(
              title: asset.title?.isNotEmpty == true ? asset.title! : 'Audio',
              size: size,
              duration: Duration(seconds: asset.duration),
            ),
          );
        }
        items.sort((a, b) => b.size.compareTo(a.size));
      }
    } catch (_) {
      // Leave the list empty on any read error.
    }

    if (!mounted) return;
    setState(() {
      _loading = false;
      _items = items;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            SiftTopAppBar(
              title: 'Audio',
              subtitle: _items.isEmpty
                  ? null
                  : '${formatThousands(_items.length)} files',
            ),
            Expanded(child: _body(context)),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    if (_loading) {
      return const ListShimmer();
    }

    if (!_hasAccess) {
      return _AudioEmpty(
        icon: LucideIcons.music,
        title: 'Audio access needed',
        body: 'Allow audio access so Clean Byte can list your music, '
            'recordings and voice notes.',
        actionLabel: 'Open Settings',
        onAction: PhotoManager.openSetting,
      );
    }

    if (_items.isEmpty) {
      return _AudioEmpty(
        icon: LucideIcons.music,
        title: 'No audio files found',
        body: 'Music, recordings and voice notes will appear here.',
        actionLabel: 'Refresh',
        onAction: _load,
      );
    }

    final totalBytes = _items.fold<int>(0, (sum, a) => sum + a.size);

    return RefreshIndicator(
      color: AppColors.accent,
      backgroundColor: AppColors.surface(context),
      onRefresh: _load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        itemCount: _items.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                '${formatThousands(_items.length)} files · ${formatBytes(totalBytes)}',
                style: TextStyle(
                  color: AppColors.textMuted(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            );
          }
          return _AudioRow(item: _items[index - 1]);
        },
      ),
    );
  }
}

class _AudioRow extends StatelessWidget {
  const _AudioRow({required this.item});

  final _AudioItem item;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      if (item.duration.inSeconds > 0) formatDuration(item.duration),
      if (item.size > 0) formatBytes(item.size),
    ].join(' · ');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.iconChipBg(
                context,
                AppColors.iconPink,
                AppColors.tintPink,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(LucideIcons.music, size: 19, color: AppColors.iconPink),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textMuted(context),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AudioEmpty extends StatelessWidget {
  const _AudioEmpty({
    required this.icon,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onAction;

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
              onPressed: onAction,
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
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
