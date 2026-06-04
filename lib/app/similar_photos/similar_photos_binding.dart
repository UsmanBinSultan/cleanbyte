import 'package:get/get.dart';
import 'package:sift/app/similar_photos/similar_photos_controller.dart';

class SimilarPhotosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SimilarPhotosController());
  }
}
