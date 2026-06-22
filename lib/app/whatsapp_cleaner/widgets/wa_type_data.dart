import 'package:flutter/widgets.dart';
import 'package:sift/app/whatsapp_cleaner/whatsapp_cleaner_controller.dart';

/// Static descriptor for a WhatsApp media category shown on the cleaner hub.
class WaTypeData {
  const WaTypeData(this.title, this.subtitle, this.icon, this.color, this.type);

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final WhatsappMediaType type;
}
