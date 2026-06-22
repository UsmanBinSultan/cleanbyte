import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as contacts;
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sift/app/routes/app_routes.dart';
import 'package:sift/services/app_flags.dart';

/// Drives the redesigned 4-page onboarding flow:
/// 0 = "We only look, never delete" · 1 = "Find what's taking up space" ·
/// 2 = "Your photos stay private" · 3 = "One last step" (permissions).
class OnboardingController extends GetxController {
  static OnboardingController get instance => Get.find();

  static const int pageCount = 4;

  final PageController pageController = PageController();
  int currentPage = 0;

  bool photosGranted = false;
  bool filesGranted = false;
  bool contactsGranted = false;
  bool requestingPhotos = false;
  bool requestingFiles = false;
  bool requestingContacts = false;

  void onPageChanged(int index) {
    currentPage = index;
    update();
  }

  void next() {
    if (currentPage < pageCount - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      finish();
    }
  }

  Future<void> requestPhotos() async {
    if (requestingPhotos || photosGranted) {
      return;
    }
    requestingPhotos = true;
    update();
    try {
      final result = await PhotoManager.requestPermissionExtend(
        requestOption: const PermissionRequestOption(
          androidPermission: AndroidPermission(
            type: RequestType.common,
            mediaLocation: false,
          ),
        ),
      );
      photosGranted = result.hasAccess;
    } catch (_) {
      photosGranted = false;
    }
    requestingPhotos = false;
    update();
  }

  Future<void> requestFiles() async {
    if (requestingFiles || filesGranted) {
      return;
    }
    requestingFiles = true;
    update();
    try {
      if (await Permission.manageExternalStorage.isGranted) {
        filesGranted = true;
      } else {
        final manage = await Permission.manageExternalStorage.request();
        if (manage.isGranted) {
          filesGranted = true;
        } else {
          final storage = await Permission.storage.request();
          filesGranted = storage.isGranted || storage.isLimited;
        }
      }
    } catch (_) {
      filesGranted = false;
    }
    requestingFiles = false;
    update();
  }

  Future<void> requestContacts() async {
    if (requestingContacts || contactsGranted) {
      return;
    }
    requestingContacts = true;
    update();
    try {
      final status = await contacts.FlutterContacts.permissions.request(
        contacts.PermissionType.read,
      );
      contactsGranted =
          status == contacts.PermissionStatus.granted ||
          status == contacts.PermissionStatus.limited;
    } catch (_) {
      contactsGranted = false;
    }
    requestingContacts = false;
    update();
  }

  Future<void> skip() => finish();

  /// Opens the system app-settings page so the user can change a permission
  /// they have already granted (the OS does not let an app revoke it directly).
  Future<void> openSystemSettings() => openAppSettings();

  /// Photos access is required to scan. Without it the app must not proceed to
  /// show data, so we request it here and only continue once it is granted.
  /// Users who want in without granting can use the "Demo Mode" link ([skip]).
  Future<void> startFirstScan() async {
    if (!photosGranted) {
      await requestPhotos();
    }
    if (photosGranted) {
      await finish();
    } else {
      Get.snackbar(
        'Photos access needed',
        'Allow Photos access to start your first scan, or try Demo Mode.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> finish() async {
    await AppFlags.markOnboardingSeen();
    Get.offAllNamed(AppRoutes.homeDashboard);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
