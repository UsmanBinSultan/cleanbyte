import 'package:get/get.dart';
import 'package:sift/app/battery_manager/battery_manager_controller.dart';

class BatteryManagerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BatteryManagerController());
  }
}
