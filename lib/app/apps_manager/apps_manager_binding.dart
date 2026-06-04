import 'package:get/get.dart';
import 'package:sift/app/apps_manager/apps_manager_controller.dart';

class AppsManagerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AppsManagerController());
  }
}
