import 'package:flutter/material.dart';
import 'package:sift/app/components/app_colors.dart';

/// A selectable option row inside a settings picker sheet.
class SettingsPickerTile extends StatelessWidget {
  const SettingsPickerTile({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: selected
          ? const Icon(Icons.check_circle, color: AppColors.accent)
          : null,
    );
  }
}
