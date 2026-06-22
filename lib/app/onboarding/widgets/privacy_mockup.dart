import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';

/// Dark phone mockup showing a "protected" gallery grid with floating privacy
/// pills, used on the privacy onboarding page.
class PrivacyMockup extends StatelessWidget {
  const PrivacyMockup({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      width: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 132,
            height: 196,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 6,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 5,
                          crossAxisSpacing: 5,
                          childAspectRatio: 0.9,
                        ),
                    itemBuilder: (context, index) {
                      // Cells 1, 2 and 5 are "flagged" in the design (dimmed
                      // with a small marker).
                      const flagged = {1, 2, 5};
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              'assets/onboarding/priv${index + 1}.jpg',
                              fit: BoxFit.cover,
                            ),
                            if (flagged.contains(index))
                              ColoredBox(
                                color: const Color(
                                  0xFF0F172A,
                                ).withValues(alpha: 0.55),
                                child: const Center(
                                  child: Icon(
                                    LucideIcons.eyeOff,
                                    size: 11,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: AppColors.accent),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.shield,
                          size: 11,
                          color: AppColors.accent,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Protected',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 2,
            child: _floatPill(LucideIcons.eyeOff, 'No tracking'),
          ),
          Positioned(
            bottom: 6,
            left: 0,
            child: _floatPill(LucideIcons.lock, 'Stays on device'),
          ),
        ],
      ),
    );
  }

  Widget _floatPill(IconData icon, String label) {
    return Builder(
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(99),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: AppColors.accent),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
