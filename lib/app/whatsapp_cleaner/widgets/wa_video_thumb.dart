import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

/// Renders a thumbnail frame for a WhatsApp video file. Frames are generated
/// once per path and cached, with a video-icon placeholder while loading or if
/// a frame can't be produced.
class WaVideoThumb extends StatefulWidget {
  const WaVideoThumb({super.key, required this.path});

  final String path;

  @override
  State<WaVideoThumb> createState() => _WaVideoThumbState();
}

class _WaVideoThumbState extends State<WaVideoThumb> {
  static final Map<String, Uint8List?> _cache = <String, Uint8List?>{};

  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    if (_cache.containsKey(widget.path)) {
      _bytes = _cache[widget.path];
    } else {
      _generate();
    }
  }

  Future<void> _generate() async {
    Uint8List? data;
    try {
      data = await VideoThumbnail.thumbnailData(
        video: widget.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 256,
        quality: 60,
      );
    } catch (_) {
      data = null;
    }
    _cache[widget.path] = data;
    if (!mounted) {
      return;
    }
    setState(() => _bytes = data);
  }

  @override
  Widget build(BuildContext context) {
    if (_bytes != null) {
      return Image.memory(_bytes!, fit: BoxFit.cover, gaplessPlayback: true);
    }
    return const ColoredBox(
      color: Color(0xFF172133),
      child: Center(
        child: Icon(LucideIcons.video, color: Color(0xFFE36F64), size: 28),
      ),
    );
  }
}
