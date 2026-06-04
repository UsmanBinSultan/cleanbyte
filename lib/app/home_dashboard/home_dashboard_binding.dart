import 'package:get/get.dart';
import 'package:sift/app/home_dashboard/home_dashboard_controller.dart';

class HomeDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeDashboardController());
  }
}
