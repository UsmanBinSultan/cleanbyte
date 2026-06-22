import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:photo_manager/photo_manager.dart';

/// Async thumbnail for a [photo_manager] [AssetEntity], showing a neutral
/// placeholder while the image decodes.
///
/// Replaces the per-view `_Thumbnail` widgets in the similar-photos,
/// photo-compressor and ai-categories grids. [size] and [quality] default to
/// the most common grid values but can be tuned per call site.
///
/// The thumbnail future is resolved once in [State.initState] and only
/// recomputed when the asset/size/quality actually change. This matters for
/// performance: the previous stateless version recreated the future on every
/// parent rebuild (e.g. each selection toggle triggers `controller.update()`),
/// which made every visible tile re-decode its image and flash its placeholder.
class AssetThumbnail extends StatefulWidget {
  const AssetThumbnail({
    super.key,
    required this.asset,
    this.size = const ThumbnailSize(360, 460),
    this.quality = 82,
  });

  final AssetEntity asset;
  final ThumbnailSize size;
  final int quality;

  @override
  State<AssetThumbnail> createState() => _AssetThumbnailState();
}

class _AssetThumbnailState extends State<AssetThumbnail> {
  late Future<Uint8List?> _thumbnail;

  @override
  void initState() {
    super.initState();
    _thumbnail = _load();
  }

  @override
  void didUpdateWidget(AssetThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.asset.id != widget.asset.id ||
        oldWidget.size != widget.size ||
        oldWidget.quality != widget.quality) {
      _thumbnail = _load();
    }
  }

  Future<Uint8List?> _load() =>
      widget.asset.thumbnailDataWithSize(widget.size, quality: widget.quality);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Decode the bitmap no larger than the box actually shown on screen
        // (in physical pixels), never larger than the source thumbnail. This
        // keeps each decoded image — and therefore the global image cache —
        // sized to the display instead of the full thumbnail resolution.
        final dpr = MediaQuery.devicePixelRatioOf(context);
        final boxWidth = constraints.maxWidth.isFinite
            ? (constraints.maxWidth * dpr).round()
            : widget.size.width;
        final cacheWidth = boxWidth <= 0
            ? widget.size.width
            : (boxWidth < widget.size.width ? boxWidth : widget.size.width);

        return FutureBuilder<Uint8List?>(
          future: _thumbnail,
          builder: (context, snapshot) {
            final bytes = snapshot.data;
            if (bytes == null) {
              return const ColoredBox(
                color: Color(0xFF172237),
                child: Center(
                  child: Icon(
                    LucideIcons.image,
                    color: Color(0xFF687384),
                    size: 22,
                  ),
                ),
              );
            }

            return Image.memory(
              bytes,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              cacheWidth: cacheWidth,
            );
          },
        );
      },
    );
  }
}
