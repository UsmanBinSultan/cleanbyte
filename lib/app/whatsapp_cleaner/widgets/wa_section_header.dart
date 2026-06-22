import 'package:flutter/material.dart';
import 'package:sift/app/components/app_colors.dart';

/// Row title with a green trailing count, used above the hub's storage and
/// insights sections.
class WaSectionHeader extends StatelessWidget {
  const WaSectionHeader({super.key, required this.title, required this.action});

  final String title;
  final String action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          action,
          style: const TextStyle(
            color: AppColors.whatsapp,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
