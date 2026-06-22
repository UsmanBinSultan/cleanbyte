import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

enum AppSortMode {
  size,
  lastUsed,
  name;

  String get label {
    switch (this) {
      case AppSortMode.size:
        return 'By size';
      case AppSortMode.lastUsed:
        return 'By last used';
      case AppSortMode.name:
        return 'By name';
    }
  }
}

class ManagedApp {
  const ManagedApp({
    required this.name,
    required this.packageName,
    required this.sizeBytes,
    required this.lastUsed,
    required this.hasUsageAccess,
    this.iconBytes,
  });

  factory ManagedApp.fromMap(Map<dynamic, dynamic> map) {
    final lastUsedMillis = (map['lastUsedMillis'] as num?)?.toInt() ?? 0;
    return ManagedApp(
      name: (map['name'] as String?)?.trim().isNotEmpty == true
          ? map['name'] as String
          : map['packageName'] as String? ?? 'Unknown app',
      packageName: map['packageName'] as String? ?? '',
      sizeBytes: (map['sizeBytes'] as num?)?.toInt() ?? 0,
      lastUsed: lastUsedMillis > 0
          ? DateTime.fromMillisecondsSinceEpoch(lastUsedMillis)
          : null,
      hasUsageAccess: map['hasUsageAccess'] == true,
      iconBytes: map['iconBytes'] as Uint8List?,
    );
  }

  final String name;
  final String packageName;
  final int sizeBytes;
  final DateTime? lastUsed;
  final bool hasUsageAccess;
  final Uint8List? iconBytes;

  String get letter => name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
}

class AppsManagerController extends GetxController with WidgetsBindingObserver {
  static AppsManagerController get instance => Get.find();

  static const _channel = MethodChannel('sift/apps');

  bool isLoading = true;
  String? errorMessage;
  AppSortMode sortMode = AppSortMode.size;
  List<ManagedApp> apps = <ManagedApp>[];

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    loadApps();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      loadApps();
    }
  }

  List<ManagedApp> get sortedApps {
    final sorted = [...apps];
    switch (sortMode) {
      case AppSortMode.size:
        sorted.sort((a, b) {
          final sizeCompare = b.sizeBytes.compareTo(a.sizeBytes);
          return sizeCompare != 0
              ? sizeCompare
              : a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
      case AppSortMode.lastUsed:
        sorted.sort((a, b) {
          final aTime = a.lastUsed?.millisecondsSinceEpoch ?? 0;
          final bTime = b.lastUsed?.millisecondsSinceEpoch ?? 0;
          final usageCompare = bTime.compareTo(aTime);
          return usageCompare != 0
              ? usageCompare
              : a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
      case AppSortMode.name:
        sorted.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
    }
    return sorted;
  }

  int get totalBytes => apps.fold(0, (total, app) => total + app.sizeBytes);

  bool get hasUsageAccess =>
      apps.isEmpty || apps.any((app) => app.hasUsageAccess);

  Future<void> loadApps() async {
    isLoading = true;
    errorMessage = null;
    update();

    try {
      final result = await _channel.invokeMethod<List<dynamic>>(
        'getInstalledApps',
      );
      apps = (result ?? <dynamic>[])
          .whereType<Map<dynamic, dynamic>>()
          .map(ManagedApp.fromMap)
          .where((app) => app.packageName.isNotEmpty)
          .toList();
    } on PlatformException catch (error) {
      errorMessage = error.message ?? 'Could not load installed apps.';
      apps = <ManagedApp>[];
    } catch (_) {
      errorMessage = 'Could not load installed apps.';
      apps = <ManagedApp>[];
    }

    isLoading = false;
    update();
  }

  void setSortMode(AppSortMode mode) {
    if (sortMode == mode) {
      return;
    }
    sortMode = mode;
    update();
  }

  Future<void> openUsageAccessSettings() {
    return _channel.invokeMethod<void>('openUsageAccessSettings');
  }
}
