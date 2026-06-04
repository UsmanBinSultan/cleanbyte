import 'package:get/get.dart';
import 'package:sift/app/privacy_promise/privacy_promise_controller.dart';

class PrivacyPromiseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PrivacyPromiseController());
  }
}
