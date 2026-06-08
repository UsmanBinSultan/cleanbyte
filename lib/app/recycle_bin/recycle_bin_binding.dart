import 'package:get/get.dart';
import 'package:sift/app/recycle_bin/recycle_bin_controller.dart';

class RecycleBinBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RecycleBinController>(RecycleBinController.new);
  }
}
