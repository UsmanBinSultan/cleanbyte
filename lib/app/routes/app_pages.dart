import 'package:get/get.dart';
import 'package:sift/app/ai_categories/ai_categories_binding.dart';
import 'package:sift/app/ai_categories/ai_categories_view.dart';
import 'package:sift/app/apps_manager/apps_manager_binding.dart';
import 'package:sift/app/apps_manager/apps_manager_view.dart';
import 'package:sift/app/battery_manager/battery_manager_binding.dart';
import 'package:sift/app/battery_manager/battery_manager_view.dart';
import 'package:sift/app/categorical_photos/categorical_photos_binding.dart';
import 'package:sift/app/categorical_photos/categorical_photos_view.dart';
import 'package:sift/app/duplicate_contacts/duplicate_contacts_binding.dart';
import 'package:sift/app/duplicate_contacts/duplicate_contacts_view.dart';
import 'package:sift/app/home_dashboard/home_dashboard_binding.dart';
import 'package:sift/app/home_dashboard/home_dashboard_view.dart';
import 'package:sift/app/initial_scan/initial_scan_binding.dart';
import 'package:sift/app/initial_scan/initial_scan_view.dart';
import 'package:sift/app/large_files/large_files_binding.dart';
import 'package:sift/app/large_files/large_files_view.dart';
import 'package:sift/app/onboarding/onboarding_binding.dart';
import 'package:sift/app/onboarding/onboarding_view.dart';
import 'package:sift/app/paywall/paywall_binding.dart';
import 'package:sift/app/paywall/paywall_view.dart';
import 'package:sift/app/permission_rationale/permission_rationale_binding.dart';
import 'package:sift/app/permission_rationale/permission_rationale_view.dart';
import 'package:sift/app/photo_compressor/photo_compressor_binding.dart';
import 'package:sift/app/photo_compressor/photo_compressor_view.dart';
import 'package:sift/app/privacy_promise/privacy_promise_binding.dart';
import 'package:sift/app/privacy_promise/privacy_promise_view.dart';
import 'package:sift/app/problem_framing/problem_framing_binding.dart';
import 'package:sift/app/problem_framing/problem_framing_view.dart';
import 'package:sift/app/process_manager/process_manager_binding.dart';
import 'package:sift/app/process_manager/process_manager_view.dart';
import 'package:sift/app/routes/app_routes.dart';
import 'package:sift/app/similar_photos/similar_photos_binding.dart';
import 'package:sift/app/similar_photos/similar_photos_controller.dart';
import 'package:sift/app/similar_photos/similar_photos_view.dart';
import 'package:sift/app/splash/splash_binding.dart';
import 'package:sift/app/splash/splash_view.dart';
import 'package:sift/app/subscription/subscription_binding.dart';
import 'package:sift/app/subscription/subscription_view.dart';
import 'package:sift/app/swipe_cleaner/swipe_cleaner_binding.dart';
import 'package:sift/app/swipe_cleaner/swipe_cleaner_view.dart';
import 'package:sift/app/whatsapp_cleaner/whatsapp_cleaner_binding.dart';
import 'package:sift/app/whatsapp_cleaner/whatsapp_cleaner_view.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: AppRoutes.problemFraming,
      page: () => const ProblemFramingView(),
      binding: ProblemFramingBinding(),
    ),
    GetPage(
      name: AppRoutes.privacyPromise,
      page: () => const PrivacyPromiseView(),
      binding: PrivacyPromiseBinding(),
    ),
    GetPage(
      name: AppRoutes.permissionRationale,
      page: () => const PermissionRationaleView(),
      binding: PermissionRationaleBinding(),
    ),
    GetPage(
      name: AppRoutes.initialScan,
      page: () => const InitialScanView(),
      binding: InitialScanBinding(),
    ),
    GetPage(
      name: AppRoutes.paywall,
      page: () => const PaywallView(),
      binding: PaywallBinding(),
    ),
    GetPage(
      name: AppRoutes.homeDashboard,
      page: () => const HomeDashboardView(),
      binding: HomeDashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.similarPhotos,
      page: () => const SimilarPhotosView(mode: MediaCleanupMode.photos),
      binding: SimilarPhotosBinding(),
    ),
    GetPage(
      name: AppRoutes.largeVideos,
      page: () => const SimilarPhotosView(mode: MediaCleanupMode.videos),
      binding: SimilarPhotosBinding(),
    ),
    GetPage(
      name: AppRoutes.screenshots,
      page: () => const SimilarPhotosView(mode: MediaCleanupMode.screenshots),
      binding: SimilarPhotosBinding(),
    ),
    GetPage(
      name: AppRoutes.invisiblePhotos,
      page: () => const SimilarPhotosView(mode: MediaCleanupMode.invisible),
      binding: SimilarPhotosBinding(),
    ),
    GetPage(
      name: AppRoutes.duplicates,
      page: () => const SimilarPhotosView(mode: MediaCleanupMode.duplicates),
      binding: SimilarPhotosBinding(),
    ),
    GetPage(
      name: AppRoutes.blurredPhotos,
      page: () => const SimilarPhotosView(mode: MediaCleanupMode.blurred),
      binding: SimilarPhotosBinding(),
    ),
    GetPage(
      name: AppRoutes.largeFiles,
      page: () => const LargeFilesView(),
      binding: LargeFilesBinding(),
    ),
    GetPage(
      name: AppRoutes.duplicateContacts,
      page: () => const DuplicateContactsView(),
      binding: DuplicateContactsBinding(),
    ),
    GetPage(
      name: AppRoutes.swipeCleaner,
      page: () => const SwipeCleanerView(),
      binding: SwipeCleanerBinding(),
    ),
    GetPage(
      name: AppRoutes.aiCategories,
      page: () => const AiCategoriesView(),
      binding: AiCategoriesBinding(),
    ),
 
    GetPage(
      name: AppRoutes.processManager,
      page: () => const ProcessManagerView(),
      binding: ProcessManagerBinding(),
    ),
    GetPage(
      name: AppRoutes.whatsappCleaner,
      page: () => const WhatsappCleanerView(),
      binding: WhatsappCleanerBinding(),
    ),
    GetPage(
      name: AppRoutes.appsManager,
      page: () => const AppsManagerView(),
      binding: AppsManagerBinding(),
    ),
    GetPage(
      name: AppRoutes.photoCompressor,
      page: () => const PhotoCompressorView(),
      binding: PhotoCompressorBinding(),
    ),
    GetPage(
      name: AppRoutes.batteryManager,
      page: () => const BatteryManagerView(),
      binding: BatteryManagerBinding(),
    ),
    GetPage(
      name: AppRoutes.subscription,
      page: () => const SubscriptionView(),
      binding: SubscriptionBinding(),
    ),
  ];
}
