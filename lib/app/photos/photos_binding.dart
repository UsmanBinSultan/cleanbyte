import 'package:get/get.dart';
import 'package:sift/app/photos/photos_controller.dart';

class SimilarPhotosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SimilarPhotosController());
  }
}
