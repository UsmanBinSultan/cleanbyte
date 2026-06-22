import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sift/app/components/app_colors.dart';

/// Slim header row with an optional Skip action that jumps to [skipRoute].
class OnboardingStatusBar extends StatelessWidget {
  const OnboardingStatusBar({super.key, this.skipRoute});

  final String? skipRoute;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: skipRoute == null
                ? const SizedBox(width: 40, height: 28)
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () => Get.offAllNamed(skipRoute!),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(40, 28),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'skip'.tr,
                          style: TextStyle(
                            color: AppColors.textFaint(context),
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
