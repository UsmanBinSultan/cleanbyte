import 'package:get/get.dart';
import 'package:sift/app/paywall/paywall_controller.dart';

class PaywallBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PaywallController());
  }
}
