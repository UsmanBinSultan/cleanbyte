import 'package:flutter/material.dart';
import 'package:sift/app/components/app_colors.dart';

/// Onboarding page title with an optional highlighted second line. A leading
/// number in [highlight] is coloured amber; any remaining text is muted, while a
/// non-numeric highlight is shown in the accent colour.
class OnboardingTitle extends StatelessWidget {
  const OnboardingTitle({super.key, required this.title, this.highlight});

  final String title;
  final String? highlight;

  @override
  Widget build(BuildContext context) {
    final highlightedCount = highlight == null
        ? null
        : RegExp(r'^\d[\d,]*').firstMatch(highlight!);
    final children = <TextSpan>[
      TextSpan(text: title),
      if (highlightedCount != null)
        TextSpan(
          text: '\n${highlightedCount.group(0)} ',
          style: TextStyle(color: AppColors.amber),
        ),
      if (highlightedCount != null)
        TextSpan(
          text: highlight!.substring(highlightedCount.end).trimLeft(),
          style: TextStyle(color: AppColors.textMuted(context)),
        ),
      if (highlight != null && highlightedCount == null)
        TextSpan(
          text: '\n$highlight',
          style: const TextStyle(color: AppColors.accent),
        ),
    ];

    return Text.rich(
      TextSpan(children: children),
      textAlign: TextAlign.center,
      style: TextStyle(
        color: AppColors.textPrimary(context),
        fontSize: 28,
        height: 1.18,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.7,
      ),
    );
  }
}
