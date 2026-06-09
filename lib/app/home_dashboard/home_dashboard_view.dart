import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/sift_bottom_nav_bar.dart';
import 'package:sift/app/home_dashboard/home_dashboard_controller.dart';
import 'package:sift/app/routes/app_routes.dart';
import 'package:sift/app/settings/settings_view.dart';

class HomeDashboardView extends StatelessWidget {
  const HomeDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeDashboardController>(
      autoRemove: false,
      builder: (controller) {
        return Scaffold(
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? const Color(0xFFF8F4EC)
              : const Color(0xFF071120),
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
                        activeIndex: controller.selectedIndex,
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

class _HomeTab extends StatelessWidget {
  const _HomeTab({required this.controller});

  final HomeDashboardController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _HomeHeader(),
          const SizedBox(height: 26),
          _StorageRing(controller: controller),
          const SizedBox(height: 18),
          _FreeUpBanner(controller: controller),
          const SizedBox(height: 16),
          _QuickCleanCard(controller: controller),
          const SizedBox(height: 16),
          _CategoryGrid(controller: controller),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'good morning'.tr,
                style: TextStyle(
                  color: Color(0xFF717A8A),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Clean Byte'.tr,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.light
                      ? const Color(0xFF17201B)
                      : Colors.white,
                  fontSize: 22,
                  height: 1,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        // Container(
        //   height: 30,
        //   padding: const EdgeInsets.symmetric(horizontal: 12),
        //   decoration: BoxDecoration(
        //     color: const Color(0xFF121B2C),
        //     borderRadius: BorderRadius.circular(18),
        //     border: Border.all(color: const Color(0xFF223047)),
        //   ),
        //   child: const Row(
        //     mainAxisSize: MainAxisSize.min,
        //     children: [
        //       Icon(Icons.cloud_done, size: 11, color: Color(0xFF18D0B8)),
        //       SizedBox(width: 6),
        //       Text(
        //         'Saved 47.2 GB',
        //         style: TextStyle(
        //           color: Color(0xFFC5CBD4),
        //           fontSize: 10,
        //           fontWeight: FontWeight.w800,
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }
}

class _StorageRing extends StatelessWidget {
  const _StorageRing({required this.controller});

  final HomeDashboardController controller;

  @override
  Widget build(BuildContext context) {
    final light = Theme.of(context).brightness == Brightness.light;
    final storage = controller.storage;
    final usedText = _formatStorageBytes(storage.usedBytes);
    final totalText = _formatStorageBytes(storage.totalBytes);
    final freeText = _formatStorageBytes(storage.freeBytes);
    return Center(
      child: SizedBox(
        width: 190,
        height: 190,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size.square(190),
              painter: _StorageRingPainter(progress: storage.usedFraction),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      usedText.split(' ').first,
                      style: TextStyle(
                        color: light ? const Color(0xFF17201B) : Colors.white,
                        fontSize: 36,
                        height: 0.9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 2, bottom: 5),
                      child: Text(
                        usedText.split(' ').last,
                        style: TextStyle(
                          color: light ? const Color(0xFF17201B) : Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  storage.totalBytes <= 0
                      ? 'calculating storage'.tr
                      : 'used of'.trParams({'total': totalText}),
                  style: const TextStyle(
                    color: Color(0xFF8A93A2),
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  storage.totalBytes <= 0
                      ? 'please wait'.tr
                      : 'free space'.trParams({'free': freeText}),
                  style: const TextStyle(
                    color: Color(0xFFFFB41B),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _formatStorageBytes(num bytes) {
  if (bytes <= 0) {
    return '0 GB';
  }
  const kb = 1000;
  const mb = kb * 1000;
  const gb = mb * 1000;
  if (bytes >= gb) {
    final value = bytes / gb;
    return '${value >= 10 ? value.toStringAsFixed(0) : value.toStringAsFixed(1)} GB';
  }
  if (bytes >= mb) {
    final value = bytes / mb;
    return '${value >= 10 ? value.toStringAsFixed(0) : value.toStringAsFixed(1)} MB';
  }
  return '${(bytes / kb).toStringAsFixed(1)} KB';
}

class _StorageRingPainter extends CustomPainter {
  const _StorageRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: 73);
    final basePaint = Paint()
      ..color = const Color(0xFF172132)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    final progressPaint = Paint()
      ..shader = const SweepGradient(
        colors: [
          Color(0xFFFFB319),
          Color(0xFFFFC132),
          Color(0xFFFFA914),
          Color(0xFFFFB319),
        ],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, math.pi * 2, false, basePaint);
    canvas.drawArc(
      rect,
      -math.pi / 2 + 0.1,
      (math.pi * 2 * progress.clamp(0, 1)).toDouble(),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _StorageRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _FreeUpBanner extends StatelessWidget {
  const _FreeUpBanner({required this.controller});

  final HomeDashboardController controller;

  @override
  Widget build(BuildContext context) {
    final light = Theme.of(context).brightness == Brightness.light;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return InkWell(
      onTap: () async {
        await Get.toNamed(AppRoutes.initialScan);
        await controller.refreshSummary();
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: light ? const Color(0xFFE6FBF4) : const Color(0xFF082E36),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: light ? const Color(0xFF95E0D0) : const Color(0xFF0D5960),
          ),
          boxShadow: light
              ? [
                  BoxShadow(
                    color: const Color(0xFF14B8A6).withValues(alpha: 0.14),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'you can free up some space'.tr,
                style: TextStyle(
                  color: light ? const Color(0xFF17201B) : Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              // Text(
              //   freeUpText,
              //   style: const TextStyle(
              //     color: Color(0xFF18D0B8),
              //     fontSize: 14,
              //     fontWeight: FontWeight.w900,
              //   ),
              // ),
              // const SizedBox(width: 10),
              Icon(
                rtl ? LucideIcons.chevronLeft : LucideIcons.chevronRight,
                color: Color(0xFF18D0B8),
                size: 17,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickCleanCard extends StatelessWidget {
  const _QuickCleanCard({required this.controller});

  final HomeDashboardController controller;

  @override
  Widget build(BuildContext context) {
    final light = Theme.of(context).brightness == Brightness.light;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final readyText = HomeDashboardController.formatBytes(
      controller.quickCleanReadyBytes,
    );
    return InkWell(
      onTap: controller.isQuickCleaning ? null : controller.quickClean,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 74,
        padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
        decoration: BoxDecoration(
          color: light ? Colors.white : const Color(0xFF0B2D35),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: light ? const Color(0xFFE4DCCB) : const Color(0xFF0B5B62),
          ),
          boxShadow: light
              ? [
                  BoxShadow(
                    color: const Color(0xFFBFA46B).withValues(alpha: 0.16),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF1DC0AE),
                borderRadius: BorderRadius.circular(14),
              ),
              child: controller.isQuickCleaning
                  ? const Center(
                      child: SizedBox(
                        width: 19,
                        height: 19,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : const Icon(
                      LucideIcons.activity,
                      color: Colors.white,
                      size: 21,
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'cache clean'.tr,
                    style: TextStyle(
                      color: light ? const Color(0xFF17201B) : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.isQuickCleaning
                        ? 'cleaning app cache'.tr
                        : 'auto tidy ready'.trParams({'ready': readyText}),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF8D96A5),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              rtl ? LucideIcons.chevronLeft : LucideIcons.chevronRight,
              color: const Color(0xFF738091),
              size: 17,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.controller});

  final HomeDashboardController controller;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _CategoryData(
        title: 'Photos',
        subtitle: controller.metricSubtitle(
          HomeDashboardController.similarPhotosKey,
        ),
        icon: LucideIcons.image,
        color: const Color(0xFF18D0B8),
        route: AppRoutes.similarPhotos,
      ),
      _CategoryData(
        title: 'large videos',
        subtitle: controller.metricSubtitle(
          HomeDashboardController.largeVideosKey,
        ),
        icon: LucideIcons.video,
        color: const Color(0xFFD99A20),
        route: AppRoutes.largeVideos,
      ),
      _CategoryData(
        title: 'screenshots',
        subtitle: controller.metricSubtitle(
          HomeDashboardController.screenshotsKey,
        ),
        icon: LucideIcons.camera,
        color: const Color(0xFF7C54E8),
        route: AppRoutes.screenshots,
      ),

      // _CategoryData(
      //   title: 'Live Photos',
      //   subtitle: controller.metricSubtitle(
      //     HomeDashboardController.livePhotosKey,
      //   ),
      //   icon: LucideIcons.image,
      //   color: const Color(0xFF2E9DCC),
      // ),
      _CategoryData(
        title: 'duplicates',
        subtitle: controller.metricSubtitle(
          HomeDashboardController.duplicatesKey,
        ),
        icon: LucideIcons.copy,
        color: const Color(0xFF64748B),
        route: AppRoutes.duplicates,
      ),
      _CategoryData(
        title: 'blurred photos',
        subtitle: controller.metricSubtitle(
          HomeDashboardController.blurredPhotosKey,
        ),
        icon: LucideIcons.focus,
        color: const Color(0xFFE95D73),
        route: AppRoutes.blurredPhotos,
      ),
      _CategoryData(
        title: 'large files',
        subtitle: controller.metricSubtitle(
          HomeDashboardController.largeFilesKey,
        ),
        icon: Icons.insert_drive_file_outlined,
        color: const Color(0xFF64748B),
        route: AppRoutes.largeFiles,
      ),
      _CategoryData(
        title: 'duplicate contacts',
        subtitle: controller.metricSubtitle(
          HomeDashboardController.duplicateContactsKey,
        ),
        icon: Icons.group_outlined,
        color: const Color(0xFF64748B),
        route: AppRoutes.duplicateContacts,
      ),
      _CategoryData(
        title: 'ai cleanup',
        subtitle: controller.metricSubtitle(
          HomeDashboardController.aiCleanupKey,
        ),
        icon: LucideIcons.sparkles,
        color: const Color(0xFF18D0B8),
        route: AppRoutes.initialScan,
      ),
      _CategoryData(
        title: 'Whatsapp Cleaner',
        subtitle: controller.metricSubtitle(
          HomeDashboardController.whatsappCleanerKey,
        ),
        icon: LucideIcons.messageCircle,
        color: const Color(0xFF10B981),
        route: AppRoutes.whatsappCleaner,
      ),

      _CategoryData(
        title: 'Apps Manager',
        subtitle: controller.metricSubtitle(
          HomeDashboardController.appsManagerKey,
        ),
        icon: LucideIcons.layoutGrid,
        color: const Color(0xFF64748B),
        route: AppRoutes.appsManager,
      ),
      _CategoryData(
        title: 'Photo Compressor',
        subtitle: controller.metricSubtitle(
          HomeDashboardController.photoCompressorKey,
        ),
        icon: LucideIcons.minimize2,
        color: const Color(0xFF7C54E8),
        route: AppRoutes.photoCompressor,
      ),
      _CategoryData(
        title: 'Battery Manager',
        subtitle: controller.metricSubtitle(
          HomeDashboardController.batteryManagerKey,
        ),
        icon: LucideIcons.battery,
        color: const Color(0xFFD99A20),
        route: AppRoutes.batteryManager,
      ),
    ];

    return GridView.builder(
      itemCount: cards.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.42,
      ),
      itemBuilder: (context, index) =>
          _CategoryCard(data: cards[index], controller: controller),
    );
  }
}

class _CategoryData {
  const _CategoryData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.route,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String? route;
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.data, required this.controller});

  final _CategoryData data;
  final HomeDashboardController controller;

  @override
  Widget build(BuildContext context) {
    final light = Theme.of(context).brightness == Brightness.light;
    return InkWell(
      onTap: data.route == null
          ? null
          : () async {
              await Get.toNamed(data.route!);
              await controller.refreshSummary();
            },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: light ? Colors.white : const Color(0xFF111929),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: light ? const Color(0xFFE8E1D3) : const Color(0xFF1F2A3E),
          ),
          boxShadow: light
              ? [
                  BoxShadow(
                    color: data.color.withValues(alpha: 0.14),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: data.color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(data.icon, color: data.color, size: 18),
            ),
            const Spacer(),
            Text(
              data.title.tr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: light ? const Color(0xFF17201B) : Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              data.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF8B94A3),
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
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
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
