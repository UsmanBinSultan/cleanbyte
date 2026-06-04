import 'package:get/get.dart';
import 'package:sift/app/routes/app_routes.dart';
import 'package:sift/services/app_flags.dart';

class SplashController extends GetxController {
  static SplashController instance = Get.find();

  @override
  void onReady() {
    super.onReady();
    Future.delayed(const Duration(seconds: 3), () async {
      if (Get.currentRoute == AppRoutes.splash) {
        final hasSeenOnboarding = await AppFlags.hasSeenOnboarding();
        Get.offNamed(
          hasSeenOnboarding ? AppRoutes.homeDashboard : AppRoutes.onboarding,
        );
      }
    });
  }
}
