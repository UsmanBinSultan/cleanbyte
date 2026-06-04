import 'package:get/get.dart';
import 'package:sift/app/permission_rationale/permission_rationale_controller.dart';

class PermissionRationaleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PermissionRationaleController());
  }
}
