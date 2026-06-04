import 'package:get/get.dart';
import 'package:sift/app/problem_framing/problem_framing_controller.dart';

class ProblemFramingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProblemFramingController());
  }
}
