import 'package:get/get.dart';
import 'package:sift/app/ai_categories/ai_categories_controller.dart';

class AiCategoriesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AiCategoriesController());
  }
}
