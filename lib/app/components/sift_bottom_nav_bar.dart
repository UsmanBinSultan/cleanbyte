import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/home_dashboard/home_dashboard_controller.dart';
import 'package:sift/app/routes/app_routes.dart';

/// Shared bottom navigation bar used on the home dashboard and on the
/// secondary screens that are reached from it (e.g. AI categories).
///
/// [activeIndex] highlights the current destination:
/// 0 = home, 1 = image categories, 2 = all actions, 3 = whatsapp cleaner,
/// 4 = settings. The previous four-tab home dashboard still passes 3 for
/// settings, so that value is normalized in the widget below.
class SiftBottomNavBar extends StatelessWidget {
  const SiftBottomNavBar({super.key, required this.activeIndex});

  final int activeIndex;

  int get _normalizedActiveIndex => activeIndex == 4 ? 4 : activeIndex;

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
        Get.toNamed(AppRoutes.allActions, arguments: {'fromNav': true});
        break;
      case 3:
        Get.toNamed(AppRoutes.whatsappCleaner, arguments: {'fromNav': true});
        break;
      case 4:
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
      height: 85,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : const Color(0xFF08101E),
        border: Border(
          top: BorderSide(
            color: Theme.of(context).brightness == Brightness.light
                ? const Color(0xFFE2E8F0)
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
            active: _normalizedActiveIndex == 0,
            onTap: () => _onTap(0),
          ),
          _NavItem(
            label: 'Ai Categories'.tr,
            icon: LucideIcons.sparkles,
            active: _normalizedActiveIndex == 1,
            onTap: () => _onTap(1),
          ),
          _NavItem(
            label: 'All Actions'.tr,
            icon: LucideIcons.layoutGrid,
            active: _normalizedActiveIndex == 2,
            onTap: () => _onTap(2),
          ),
          _NavItem(
            label: 'wa clean'.tr,
            icon: LucideIcons.messageCircle,
            iconAsset: 'assets/icons/whatsapp.svg',
            active: _normalizedActiveIndex == 3,
            onTap: () => _onTap(3),
          ),
          _NavItem(
            label: 'Settings'.tr,
            icon: LucideIcons.settings,
            active: _normalizedActiveIndex == 4,
            onTap: () => _onTap(4),
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
    this.iconAsset,
  });

  final String label;
  final IconData icon;
  final String? iconAsset;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFF1DC8A8) : const Color(0xFF94A3B8);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconAsset != null)
              SvgPicture.asset(
                iconAsset!,
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              )
            else
              Icon(icon, size: 22, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: active ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
