import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// User-toggleable battery optimisations shown on the Battery screen.
///
/// These are preferences the user opts into (not live OS controls), so the
/// per-item minute savings are indicative estimates used for the UI summary.
enum BatteryOptimisation {
  // brightness('Reduce screen brightness', 'Auto at 70% peak', 45),
  // backgroundData('Disable background data', 'For non-essential apps', 30),
  location('Limit location services', 'Only while using', 60),

  notifications('Reduce notifications', 'Group non-priority', 20);

  const BatteryOptimisation(this.title, this.subtitle, this.savingMinutes);

  final String title;
  final String subtitle;
  final int savingMinutes;
}

class BatterySnapshot {
  const BatterySnapshot({
    required this.level,
    required this.health,
    required this.status,
    required this.isCharging,
    required this.capacityPercent,
    required this.designCapacityMah,
    required this.estimatedCapacityMah,
    required this.temperatureCelsius,
    required this.voltage,
    required this.checkedAt,
  });

  const BatterySnapshot.empty()
    : this(
        level: 0,
        health: 'Unknown',
        status: 'Unknown',
        isCharging: false,
        capacityPercent: null,
        designCapacityMah: null,
        estimatedCapacityMah: null,
        temperatureCelsius: null,
        voltage: null,
        checkedAt: null,
      );

  final int level;
  final String health;
  final String status;
  final bool isCharging;
  final int? capacityPercent;
  final double? designCapacityMah;
  final double? estimatedCapacityMah;
  final double? temperatureCelsius;
  final int? voltage;
  final DateTime? checkedAt;

  double get fillFraction => level.clamp(0, 100) / 100;
}

class BatteryManagerController extends GetxController
    with WidgetsBindingObserver {
  static BatteryManagerController instance = Get.find();

  static const _channel = MethodChannel('sift/battery');
  static const _refreshInterval = Duration(seconds: 30);

  bool isLoading = true;
  String? errorMessage;
  BatterySnapshot battery = const BatterySnapshot.empty();
  Timer? _refreshTimer;
  bool _isReadingBattery = false;

  // Optimisation preferences. One is enabled by default so the summary reads
  // "1 of 4 optimisations on", matching the design's resting state.
  final Map<BatteryOptimisation, bool> _optimisations = {
    for (final option in BatteryOptimisation.values)
      option: option == BatteryOptimisation.location,
  };

  List<BatteryOptimisation> get optimisations => BatteryOptimisation.values;

  bool isOptimisationOn(BatteryOptimisation option) =>
      _optimisations[option] ?? false;

  int get activeOptimisationCount =>
      _optimisations.values.where((on) => on).length;

  int get estimatedSavingMinutes => BatteryOptimisation.values
      .where(isOptimisationOn)
      .fold(0, (sum, option) => sum + option.savingMinutes);

  int get maxSavingMinutes => BatteryOptimisation.values.fold(
    0,
    (sum, option) => sum + option.savingMinutes,
  );

  void toggleOptimisation(BatteryOptimisation option) {
    _optimisations[option] = !(_optimisations[option] ?? false);
    update();
  }

  void applyAllOptimisations() {
    for (final option in BatteryOptimisation.values) {
      _optimisations[option] = true;
    }
    update();
  }

  /// `45 min`, `1 hr`, or `2h 35m`.
  String formatSavingMinutes(int minutes) {
    if (minutes <= 0) {
      return '0 min';
    }
    if (minutes < 60) {
      return '$minutes min';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) {
      return '$hours hr';
    }
    return '${hours}h ${mins}m';
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    loadBattery();
    _refreshTimer = Timer.periodic(
      _refreshInterval,
      (_) => loadBattery(showLoading: false),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      loadBattery(showLoading: false);
    }
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  Future<void> loadBattery({bool showLoading = true}) async {
    if (_isReadingBattery) {
      return;
    }

    _isReadingBattery = true;
    if (showLoading) {
      isLoading = true;
    }
    errorMessage = null;
    update();

    try {
      try {
        final rawResult = await _channel.invokeMethod<dynamic>(
          'getBatteryStats',
        );
        final result = Map<dynamic, dynamic>.from(rawResult as Map);
        battery = BatterySnapshot(
          level: (result['level'] as num?)?.round() ?? 0,
          health: result['health'] as String? ?? 'Unknown',
          status: result['status'] as String? ?? 'Unknown',
          isCharging: result['isCharging'] == true,
          capacityPercent: (result['capacityPercent'] as num?)?.round(),
          designCapacityMah: (result['designCapacityMah'] as num?)?.toDouble(),
          estimatedCapacityMah: (result['estimatedCapacityMah'] as num?)
              ?.toDouble(),
          temperatureCelsius: (result['temperatureCelsius'] as num?)
              ?.toDouble(),
          voltage: (result['voltage'] as num?)?.round(),
          checkedAt: DateTime.now(),
        );
      } on MissingPluginException {
        errorMessage =
            'Battery reader is not installed in this build. Rebuild and reinstall the app.';
        battery = const BatterySnapshot.empty();
      } on PlatformException catch (error) {
        errorMessage =
            error.message ?? 'Could not read battery details from this device.';
        battery = const BatterySnapshot.empty();
      } catch (error) {
        errorMessage = 'Could not read battery details: $error';
        battery = const BatterySnapshot.empty();
      }
    } finally {
      isLoading = false;
      _isReadingBattery = false;
      update();
    }
  }

  String get lastCheckText {
    final checked = battery.checkedAt;
    if (checked == null) {
      return 'Not checked yet';
    }
    final hour = checked.hour == 0
        ? 12
        : checked.hour > 12
        ? checked.hour - 12
        : checked.hour;
    final minute = checked.minute.toString().padLeft(2, '0');
    final suffix = checked.hour >= 12 ? 'PM' : 'AM';
    return 'Today, $hour:$minute $suffix';
  }

  String get temperatureText {
    final temp = battery.temperatureCelsius;
    if (temp == null) {
      return 'Temp unavailable';
    }
    return '${temp.toStringAsFixed(1)}C';
  }

  String get capacityText {
    final design = battery.designCapacityMah;
    if (design != null && design > 0) {
      return '${design.round()} mAh';
    }
    final estimated = battery.estimatedCapacityMah;
    if (estimated != null && estimated > 0) {
      return '~${estimated.round()} mAh';
    }
    final percent = battery.capacityPercent ?? battery.level;
    return '$percent%';
  }
}
