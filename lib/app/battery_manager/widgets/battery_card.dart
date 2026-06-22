import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/battery_manager/battery_manager_controller.dart';
import 'package:sift/app/components/app_colors.dart';

/// Teal hero card: a battery shape, a health summary line and a stat strip
/// (health / capacity / temp / voltage).
class BatteryCard extends StatelessWidget {
  const BatteryCard({super.key, required this.controller});

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
                const _StatDivider(),
                _Stat(value: controller.capacityText, label: 'Capacity'),
                const _StatDivider(),
                _Stat(value: controller.temperatureText, label: 'Temp'),
                const _StatDivider(),
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
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: Colors.white.withValues(alpha: 0.18),
    );
  }
}
