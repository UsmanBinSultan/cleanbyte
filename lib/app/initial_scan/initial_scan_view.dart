import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/home_dashboard/home_dashboard_controller.dart';
import 'package:sift/app/initial_scan/initial_scan_controller.dart';
import 'package:sift/app/routes/app_routes.dart';

class InitialScanView extends StatelessWidget {
  const InitialScanView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InitialScanController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.pageBackground(context),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Column(
                  children: [
                    _ScanTopBar(controller: controller),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _LiveScanCard(controller: controller),
                            const SizedBox(height: 16),
                            _CategoryChips(controller: controller),
                            const SizedBox(height: 22),
                            _FoundSoFar(controller: controller),
                            const SizedBox(height: 18),
                            _ScanActions(controller: controller),
                            const SizedBox(height: 14),
                            const _AiSortingNote(),
                          ],
                        ),
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

class _ScanTopBar extends StatelessWidget {
  const _ScanTopBar({required this.controller});

  final InitialScanController controller;

  @override
  Widget build(BuildContext context) {
    final scanning = controller.isScanning;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          InkWell(
            onTap: Get.back,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderFor(context)),
              ),
              child: Icon(
                LucideIcons.chevronLeft,
                size: 18,
                color: AppColors.textMuted(context),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Smart Scan',
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      LucideIcons.sparkles,
                      size: 11,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      controller.isComplete
                          ? 'Scan Complete'
                          : scanning
                          ? 'AI is analyzing your storage'
                          : 'Scan stopped',
                      style: TextStyle(
                        color: AppColors.textMuted(context),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (scanning)
            InkWell(
              onTap: controller.stopScan,
              borderRadius: BorderRadius.circular(99),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    color: AppColors.danger.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  'Stop',
                  style: TextStyle(
                    color: AppColors.danger,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LiveScanCard extends StatelessWidget {
  const _LiveScanCard({required this.controller});

  final InitialScanController controller;

  @override
  Widget build(BuildContext context) {
    final percent = (controller.progress * 100).round().clamp(0, 100);
    final stages = [
      'Scan Start',
      'Analyzing',
      'Categorizing',
      'Reviewing',
      'Complete',
    ];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderFor(context)),
        boxShadow: AppColors.isLight(context)
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
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
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                controller.isComplete ? 'Scan complete' : 'Live Scan',
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 116,
                height: 116,
                child: CustomPaint(
                  painter: _ScanRingPainter(progress: controller.progress),
                  child: Center(
                    child: Icon(
                      controller.isComplete
                          ? LucideIcons.check
                          : LucideIcons.image,
                      color: AppColors.accent,
                      size: 26,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$percent',
                          style: TextStyle(
                            color: AppColors.textPrimary(context),
                            fontSize: 40,
                            height: 1,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 6, left: 1),
                          child: Text(
                            '%',
                            style: TextStyle(
                              color: AppColors.textMuted(context),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      controller.isComplete ? 'All done' : controller.status,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _miniStat(
                      context,
                      LucideIcons.layoutGrid,
                      AppColors.iconPurple,
                      '${controller.photoCount + controller.videoCount} items',
                      'Being scanned',
                    ),
                    const SizedBox(height: 8),
                    _miniStat(
                      context,
                      LucideIcons.clock,
                      AppColors.accent,
                      controller.isComplete
                          ? 'Done'
                          : '~${controller.estimatedSecondsLeft}s left',
                      'Estimated time',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _Stepper(stages: stages, stageIndex: controller.stageIndex),
        ],
      ),
    );
  }

  Widget _miniStat(
    BuildContext context,
    IconData icon,
    Color color,
    String value,
    String label,
  ) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: AppColors.iconChipBg(
              context,
              color,
              color.withValues(alpha: 0.14),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 13, color: color),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.stages, required this.stageIndex});

  final List<String> stages;
  final int stageIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < stages.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Container(
                height: 2,
                color: i <= stageIndex
                    ? AppColors.accent
                    : AppColors.borderFor(context),
              ),
            ),
          Column(
            children: [
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: i < stageIndex
                      ? AppColors.accent
                      : i == stageIndex
                      ? AppColors.iconChipBg(
                          context,
                          AppColors.accent,
                          AppColors.tintTeal,
                        )
                      : AppColors.surfaceTint(context),
                  shape: BoxShape.circle,
                  border: i == stageIndex
                      ? Border.all(color: AppColors.accent, width: 1.5)
                      : null,
                ),
                child: i < stageIndex
                    ? const Icon(
                        LucideIcons.check,
                        size: 12,
                        color: Colors.white,
                      )
                    : Text(
                        '${i + 1}',
                        style: TextStyle(
                          color: i == stageIndex
                              ? AppColors.accent
                              : AppColors.textFaint(context),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ScanRingPainter extends CustomPainter {
  const _ScanRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: size.width / 2 - 7);
    final base = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;
    final fill = Paint()
      ..shader = const SweepGradient(
        colors: [AppColors.accent, AppColors.accentDeep, AppColors.accent],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, size.width / 2 - 7, base);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress.clamp(0, 1),
      false,
      fill,
    );
  }

  @override
  bool shouldRepaint(covariant _ScanRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.controller});

  final InitialScanController controller;

  @override
  Widget build(BuildContext context) {
    final chips = [
      (LucideIcons.image, 'Photos', AppColors.accent, AppColors.tintTeal),
      (LucideIcons.folder, 'Files', AppColors.iconBlue, AppColors.tintBlue),
      (
        LucideIcons.smartphone,
        'Screenshots',
        AppColors.iconPurple,
        AppColors.tintPurple,
      ),
      (LucideIcons.video, 'Videos', AppColors.iconAmber, AppColors.tintAmber),
      (LucideIcons.users, 'Contacts', AppColors.iconPink, AppColors.tintPink),
    ];
    final done = controller.stageIndex;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var i = 0; i < chips.length; i++)
          Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.iconChipBg(
                        context,
                        chips[i].$3,
                        chips[i].$4,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(chips[i].$1, color: chips[i].$3, size: 20),
                  ),
                  if (i < done + 1)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.pageBackground(context),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          LucideIcons.check,
                          size: 8,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                chips[i].$2,
                style: TextStyle(
                  color: AppColors.textMuted(context),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _FoundSoFar extends StatelessWidget {
  const _FoundSoFar({required this.controller});

  final InitialScanController controller;

  @override
  Widget build(BuildContext context) {
    final home = Get.isRegistered<HomeDashboardController>()
        ? HomeDashboardController.instance
        : null;
    final similar = home?.metric(HomeDashboardController.similarPhotosKey);
    final files = home?.metric(HomeDashboardController.largeFilesKey);
    final dupes = home?.metric(HomeDashboardController.duplicatesKey);

    String bytesLabel(int? bytes) => (bytes ?? 0) > 0
        ? '~${HomeDashboardController.formatBytes(bytes!)}'
        : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Found So Far',
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            InkWell(
              onTap: () => Get.toNamed(AppRoutes.reviewDelete),
              child: Row(
                children: [
                  Text(
                    'View Details',
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
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                ontap: () => Get.toNamed(AppRoutes.similarPhotos),
                label: 'Photos',
                value: '${similar?.count ?? controller.photoCount}',
                sub: bytesLabel(similar?.bytes),
                color: AppColors.accent,
                tint: AppColors.tintMint,
                icon: LucideIcons.image,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                ontap: () => Get.toNamed(AppRoutes.largeFiles),
                label: 'Old Files',
                value: '${files?.count ?? 0}',
                sub: bytesLabel(files?.bytes),
                color: AppColors.iconBlue,
                tint: AppColors.tintBlue,
                icon: LucideIcons.folder,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                ontap: () => Get.toNamed(AppRoutes.duplicates),
                label: 'Duplicates',
                value: '${dupes?.count ?? 0}',
                sub: bytesLabel(dupes?.bytes),
                color: AppColors.iconAmber,
                tint: AppColors.tintAmber,
                icon: LucideIcons.copy,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
    required this.tint,
    required this.icon,
    required this.ontap,
  });

  final String label;
  final String value;
  final String sub;
  final Color color;
  final Color tint;
  final IconData icon;
  final VoidCallback? ontap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.iconChipBg(context, color, tint),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: ontap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(height: 10),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (sub.isNotEmpty)
                Text(
                  sub,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanActions extends StatelessWidget {
  const _ScanActions({required this.controller});

  final InitialScanController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              gradient: AppColors.accentGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.28),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: TextButton.icon(
              onPressed: () => Get.toNamed(AppRoutes.reviewDelete),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              icon: const Text('Review Results'),
              label: const Icon(LucideIcons.arrowRight, size: 16),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 50,
            child: TextButton.icon(
              onPressed: controller.isScanning ? null : controller.startScan,
              style: TextButton.styleFrom(
                backgroundColor: AppColors.surface(context),
                foregroundColor: AppColors.textPrimary(context),
                side: BorderSide(color: AppColors.borderFor(context)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              icon: const Icon(LucideIcons.refreshCw, size: 14),
              label: const Text('Scan Again'),
            ),
          ),
        ),
      ],
    );
  }
}

class _AiSortingNote extends StatelessWidget {
  const _AiSortingNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceTint(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.sparkles, size: 16, color: AppColors.accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'AI sorting is detecting duplicates, blurry shots & large files.',
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
