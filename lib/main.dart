import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sift/app/routes/app_pages.dart';
import 'package:sift/app/routes/app_routes.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/settings/settings_binding.dart';
import 'package:sift/app/settings/settings_controller.dart';
import 'package:sift/app/translations/app_translations.dart';
import 'package:sift/services/recycle_bin_service.dart';

void main() {
  SettingsBinding().dependencies();
  // Loads the saved index and purges anything older than 30 days on startup.
  Get.put(RecycleBinService(), permanent: true);
  runApp(const CleanByteApp());
}

class CleanByteApp extends StatelessWidget {
  const CleanByteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'clean byte',
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      translations: AppTranslations(),
      locale: Get.find<SettingsController>().currentLocale,
      fallbackLocale: const Locale('en', 'US'),
      themeMode: Get.find<SettingsController>().themeMode,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.lightBg,
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accent,
          brightness: Brightness.light,
          surface: AppColors.lightSurface,
        ),
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: AppColors.lightFg,
          displayColor: AppColors.lightFg,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.bgDeep,
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accent,
          brightness: Brightness.dark,
          surface: AppColors.bg,
        ),
      ),
    );
  }
}
