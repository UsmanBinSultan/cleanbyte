import 'package:flutter/material.dart';
import 'package:sift/app/components/app_colors.dart';

/// Bottom-sheet container for a settings picker — a title plus a scrollable
/// list of option tiles.
class SettingsPickerSheet extends StatelessWidget {
  const SettingsPickerSheet({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(14),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.borderFor(context)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 2, 4, 10),
              child: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            Flexible(child: ListView(shrinkWrap: true, children: children)),
          ],
        ),
      ),
    );
  }
}
