import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';

/// Reassurance footer shown at the bottom of the home tab.
class ApproveFooter extends StatelessWidget {
  const ApproveFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.shieldCheck,
            size: 13,
            color: AppColors.textFaint(context),
          ),
          const SizedBox(width: 6),
          Text(
            'Nothing is deleted until you approve',
            style: TextStyle(
              color: AppColors.textFaint(context),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
