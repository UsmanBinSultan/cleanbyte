import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';

enum AppThemePreference {
  dark,
  light,
  system;

  String get labelKey {
    switch (this) {
      case AppThemePreference.dark:
        return 'dark';
      case AppThemePreference.light:
        return 'light';
      case AppThemePreference.system:
        return 'system';
    }
  }
}

class LanguageOption {
  const LanguageOption({
    required this.nameKey,
    required this.locale,
    required this.nativeName,
  });

  final String nameKey;
  final Locale locale;
  final String nativeName;
}

class PhotoCollectionInfo {
  const PhotoCollectionInfo({required this.name, required this.count});

  final String name;
  final int count;
}

class SettingsController extends GetxController {
  static const _settingsFileName = 'app_settings.json';
  static const _photosChannel = MethodChannel('sift/photos');

  static const languages = [
    LanguageOption(
      nameKey: 'english',
      locale: Locale('en', 'US'),
      nativeName: 'English',
    ),
    LanguageOption(
      nameKey: 'arabic',
      locale: Locale('ar', 'SA'),
      nativeName: 'العربية',
    ),
    // LanguageOption(
    //   nameKey: 'spanish',
    //   locale: Locale('es', 'ES'),
    //   nativeName: 'Español',
    // ),
    // LanguageOption(
    //   nameKey: 'french',
    //   locale: Locale('fr', 'FR'),
    //   nativeName: 'Français',
    // ),
    // LanguageOption(
    //   nameKey: 'german',
    //   locale: Locale('de', 'DE'),
    //   nativeName: 'Deutsch',
    // ),
    // LanguageOption(
    //   nameKey: 'urdu',
    //   locale: Locale('ur', 'PK'),
    //   nativeName: 'اردو',
    // ),
    // LanguageOption(
    //   nameKey: 'hindi',
    //   locale: Locale('hi', 'IN'),
    //   nativeName: 'हिन्दी',
    // ),
    // LanguageOption(
    //   nameKey: 'portuguese',
    //   locale: Locale('pt', 'PT'),
    //   nativeName: 'Português',
    // ),
    // LanguageOption(
    //   nameKey: 'italian',
    //   locale: Locale('it', 'IT'),
    //   nativeName: 'Italiano',
    // ),
    // LanguageOption(
    //   nameKey: 'turkish',
    //   locale: Locale('tr', 'TR'),
    //   nativeName: 'Türkçe',
    // ),
  ];

  AppThemePreference themePreference = AppThemePreference.dark;
  Locale currentLocale = const Locale('en', 'US');
  bool onDeviceOnly = true;
  bool isLoadingPhotoCollections = false;
  List<PhotoCollectionInfo> photoCollections = <PhotoCollectionInfo>[];

  @override
  void onInit() {
    super.onInit();
    _restoreSettings();
  }

  ThemeMode get themeMode {
    switch (themePreference) {
      case AppThemePreference.dark:
        return ThemeMode.dark;
      case AppThemePreference.light:
        return ThemeMode.light;
      case AppThemePreference.system:
        return ThemeMode.dark;
    }
  }

  LanguageOption get selectedLanguage {
    return languages.firstWhere(
      (language) => _sameLocale(language.locale, currentLocale),
      orElse: () => languages.first,
    );
  }

  String get selectedLanguageLabel => selectedLanguage.nativeName;

  String get selectedThemeLabel => themePreference.labelKey.tr;

  Future<void> changeLanguage(LanguageOption option) async {
    currentLocale = option.locale;
    Get.updateLocale(option.locale);
    update();
    await _saveSettings();
  }

  Future<void> changeTheme(AppThemePreference preference) async {
    themePreference = preference;
    Get.changeThemeMode(themeMode);
    update();
    await _saveSettings();
  }

  Future<void> toggleOnDeviceOnly(bool value) async {
    onDeviceOnly = value;
    update();
    await _saveSettings();
  }

  Future<void> openGallery() async {
    try {
      await _photosChannel.invokeMethod<bool>('openGallery');
    } catch (_) {}
  }

  Future<void> loadPhotoCollections() async {
    isLoadingPhotoCollections = true;
    update();

    final permission = await PhotoManager.requestPermissionExtend(
      requestOption: const PermissionRequestOption(
        androidPermission: AndroidPermission(
          type: RequestType.common,
          mediaLocation: false,
        ),
      ),
    );
    if (!permission.hasAccess) {
      photoCollections = <PhotoCollectionInfo>[];
      isLoadingPhotoCollections = false;
      update();
      await PhotoManager.openSetting();
      return;
    }

    final paths = await PhotoManager.getAssetPathList(
      type: RequestType.common,
      onlyAll: false,
      filterOption: FilterOptionGroup(
        orders: const [OrderOption(type: OrderOptionType.createDate)],
      ),
    );
    final collections = <PhotoCollectionInfo>[];
    for (final path in paths) {
      final count = await path.assetCountAsync;
      if (count <= 0) {
        continue;
      }
      collections.add(PhotoCollectionInfo(name: path.name, count: count));
    }
    photoCollections = collections;
    isLoadingPhotoCollections = false;
    update();
  }

  Future<void> _restoreSettings() async {
    try {
      final file = await _settingsFile();
      if (!await file.exists()) {
        Get.changeThemeMode(themeMode);
        Get.updateLocale(currentLocale);
        return;
      }

      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map<String, dynamic>) {
        return;
      }

      final themeName = decoded['theme'] as String?;
      themePreference = AppThemePreference.values.firstWhere(
        (theme) => theme.name == themeName,
        orElse: () => AppThemePreference.dark,
      );

      final languageCode = decoded['languageCode'] as String?;
      final countryCode = decoded['countryCode'] as String?;
      if (languageCode != null && languageCode.isNotEmpty) {
        currentLocale = Locale(languageCode, countryCode);
      }
      onDeviceOnly = decoded['onDeviceOnly'] != false;

      Get.changeThemeMode(themeMode);
      Get.updateLocale(currentLocale);
      update();
    } catch (_) {
      Get.changeThemeMode(themeMode);
      Get.updateLocale(currentLocale);
    }
  }

  Future<void> _saveSettings() async {
    try {
      final file = await _settingsFile();
      await file.writeAsString(
        jsonEncode({
          'theme': themePreference.name,
          'languageCode': currentLocale.languageCode,
          'countryCode': currentLocale.countryCode,
          'onDeviceOnly': onDeviceOnly,
        }),
        flush: true,
      );
    } catch (_) {
      // Runtime changes are already applied; persistence can retry next change.
    }
  }

  Future<File> _settingsFile() async {
    final directory = await getApplicationSupportDirectory();
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return File('${directory.path}${Platform.pathSeparator}$_settingsFileName');
  }

  bool _sameLocale(Locale a, Locale b) {
    return a.languageCode == b.languageCode && a.countryCode == b.countryCode;
  }
}
