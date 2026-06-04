import 'package:get/get.dart';
import 'package:sift/app/photo_compressor/photo_compressor_controller.dart';

class PhotoCompressorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PhotoCompressorController());
  }
}
