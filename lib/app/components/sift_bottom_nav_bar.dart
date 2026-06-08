import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/home_dashboard/home_dashboard_controller.dart';
import 'package:sift/app/routes/app_routes.dart';

/// Shared bottom navigation bar used on the home dashboard and on the
/// secondary screens that are reached from it (e.g. AI categories).
///
/// [activeIndex] highlights the current destination:
/// 0 = home, 1 = image categories, 2 = whatsapp cleaner, 3 = settings.
class SiftBottomNavBar extends StatelessWidget {
  const SiftBottomNavBar({super.key, required this.activeIndex});

  final int activeIndex;

  void _onTap(int index) {
    if (index == activeIndex) {
      return;
    }
    switch (index) {
      case 0:
        _backToHomeTab(0);
        break;
      case 1:
        Get.toNamed(AppRoutes.aiCategories, arguments: {'fromNav': true});
        break;
      case 2:
        Get.toNamed(AppRoutes.whatsappCleaner, arguments: {'fromNav': true});
        break;
      case 3:
        _backToHomeTab(3);
        break;
    }
  }

  void _backToHomeTab(int tab) {
    HomeDashboardController.instance.changeTab(tab);
    // Pop back to the home dashboard if we are on a pushed route.
    if (Get.currentRoute != AppRoutes.homeDashboard) {
      Get.until((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : const Color(0xFF08101E),
        border: Border(
          top: BorderSide(
            color: Theme.of(context).brightness == Brightness.light
                ? const Color(0xFFE7E2D6)
                : const Color(0xFF121C2C),
          ),
        ),
        boxShadow: Theme.of(context).brightness == Brightness.light
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 22,
                  offset: const Offset(0, -8),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          _NavItem(
            label: 'home'.tr,
            icon: LucideIcons.home,
            active: activeIndex == 0,
            onTap: () => _onTap(0),
          ),
          _NavItem(
            label: 'Ai Categories'.tr,
            icon: LucideIcons.sparkles,
            active: activeIndex == 1,
            onTap: () => _onTap(1),
          ),
          _NavItem(
            label: 'wa clean'.tr,
            icon: LucideIcons.messageCircle,
            active: activeIndex == 2,
            onTap: () => _onTap(2),
          ),
          _NavItem(
            label: 'settings'.tr,
            icon: LucideIcons.settings,
            active: activeIndex == 3,
            onTap: () => _onTap(3),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFF18D0B8) : const Color(0xFF697385);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
