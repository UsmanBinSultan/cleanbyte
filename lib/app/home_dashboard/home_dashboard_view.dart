import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
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

class _HomeTab extends StatelessWidget {
  const _HomeTab({required this.controller});

  final HomeDashboardController controller;

  @override
  Widget build(BuildContext context) {
    // No media access → show nothing but a grant-access gate (no storage/data).
    if (!controller.hasMediaAccess && !controller.isLoadingSummary) {
      return _AccessGate(controller: controller);
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 104),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HomeHeader(controller: controller),
          const SizedBox(height: 16),
          _StorageCard(controller: controller),
          const SizedBox(height: 22),
          _QuickActions(controller: controller),
          const SizedBox(height: 22),
          _TodaysSuggestions(controller: controller),
          const SizedBox(height: 18),
          const _ApproveFooter(),
        ],
      ),
    );
  }
}

class _AccessGate extends StatelessWidget {
  const _AccessGate({required this.controller});

  final HomeDashboardController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 6, 24, 104),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: _CircleIconButton(
              icon: LucideIcons.settings,
              onTap: () => controller.changeTab(3),
            ),
          ),
          const Spacer(),
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.iconChipBg(
                context,
                AppColors.accent,
                AppColors.tintTeal,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.imagePlus,
              size: 38,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Allow access to clean up',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Clean Byte scans your photos and files on your device to find '
            'what is taking up space. Your data never leaves your phone.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted(context),
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 26),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppColors.accentGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: TextButton.icon(
                onPressed: controller.requestMediaAccess,
                icon: const Icon(LucideIcons.unlock, size: 17),
                label: const Text('Allow Access'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: controller.openMediaSettings,
            child: Text(
              'Open Settings',
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.shieldCheck,
                size: 13,
                color: AppColors.textFaint(context),
              ),
              const SizedBox(width: 6),
              Text(
                'Nothing leaves your device',
                style: TextStyle(
                  color: AppColors.textFaint(context),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header: greeting + reviewable subtitle + settings gear.
// ---------------------------------------------------------------------------
class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.controller});

  final HomeDashboardController controller;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final reclaimable = controller.reclaimableBytes;
    final subtitle = controller.isLoadingSummary && reclaimable <= 0
        ? 'Checking what can be cleaned…'
        : reclaimable > 0
        ? '${HomeDashboardController.formatBytes(reclaimable)} may be reviewable'
        : 'Your storage looks tidy';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$_greeting 👋',
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppColors.textMuted(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        _CircleIconButton(
          icon: LucideIcons.settings,
          onTap: () => controller.changeTab(3),
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderFor(context)),
        ),
        child: Icon(icon, size: 18, color: AppColors.textMuted(context)),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Storage card: teal gradient with a small usage ring + Start Smart Scan.
// ---------------------------------------------------------------------------
class _StorageCard extends StatelessWidget {
  const _StorageCard({required this.controller});

  final HomeDashboardController controller;

  @override
  Widget build(BuildContext context) {
    final storage = controller.storage;
    final hasData = storage.totalBytes > 0;
    final percent = (storage.usedFraction * 100).round();
    final usedText = _formatStorageBytes(storage.usedBytes);
    final totalText = _formatStorageBytes(storage.totalBytes);
    final freeText = _formatStorageBytes(storage.freeBytes);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.accentGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentDeep.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 66,
                height: 66,
                child: CustomPaint(
                  painter: _UsageRingPainter(
                    progress: hasData ? storage.usedFraction : 0,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          hasData ? '$percent%' : '--',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            height: 1,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Text(
                          'used',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasData ? usedText : 'Calculating…',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        height: 1.1,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (hasData)
                      Text(
                        'of $totalText used',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    const SizedBox(height: 8),
                    if (hasData)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$freeText available',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  controller.isLoadingSummary
                      ? 'Scanning your storage…'
                      : 'Tap to run a smart scan',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              _StartScanButton(controller: controller),
            ],
          ),
        ],
      ),
    );
  }
}

class _StartScanButton extends StatelessWidget {
  const _StartScanButton({required this.controller});

  final HomeDashboardController controller;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(99),
      child: InkWell(
        borderRadius: BorderRadius.circular(99),
        onTap: () async {
          await Get.toNamed(AppRoutes.initialScan);
          await controller.refreshSummary();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                LucideIcons.search,
                size: 14,
                color: AppColors.accentDeep,
              ),
              const SizedBox(width: 6),
              Text(
                'Start Smart Scan',
                style: TextStyle(
                  color: AppColors.accentDeep,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UsageRingPainter extends CustomPainter {
  const _UsageRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final base = Paint()
      ..color = Colors.white.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final fill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, base);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      (math.pi * 2 * progress.clamp(0, 1)).toDouble(),
      false,
      fill,
    );
  }

  @override
  bool shouldRepaint(covariant _UsageRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
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

// ---------------------------------------------------------------------------
// Quick actions: a 2-column grid of category cards with a "See all" toggle.
// ---------------------------------------------------------------------------
class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.controller});

  final HomeDashboardController controller;

  List<_ActionData> _all() => [
    _ActionData(
      title: 'Duplicate Photos',
      metricKey: HomeDashboardController.duplicatesKey,
      icon: LucideIcons.copy,
      iconColor: AppColors.accent,
      tint: AppColors.tintTeal,
      route: AppRoutes.duplicates,
    ),
    _ActionData(
      title: 'Large Videos',
      metricKey: HomeDashboardController.largeVideosKey,
      icon: LucideIcons.video,
      iconColor: AppColors.iconAmber,
      tint: AppColors.tintAmber,
      route: AppRoutes.largeVideos,
    ),
    _ActionData(
      title: 'Screenshots',
      metricKey: HomeDashboardController.screenshotsKey,
      icon: LucideIcons.smartphone,
      iconColor: AppColors.iconPurple,
      tint: AppColors.tintPurple,
      route: AppRoutes.screenshots,
    ),
    _ActionData(
      title: 'Files',
      metricKey: HomeDashboardController.largeFilesKey,
      icon: LucideIcons.folder,
      iconColor: AppColors.iconBlue,
      tint: AppColors.tintBlue,
      route: AppRoutes.largeFiles,
    ),
    _ActionData(
      title: 'Photos',
      metricKey: HomeDashboardController.similarPhotosKey,
      icon: LucideIcons.image,
      iconColor: AppColors.accent,
      tint: AppColors.tintMint,
      route: AppRoutes.similarPhotos,
    ),
    _ActionData(
      title: 'Blurred Photos',
      metricKey: HomeDashboardController.blurredPhotosKey,
      icon: LucideIcons.focus,
      iconColor: AppColors.iconPink,
      tint: AppColors.tintPink,
      route: AppRoutes.blurredPhotos,
    ),
    _ActionData(
      title: 'Photo Compressor',
      metricKey: HomeDashboardController.photoCompressorKey,
      icon: LucideIcons.minimize2,
      iconColor: AppColors.iconPink,
      tint: AppColors.tintPink,
      route: AppRoutes.photoCompressor,
    ),
    _ActionData(
      title: 'Duplicate Contacts',
      metricKey: HomeDashboardController.duplicateContactsKey,
      icon: LucideIcons.users,
      iconColor: AppColors.iconAmber,
      tint: AppColors.tintAmber,
      route: AppRoutes.duplicateContacts,
    ),
    _ActionData(
      title: 'WhatsApp Cleaner',
      metricKey: HomeDashboardController.whatsappCleanerKey,
      icon: LucideIcons.messageCircle,
      iconColor: AppColors.whatsapp,
      tint: AppColors.tintGreen,
      route: AppRoutes.whatsappCleaner,
    ),
    _ActionData(
      title: 'Apps Manager',
      metricKey: HomeDashboardController.appsManagerKey,
      icon: LucideIcons.layoutGrid,
      iconColor: AppColors.iconBlue,
      tint: AppColors.tintBlue,
      route: AppRoutes.appsManager,
    ),
    _ActionData(
      title: 'Battery Saver',
      metricKey: HomeDashboardController.batteryManagerKey,
      icon: LucideIcons.batteryCharging,
      iconColor: AppColors.accent,
      tint: AppColors.tintGreen,
      route: AppRoutes.batteryManager,
    ),
    _ActionData(
      title: 'AI Cleanup',
      metricKey: HomeDashboardController.aiCleanupKey,
      icon: LucideIcons.sparkles,
      iconColor: AppColors.iconPurple,
      tint: AppColors.tintPurple,
      route: AppRoutes.initialScan,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final all = _all();
    final visible = all.take(4).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Quick Actions',
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                await Get.toNamed(AppRoutes.allActions);
                await controller.refreshSummary();
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  children: [
                    Text(
                      'See all',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Icon(
                      LucideIcons.chevronRight,
                      size: 15,
                      color: AppColors.accent,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          itemCount: visible.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.55,
          ),
          itemBuilder: (context, index) =>
              _ActionCard(data: visible[index], controller: controller),
        ),
      ],
    );
  }
}

class _ActionData {
  const _ActionData({
    required this.title,
    required this.metricKey,
    required this.icon,
    required this.iconColor,
    required this.tint,
    required this.route,
  });

  final String title;
  final String metricKey;
  final IconData icon;
  final Color iconColor;
  final Color tint;
  final String route;
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.data, required this.controller});

  final _ActionData data;
  final HomeDashboardController controller;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () async {
        await Get.toNamed(data.route);
        await controller.refreshSummary();
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.borderFor(context)),
          boxShadow: AppColors.isLight(context)
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.iconChipBg(
                      context,
                      data.iconColor,
                      data.tint,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(data.icon, color: data.iconColor, size: 20),
                ),
                const Spacer(),
                Icon(
                  LucideIcons.chevronRight,
                  size: 15,
                  color: AppColors.textFaint(context),
                ),
              ],
            ),
            const Spacer(),
            Text(
              data.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              controller.metricSubtitle(data.metricKey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Today's suggestions: a card of recommended actions derived from metrics.
// ---------------------------------------------------------------------------
class _TodaysSuggestions extends StatelessWidget {
  const _TodaysSuggestions({required this.controller});

  final HomeDashboardController controller;

  List<_Suggestion> _build() {
    final suggestions = <_Suggestion>[];
    void add(
      String key,
      String Function(int count) title,
      IconData icon,
      Color color,
      Color tint,
      String route,
    ) {
      final metric = controller.metric(key);
      if (metric.count <= 0) return;
      final savings = metric.bytes > 0
          ? '~${HomeDashboardController.formatBytes(metric.bytes)} potential savings'
          : '${metric.count} to review';
      suggestions.add(
        _Suggestion(
          title: title(metric.count),
          subtitle: savings,
          icon: icon,
          color: color,
          tint: tint,
          route: route,
        ),
      );
    }

    add(
      HomeDashboardController.similarPhotosKey,
      (c) => 'Review $c similar photos',
      LucideIcons.search,
      AppColors.accent,
      AppColors.tintMint,
      AppRoutes.similarPhotos,
    );
    add(
      HomeDashboardController.largeVideosKey,
      (c) => 'Compress $c large videos',
      LucideIcons.video,
      AppColors.iconAmber,
      AppColors.tintAmber,
      AppRoutes.largeVideos,
    );
    add(
      HomeDashboardController.screenshotsKey,
      (c) => 'Clean $c old screenshots',
      LucideIcons.smartphone,
      AppColors.iconPurple,
      AppColors.tintPurple,
      AppRoutes.screenshots,
    );
    add(
      HomeDashboardController.duplicateContactsKey,
      (c) => 'Merge $c duplicate contacts',
      LucideIcons.users,
      AppColors.iconBlue,
      AppColors.tintBlue,
      AppRoutes.duplicateContacts,
    );
    return suggestions.take(4).toList();
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = _build();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Today's Suggestions",
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const Spacer(),
            if (suggestions.isNotEmpty)
              Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.iconChipBg(
                    context,
                    AppColors.accent,
                    AppColors.tintTeal,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${suggestions.length}',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderFor(context)),
            boxShadow: AppColors.isLight(context)
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: suggestions.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      controller.isLoadingSummary
                          ? 'Looking for things to clean…'
                          : "You're all caught up 🎉",
                      style: TextStyle(
                        color: AppColors.textMuted(context),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              : Column(
                  children: [
                    for (var i = 0; i < suggestions.length; i++) ...[
                      if (i > 0)
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: AppColors.borderFor(context),
                          indent: 16,
                          endIndent: 16,
                        ),
                      _SuggestionRow(
                        suggestion: suggestions[i],
                        controller: controller,
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _Suggestion {
  const _Suggestion({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.tint,
    required this.route,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color tint;
  final String route;
}

class _SuggestionRow extends StatelessWidget {
  const _SuggestionRow({required this.suggestion, required this.controller});

  final _Suggestion suggestion;
  final HomeDashboardController controller;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await Get.toNamed(suggestion.route);
        await controller.refreshSummary();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.iconChipBg(
                  context,
                  suggestion.color,
                  suggestion.tint,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(suggestion.icon, color: suggestion.color, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suggestion.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    suggestion.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              size: 15,
              color: AppColors.textFaint(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApproveFooter extends StatelessWidget {
  const _ApproveFooter();

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
