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
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? const Color(0xFFFFFBF5)
              : const Color(0xFF071120),
          body: SafeArea(
            child: Column(
              children: [
                SiftTopAppBar(
                  title: 'battery_manager'.tr,
                  trailing: IconButton(
                    onPressed: controller.isLoading
                        ? null
                        : controller.loadBattery,
                    icon: controller.isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF18D0B8),
                            ),
                          )
                        : const Icon(LucideIcons.refreshCw),
                    color: const Color(0xFF18D0B8),
                    tooltip: 'Refresh',
                  ),
                ),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 430),
                      child: RefreshIndicator(
                        color: const Color(0xFF18D0B8),
                        backgroundColor: AppColors.surface(context),
                        onRefresh: controller.loadBattery,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 48),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _BatteryHealthCard(controller: controller),
                              const SizedBox(height: 22),
                              const _BatteryTipsCard(),
                            ],
                          ),
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

class _BatteryHealthCard extends StatelessWidget {
  const _BatteryHealthCard({required this.controller});

  final BatteryManagerController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderFor(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: AppColors.isLight(context) ? 0.06 : 0.22,
            ),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: _BatteryGauge(battery: controller.battery)),
          const SizedBox(height: 34),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: _HealthText(controller: controller)),
              _LastCheckText(controller: controller),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: AppColors.borderFor(context), height: 1),
          const SizedBox(height: 14),
          _BatteryDetailRow(controller: controller),
          if (controller.errorMessage != null) ...[
            const SizedBox(height: 14),
            Text(
              controller.errorMessage!,
              style: const TextStyle(
                color: Color(0xFFE76F51),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BatteryGauge extends StatelessWidget {
  const _BatteryGauge({required this.battery});

  final BatterySnapshot battery;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 88,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            right: 2,
            child: Container(
              width: 12,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFF5C6675),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 18,
            child: Container(
              height: 76,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF536071), width: 3),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    const ColoredBox(color: Color(0xFF142131)),
                    FractionallySizedBox(
                      widthFactor: battery.fillFraction,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF2ED3C4), Color(0xFF9AB17F)],
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        '${battery.level}%',
                        style: TextStyle(
                          color: AppColors.isLight(context)
                              ? Colors.black
                              : Colors.white,
                          fontSize: 31,
                          height: 1,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthText extends StatelessWidget {
  const _HealthText({required this.controller});

  final BatteryManagerController controller;

  @override
  Widget build(BuildContext context) {
    final light = AppColors.isLight(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HEALTH',
          style: TextStyle(
            color: AppColors.textFaint(context),
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.2,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '${controller.battery.level}%',
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              controller.battery.health,
              style: TextStyle(
                color: light
                    ? const Color(0xFF0E8F80)
                    : const Color(0xFF42E6C7),
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          controller.battery.isCharging
              ? 'Charging'
              : controller.battery.status,
          style: TextStyle(
            color: AppColors.textMuted(context),
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _BatteryDetailRow extends StatelessWidget {
  const _BatteryDetailRow({required this.controller});

  final BatteryManagerController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _BatteryDetailMetric(
            label: 'CAPACITY',
            value: controller.capacityText,
            icon: LucideIcons.battery,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _BatteryDetailMetric(
            label: 'TEMPERATURE',
            value: controller.temperatureText,
            icon: LucideIcons.thermometer,
          ),
        ),
      ],
    );
  }
}

class _BatteryDetailMetric extends StatelessWidget {
  const _BatteryDetailMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.isLight(context)
            ? AppColors.lightSurfaceTint
            : const Color(0xFF172231),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF18D0B8), size: 18),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textFaint(context),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
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

class _LastCheckText extends StatelessWidget {
  const _LastCheckText({required this.controller});

  final BatteryManagerController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'Last check',
          style: TextStyle(
            color: AppColors.textMuted(context),
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          controller.lastCheckText,
          style: TextStyle(
            color: AppColors.textFaint(context),
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _BatteryTipsCard extends StatelessWidget {
  const _BatteryTipsCard();

  static const _tips = [
    'Charge to 80% if you can. Full charges age the battery faster.',
    'Avoid hot cars. Heat is the #1 driver of capacity loss.',
    'Use Optimized Charging so your phone learns your schedule.',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 12),
          child: Text(
            'BATTERY TIPS',
            style: TextStyle(
              color: AppColors.textFaint(context),
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderFor(context)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var index = 0; index < _tips.length; index++)
                _BatteryTipRow(
                  number: '${index + 1}'.padLeft(2, '0'),
                  text: _tips[index],
                  showDivider: index != _tips.length - 1,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BatteryTipRow extends StatelessWidget {
  const _BatteryTipRow({
    required this.number,
    required this.text,
    required this.showDivider,
  });

  final String number;
  final String text;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: showDivider
            ? Border(bottom: BorderSide(color: AppColors.borderFor(context)))
            : null,
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Text(
              number,
              style: TextStyle(
                color: AppColors.textFaint(context),
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 12,
                height: 1.45,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
