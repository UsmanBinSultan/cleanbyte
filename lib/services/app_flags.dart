import 'dart:io';

import 'package:path_provider/path_provider.dart';

class AppFlags {
  const AppFlags._();

  static const _onboardingCompleteFile = 'onboarding_complete.flag';

  static Future<bool> hasSeenOnboarding() async {
    final file = await _file(_onboardingCompleteFile);
    return file.exists();
  }

  static Future<void> markOnboardingSeen() async {
    final file = await _file(_onboardingCompleteFile);
    await file.writeAsString(DateTime.now().toIso8601String());
  }

  static Future<File> _file(String name) async {
    final directory = await getApplicationSupportDirectory();
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return File('${directory.path}${Platform.pathSeparator}$name');
  }
}
