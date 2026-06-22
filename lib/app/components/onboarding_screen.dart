import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/onboarding/onboarding_art.dart';
import 'package:sift/app/components/onboarding/onboarding_bullet.dart';
import 'package:sift/app/components/onboarding/onboarding_bullet_card.dart';
import 'package:sift/app/components/onboarding/onboarding_bullet_row.dart';
import 'package:sift/app/components/onboarding/onboarding_dots.dart';
import 'package:sift/app/components/onboarding/onboarding_primary_button.dart';
import 'package:sift/app/components/onboarding/onboarding_secondary_button.dart';
import 'package:sift/app/components/onboarding/onboarding_status_bar.dart';
import 'package:sift/app/components/onboarding/onboarding_title.dart';

export 'package:sift/app/components/onboarding/onboarding_art.dart'
    show OnboardingArtType;
export 'package:sift/app/components/onboarding/onboarding_bullet.dart'
    show OnboardingBullet;

/// Shared onboarding page scaffold used by the intro flow (problem framing,
/// privacy promise, permission rationale). The illustration, bullets, title,
/// dots and buttons live under `onboarding/`.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({
    super.key,
    required this.step,
    required this.title,
    required this.highlight,
    required this.body,
    required this.primaryLabel,
    required this.onPrimary,
    required this.artType,
    this.eyebrow,
    this.skipRoute,
    this.secondaryLabel,
    this.onSecondary,
    this.footer,
    this.linkLabel,
    this.onLink,
    this.artBadgeLabel,
    this.bullets = const [],
  });

  final int step;
  final String title;
  final String? highlight;
  final String body;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final OnboardingArtType artType;
  final String? eyebrow;
  final String? skipRoute;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final String? footer;
  final String? linkLabel;
  final VoidCallback? onLink;
  final String? artBadgeLabel;
  final List<OnboardingBullet> bullets;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.height < 760;
    final firstPage = step == 0;

    return Scaffold(
      backgroundColor: firstPage
          ? AppColors.mintBg
          : AppColors.pageBackground(context),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, compact ? 8 : 10, 20, 14),
              child: Column(
                children: [
                  OnboardingStatusBar(skipRoute: skipRoute),
                  SizedBox(
                    height: firstPage
                        ? (compact ? 8 : 18)
                        : (compact ? 20 : 34),
                  ),
                  OnboardingArt(type: artType, badgeLabel: artBadgeLabel),
                  SizedBox(height: firstPage ? 24 : (compact ? 22 : 38)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: firstPage
                          ? CrossAxisAlignment.center
                          : CrossAxisAlignment.start,
                      children: [
                        if (eyebrow != null) ...[
                          Text(
                            eyebrow!,
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 3.0,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        OnboardingTitle(title: title, highlight: highlight),
                        SizedBox(height: firstPage ? 16 : 16),
                        if (body.isNotEmpty) ...[
                          Text(
                            body,
                            textAlign: firstPage
                                ? TextAlign.center
                                : TextAlign.start,
                            style: TextStyle(
                              color: AppColors.textMuted(context),
                              fontSize: firstPage ? 14 : 13,
                              height: firstPage ? 1.65 : 1.55,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        if (bullets.isNotEmpty) ...[
                          SizedBox(height: firstPage ? 24 : 18),
                          firstPage
                              ? OnboardingBulletCard(bullets: bullets)
                              : Column(
                                  children: [
                                    for (final bullet in bullets)
                                      OnboardingBulletRow(bullet: bullet),
                                  ],
                                ),
                        ],
                        if (linkLabel != null) ...[
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: onLink ?? () {},
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(10, 24),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              foregroundColor: AppColors.accent,
                            ),
                            icon: Text(
                              linkLabel!,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            label: const Icon(LucideIcons.arrowRight, size: 13),
                          ),
                        ],
                        const Spacer(),
                        OnboardingDots(activeIndex: step),
                        SizedBox(height: compact ? 16 : 22),
                        OnboardingPrimaryButton(
                          label: primaryLabel,
                          onPressed: onPrimary,
                        ),
                        if (secondaryLabel != null) ...[
                          const SizedBox(height: 10),
                          OnboardingSecondaryButton(
                            label: secondaryLabel!,
                            onPressed: onSecondary ?? () => Get.back(),
                          ),
                        ],
                        if (footer != null) ...[
                          const SizedBox(height: 10),
                          Center(
                            child: Text(
                              footer!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textFaint(context),
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
