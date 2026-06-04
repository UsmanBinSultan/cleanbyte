import 'package:get/get.dart';
import 'package:sift/app/process_manager/process_manager_controller.dart';

class ProcessManagerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProcessManagerController());
  }
}
