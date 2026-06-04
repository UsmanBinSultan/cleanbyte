import 'package:get/get.dart';
import 'package:sift/app/large_files/large_files_controller.dart';

class LargeFilesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LargeFilesController());
  }
}
