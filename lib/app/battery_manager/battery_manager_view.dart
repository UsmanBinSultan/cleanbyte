import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/battery_manager/battery_manager_controller.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/sift_top_app_bar.dart';

class BatteryManagerView extends StatelessWidget {
  const BatteryManagerView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BatteryManagerController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.pageBackground(context),
          body: SafeArea(
            child: Column(
              children: [
                SiftTopAppBar(
                  title: 'battery_manager'.tr,
                  subtitle: 'Health & Optimisations',
                ),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: RefreshIndicator(
                        color: AppColors.accent,
                        backgroundColor: AppColors.surface(context),
                        onRefresh: controller.loadBattery,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                          children: [
                            _BatteryCard(controller: controller),
                            const SizedBox(height: 14),
                            _ExtraBatteryCard(controller: controller),
                            const SizedBox(height: 22),
                            // _SectionLabel(label: 'Optimisations'),
                            const SizedBox(height: 10),
                            // _OptimisationsCard(controller: controller),
                            // const SizedBox(height: 22),
                            _SectionLabel(label: 'Battery Tips'),
                            const SizedBox(height: 10),
                            const _BatteryTips(),
                            const SizedBox(height: 22),
                            _ApplyButton(controller: controller),
                            const SizedBox(height: 8),
                            Center(
                              child: Text(
                                'Settings can be changed at any time',
                                style: TextStyle(
                                  color: AppColors.textFaint(context),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: AppColors.textPrimary(context),
        fontSize: 16,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Teal hero card: battery shape + health summary + stat strip.
// ---------------------------------------------------------------------------
class _BatteryCard extends StatelessWidget {
  const _BatteryCard({required this.controller});

  final BatteryManagerController controller;

  @override
  Widget build(BuildContext context) {
    final battery = controller.battery;
    final goodShape =
        battery.level >= 50 || battery.health.toLowerCase() == 'good';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.accentGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentDeep.withValues(alpha: 0.3),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          _BatteryShape(level: battery.level),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(LucideIcons.check, size: 12, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                goodShape ? 'Battery is in good shape' : 'Battery needs care',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                'Checked ${controller.lastCheckText}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                _Stat(value: '${battery.level}%', label: 'Health'),
                _StatDivider(),
                _Stat(value: controller.capacityText, label: 'Capacity'),
                _StatDivider(),
                _Stat(value: controller.temperatureText, label: 'Temp'),
                _StatDivider(),
                _Stat(
                  value: battery.voltage == null
                      ? '--'
                      : '${(battery.voltage! / 1000).toStringAsFixed(2)}V',
                  label: 'Voltage',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BatteryShape extends StatelessWidget {
  const _BatteryShape({required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 86,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 86,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$level%',
              style: const TextStyle(
                color: AppColors.accentDeep,
                fontSize: 38,
                height: 1,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Container(
            width: 7,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: Colors.white.withValues(alpha: 0.18),
    );
  }
}

// ---------------------------------------------------------------------------
// Estimated extra battery card.
// ---------------------------------------------------------------------------
class _ExtraBatteryCard extends StatelessWidget {
  const _ExtraBatteryCard({required this.controller});

  final BatteryManagerController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estimated extra battery',
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${controller.activeOptimisationCount} of '
                  '${controller.optimisations.length} optimisations on',
                  style: TextStyle(
                    color: AppColors.textMuted(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.iconChipBg(
                context,
                AppColors.accent,
                AppColors.tintTeal,
              ),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.zap, size: 13, color: AppColors.accentDeep),
                const SizedBox(width: 4),
                Text(
                  '+${controller.formatSavingMinutes(controller.estimatedSavingMinutes)}',
                  style: const TextStyle(
                    color: AppColors.accentDeep,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
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

// ---------------------------------------------------------------------------
// Optimisation toggle list.
// ---------------------------------------------------------------------------
// class _OptimisationsCard extends StatelessWidget {
//   const _OptimisationsCard({required this.controller});

//   final BatteryManagerController controller;

//   static const _icons = {
//     BatteryOptimisation.brightness: LucideIcons.sun,
//     BatteryOptimisation.backgroundData: LucideIcons.wifi,
//     BatteryOptimisation.location: LucideIcons.mapPin,
//     BatteryOptimisation.notifications: LucideIcons.bell,
//   };

//   @override
//   Widget build(BuildContext context) {
//     final options = controller.optimisations;
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.surface(context),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: AppColors.borderFor(context)),
//       ),
//       clipBehavior: Clip.antiAlias,
//       child: Column(
//         children: [
//           for (var i = 0; i < options.length; i++) ...[
//             if (i > 0)
//               Divider(
//                 height: 1,
//                 indent: 60,
//                 color: AppColors.borderFor(context),
//               ),
//             _OptimisationRow(
//               icon: _icons[options[i]]!,
//               option: options[i],
//               on: controller.isOptimisationOn(options[i]),
//               estimate: controller.formatSavingMinutes(
//                 options[i].savingMinutes,
//               ),
//               onChanged: (_) => controller.toggleOptimisation(options[i]),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }

// class _OptimisationRow extends StatelessWidget {
//   const _OptimisationRow({
//     required this.icon,
//     required this.option,
//     required this.on,
//     required this.estimate,
//     required this.onChanged,
//   });

//   final IconData icon;
//   final BatteryOptimisation option;
//   final bool on;
//   final String estimate;
//   final ValueChanged<bool> onChanged;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//       child: Row(
//         children: [
//           Container(
//             width: 36,
//             height: 36,
//             decoration: BoxDecoration(
//               color: AppColors.iconChipBg(
//                 context,
//                 AppColors.accent,
//                 AppColors.tintTeal,
//               ),
//               borderRadius: BorderRadius.circular(11),
//             ),
//             child: Icon(icon, size: 17, color: AppColors.accent),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   option.title,
//                   style: TextStyle(
//                     color: AppColors.textPrimary(context),
//                     fontSize: 13,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   option.subtitle,
//                   style: TextStyle(
//                     color: AppColors.textMuted(context),
//                     fontSize: 11,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 8),
//           Text(
//             '+$estimate',
//             style: TextStyle(
//               color: on ? AppColors.accent : AppColors.textFaint(context),
//               fontSize: 11,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//           const SizedBox(width: 8),
//           Switch.adaptive(
//             value: on,
//             onChanged: onChanged,
//             activeTrackColor: AppColors.accent,
//             activeThumbColor: Colors.white,
//           ),
//         ],
//       ),
//     );
//   }
// }

// ---------------------------------------------------------------------------
// Tips
// ---------------------------------------------------------------------------
class _BatteryTips extends StatelessWidget {
  const _BatteryTips();

  static const _tips = [
    (LucideIcons.zap, 'Charge between 20–80% for best long-term health'),
    (
      LucideIcons.clock,
      'Avoid charging overnight without Optimised Charging on',
    ),
    (
      LucideIcons.thermometer,
      'Heat degrades battery — remove case while charging',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final tip in _tips)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderFor(context)),
            ),
            child: Row(
              children: [
                Icon(tip.$1, size: 16, color: AppColors.accent),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tip.$2,
                    style: TextStyle(
                      color: AppColors.textMuted(context),
                      fontSize: 12.5,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ApplyButton extends StatelessWidget {
  const _ApplyButton({required this.controller});

  final BatteryManagerController controller;

  @override
  Widget build(BuildContext context) {
    final allOn =
        controller.activeOptimisationCount == controller.optimisations.length;
    return DecoratedBox(
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
          onPressed: allOn ? null : controller.applyAllOptimisations,
          icon: const Icon(LucideIcons.zap, size: 17),
          label: Text(
            allOn
                ? 'All optimisations on'
                : 'Apply All Optimisations · +${controller.formatSavingMinutes(controller.maxSavingMinutes)}',
          ),
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            disabledForegroundColor: Colors.white70,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
