import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sift/app/routes/app_pages.dart';
import 'package:sift/app/routes/app_routes.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/settings/settings_binding.dart';
import 'package:sift/app/settings/settings_controller.dart';
import 'package:sift/app/translations/app_translations.dart';

void main() {
  SettingsBinding().dependencies();
  runApp(const CleanByteApp());
}

class CleanByteApp extends StatelessWidget {
  const CleanByteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'app title'.tr,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      translations: AppTranslations(),
      locale: Get.find<SettingsController>().currentLocale,
      fallbackLocale: const Locale('en', 'US'),
      themeMode: Get.find<SettingsController>().themeMode,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFFBF5),
        fontFamily: 'SF Pro Text',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF14B8A6),
          brightness: Brightness.light,
          surface: const Color(0xFFFFFCF7),
        ),
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: const Color(0xFF17201B),
          displayColor: const Color(0xFF17201B),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.bgDeep,
        fontFamily: 'SF Pro Text',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accent,
          brightness: Brightness.dark,
          surface: AppColors.bg,
        ),
      ),
    );
  }
}
