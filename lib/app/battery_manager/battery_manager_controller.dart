import 'package:flutter/services.dart';
import 'package:get/get.dart';

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

class BatteryManagerController extends GetxController {
  static BatteryManagerController instance = Get.find();

  static const _channel = MethodChannel('sift/battery');

  bool isLoading = true;
  String? errorMessage;
  BatterySnapshot battery = const BatterySnapshot.empty();

  @override
  void onInit() {
    super.onInit();
    loadBattery();
  }

  Future<void> loadBattery() async {
    isLoading = true;
    errorMessage = null;
    update();

    try {
      final rawResult = await _channel.invokeMethod<dynamic>('getBatteryStats');
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
        temperatureCelsius: (result['temperatureCelsius'] as num?)?.toDouble(),
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

    isLoading = false;
    update();
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
