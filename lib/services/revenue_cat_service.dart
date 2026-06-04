import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService {
  RevenueCatService._();

  static final RevenueCatService instance = RevenueCatService._();

  static const androidApiKey = String.fromEnvironment(
    'test_moMjQoxLEFbDZTGZJqrdrsUnWQN',
  );
  static const iosApiKey = String.fromEnvironment('REVENUECAT_IOS_API_KEY');
  static const entitlementId = String.fromEnvironment(
    'REVENUECAT_ENTITLEMENT_ID',
    defaultValue: 'pro',
  );

  bool _configured = false;
  Package? _cachedPackage;

  Future<void> configure() async {
    if (_configured) {
      return;
    }

    final apiKey = _apiKeyForPlatform;
    if (apiKey.isEmpty) {
      throw const RevenueCatNotConfiguredException();
    }

    await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.warn);
    await Purchases.configure(PurchasesConfiguration(apiKey));
    _configured = true;
  }

  Future<Package> loadCleanerProPackage() async {
    await configure();

    final cached = _cachedPackage;
    if (cached != null) {
      return cached;
    }

    final offerings = await Purchases.getOfferings();
    final current = offerings.current;
    final package =
        current?.annual ??
        current?.monthly ??
        current?.weekly ??
        (current?.availablePackages.isNotEmpty == true
            ? current!.availablePackages.first
            : null);

    if (package == null) {
      throw const RevenueCatNoPackageException();
    }

    _cachedPackage = package;
    return package;
  }

  Future<CustomerInfo> purchaseCleanerPro() async {
    final package = await loadCleanerProPackage();
    final result = await Purchases.purchase(PurchaseParams.package(package));
    return result.customerInfo;
  }

  Future<CustomerInfo> restorePurchases() async {
    await configure();
    return Purchases.restorePurchases();
  }

  Future<CustomerInfo> customerInfo() async {
    await configure();
    return Purchases.getCustomerInfo();
  }

  bool hasCleanerPro(CustomerInfo customerInfo) {
    if (customerInfo.entitlements.active.containsKey(entitlementId)) {
      return true;
    }
    return customerInfo.entitlements.active.isNotEmpty ||
        customerInfo.activeSubscriptions.isNotEmpty;
  }

  String get _apiKeyForPlatform {
    if (Platform.isAndroid) {
      return androidApiKey;
    }
    if (Platform.isIOS || Platform.isMacOS) {
      return iosApiKey;
    }
    return '';
  }
}

class RevenueCatNotConfiguredException implements Exception {
  const RevenueCatNotConfiguredException();

  @override
  String toString() {
    return 'RevenueCat is not configured. Run with --dart-define=REVENUECAT_ANDROID_API_KEY=goog_...';
  }
}

class RevenueCatNoPackageException implements Exception {
  const RevenueCatNoPackageException();

  @override
  String toString() {
    return 'No RevenueCat packages were found. Add a current offering with a package in the RevenueCat dashboard.';
  }
}
