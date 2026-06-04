import 'package:get/get.dart';
import 'package:sift/app/initial_scan/initial_scan_controller.dart';

class InitialScanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => InitialScanController());
  }
}
