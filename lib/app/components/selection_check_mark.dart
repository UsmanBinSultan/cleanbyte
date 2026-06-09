import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Animated circular selection indicator shown on media grid/list tiles.
///
/// Replaces the identical `_SelectionMark`/`_WaSelectionMark` widgets in the
/// similar-photos and whatsapp-cleaner views.
class SelectionCheckMark extends StatelessWidget {
  const SelectionCheckMark({super.key, required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFF18D0B8)
            : Colors.black.withValues(alpha: 0.45),
        shape: BoxShape.circle,
        border: Border.all(
          color: selected
              ? const Color(0xFF18D0B8)
              : Colors.white.withValues(alpha: 0.65),
        ),
      ),
      child: selected
          ? const Icon(LucideIcons.check, size: 14, color: Color(0xFF062322))
          : null,
    );
  }
}
