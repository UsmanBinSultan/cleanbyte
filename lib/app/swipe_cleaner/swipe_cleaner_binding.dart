import 'package:get/get.dart';
import 'package:sift/app/swipe_cleaner/swipe_cleaner_controller.dart';

class SwipeCleanerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SwipeCleanerController());
  }
}
