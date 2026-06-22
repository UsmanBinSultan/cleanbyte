import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/sift_bottom_nav_bar.dart';
import 'package:sift/app/home_dashboard/home_dashboard_controller.dart';
import 'package:sift/app/home_dashboard/widgets/access_gate.dart';
import 'package:sift/app/home_dashboard/widgets/approve_footer.dart';
import 'package:sift/app/home_dashboard/widgets/home_header.dart';
import 'package:sift/app/home_dashboard/widgets/quick_actions.dart';
import 'package:sift/app/home_dashboard/widgets/storage_card.dart';
import 'package:sift/app/home_dashboard/widgets/todays_suggestions.dart';
import 'package:sift/app/settings/settings_view.dart';

/// Home dashboard shell: a tab stack (home / photos / vault / settings) with the
/// shared bottom nav. The home tab's sections live under `widgets/`.
class HomeDashboardView extends StatelessWidget {
  const HomeDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeDashboardController>(
      autoRemove: false,
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.pageBackground(context),
          body: SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Stack(
                  children: [
                    IndexedStack(
                      index: controller.selectedIndex,
                      children: [
                        _HomeTab(controller: controller),
                        const _EmptyTab(title: 'Photos'),
                        const _EmptyTab(title: 'Vault'),
                        const SettingsView(),
                      ],
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: SiftBottomNavBar(
                        activeIndex: controller.selectedIndex == 3
                            ? 4
                            : controller.selectedIndex,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The home tab body: an access gate when permission is missing, otherwise the
/// scrollable stack of dashboard sections.
class _HomeTab extends StatelessWidget {
  const _HomeTab({required this.controller});

  final HomeDashboardController controller;

  @override
  Widget build(BuildContext context) {
    // No media access → show nothing but a grant-access gate (no storage/data).
    if (!controller.hasMediaAccess && !controller.isLoadingSummary) {
      return AccessGate(controller: controller);
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 104),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeHeader(controller: controller),
          const SizedBox(height: 16),
          StorageCard(controller: controller),
          const SizedBox(height: 22),
          QuickActions(controller: controller),
          const SizedBox(height: 22),
          TodaysSuggestions(controller: controller),
          const SizedBox(height: 18),
          const ApproveFooter(),
        ],
      ),
    );
  }
}

class _EmptyTab extends StatelessWidget {
  const _EmptyTab({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.textPrimary(context),
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
