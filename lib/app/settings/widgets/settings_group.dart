import 'package:flutter/material.dart';
import 'package:sift/app/components/app_colors.dart';

/// Rounded, bordered container that stacks settings rows with dividers between
/// them.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index != children.length - 1)
              Divider(
                height: 1,
                indent: 60,
                color: AppColors.borderFor(context),
              ),
          ],
        ],
      ),
    );
  }
}
