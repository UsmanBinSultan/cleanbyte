import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sift/services/revenue_cat_service.dart';

class PaywallController extends GetxController {
  static PaywallController get instance => Get.find();

  bool isLoading = true;
  bool isPurchasing = false;
  bool isSubscribed = false;
  String? statusMessage;
  String price = '\$34.99';
  String cadence = '/ year';
  String weeklyPrice = '\$0.67';

  @override
  void onInit() {
    super.onInit();
    loadRevenueCatState();
  }

  String get manageSubtitle {
    if (isPurchasing) {
      return 'Opening RevenueCat checkout...';
    }
    if (isSubscribed) {
      return 'Clean Byte Pro is active';
    }
    return statusMessage ?? 'Starts RevenueCat test purchase';
  }

  Future<void> loadRevenueCatState() async {
    isLoading = true;
    update();

    try {
      final package = await RevenueCatService.instance.loadCleanerProPackage();
      _applyPackage(package);
      final customerInfo = await RevenueCatService.instance.customerInfo();
      isSubscribed = RevenueCatService.instance.hasCleanerPro(customerInfo);
      statusMessage = null;
    } catch (error) {
      statusMessage = _friendlyError(error);
    }

    isLoading = false;
    update();
  }

  Future<void> purchaseCleanerPro() async {
    if (isPurchasing) {
      return;
    }

    isPurchasing = true;
    statusMessage = null;
    update();

    try {
      final customerInfo = await RevenueCatService.instance
          .purchaseCleanerPro();
      isSubscribed = RevenueCatService.instance.hasCleanerPro(customerInfo);
      Get.snackbar(
        isSubscribed ? 'Subscription active' : 'Purchase complete',
        isSubscribed
            ? 'Clean Byte Pro is active in RevenueCat.'
            : 'RevenueCat completed the purchase, but no active entitlement was returned yet.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on PlatformException catch (error) {
      final code = PurchasesErrorHelper.getErrorCode(error);
      if (code != PurchasesErrorCode.purchaseCancelledError) {
        statusMessage = _friendlyError(error);
        Get.snackbar(
          'Subscription unavailable',
          statusMessage!,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (error) {
      statusMessage = _friendlyError(error);
      Get.snackbar(
        'Subscription unavailable',
        statusMessage!,
        snackPosition: SnackPosition.BOTTOM,
      );
    }

    isPurchasing = false;
    update();
  }

  Future<void> restoreCleanerPro() async {
    try {
      final customerInfo = await RevenueCatService.instance.restorePurchases();
      isSubscribed = RevenueCatService.instance.hasCleanerPro(customerInfo);
      update();
      Get.snackbar(
        isSubscribed ? 'Subscription restored' : 'Nothing restored',
        isSubscribed
            ? 'Clean Byte Pro is active.'
            : 'No active RevenueCat subscription was found.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      Get.snackbar(
        'Restore failed',
        _friendlyError(error),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _applyPackage(Package package) {
    final product = package.storeProduct;
    price = product.priceString;
    cadence = _cadenceForPeriod(product.subscriptionPeriod);
    weeklyPrice = product.pricePerWeekString ?? weeklyPrice;
  }

  String _cadenceForPeriod(String? period) {
    return switch (period) {
      'P1W' => '/ week',
      'P1M' => '/ month',
      'P1Y' => '/ year',
      _ => '/ year',
    };
  }

  String _friendlyError(Object error) {
    if (error is RevenueCatNotConfiguredException) {
      return 'Add your RevenueCat Android API key with --dart-define=REVENUECAT_ANDROID_API_KEY=goog_...';
    }
    if (error is RevenueCatNoPackageException) {
      return 'No current RevenueCat offering/package was found.';
    }
    if (error is PlatformException) {
      return error.message ?? error.code;
    }
    return error.toString();
  }
}
