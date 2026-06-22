import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/whatsapp_cleaner/whatsapp_cleaner_controller.dart';

/// The list/empty-state icon for a WhatsApp media [type].
IconData whatsappTypeIcon(WhatsappMediaType type) {
  switch (type) {
    case WhatsappMediaType.images:
      return LucideIcons.image;
    case WhatsappMediaType.videos:
      return LucideIcons.video;
    case WhatsappMediaType.voiceNotes:
      return LucideIcons.mic;
    case WhatsappMediaType.documents:
      return LucideIcons.fileText;
  }
}

/// The accent color for a WhatsApp media [type].
Color whatsappTypeColor(WhatsappMediaType type) {
  switch (type) {
    case WhatsappMediaType.images:
      return const Color(0xFFD7B451);
    case WhatsappMediaType.videos:
      return const Color(0xFFE36F64);
    case WhatsappMediaType.voiceNotes:
      return const Color(0xFF9B4FC7);
    case WhatsappMediaType.documents:
      return const Color(0xFF5D78B8);
  }
}
