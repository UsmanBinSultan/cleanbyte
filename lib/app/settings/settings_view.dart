import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/routes/app_routes.dart';
import 'package:sift/app/settings/settings_controller.dart';
import 'package:sift/app/settings/widgets/faq_sheet.dart';
import 'package:sift/app/settings/widgets/settings_action_row.dart';
import 'package:sift/app/settings/widgets/settings_group.dart';
import 'package:sift/app/settings/widgets/settings_picker_sheet.dart';
import 'package:sift/app/settings/widgets/settings_picker_tile.dart';
import 'package:sift/app/settings/widgets/settings_section_label.dart';
import 'package:sift/app/settings/widgets/settings_switch_row.dart';
import 'package:sift/services/recycle_bin_service.dart';

/// Settings tab: preference toggles, privacy, display and storage actions.
/// Rows, groups and picker sheets live under `widgets/`.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingsController>(
      builder: (controller) {
        return ColoredBox(
          color: AppColors.pageBackground(context),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 104),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings'.tr,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 28,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 15),
                SettingsSectionLabel(label: 'Preferences'),
                const SizedBox(height: 8),
                SettingsGroup(
                  children: [
                    SettingsSwitchRow(
                      icon: LucideIcons.sparkles,
                      iconColor: AppColors.iconPurple,
                      tint: AppColors.tintPurple,
                      titleKey: 'Smart suggestions',
                      subtitleKey: 'Surface cleanup tips on the home screen',
                      enabled: controller.smartSuggestions,
                      onChanged: controller.toggleSmartSuggestions,
                    ),
                    SettingsActionRow(
                      icon: LucideIcons.calendarClock,
                      iconColor: AppColors.iconAmber,
                      tint: AppColors.tintAmber,
                      titleKey: 'Scan frequency',
                      subtitleKey: 'How often to auto scan',
                      valueText: controller.scanFrequencyLabel,
                      onTap: () => _showScanFrequencyPicker(controller),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                SettingsSectionLabel(label: 'privacy'.tr),
                const SizedBox(height: 8),
                SettingsGroup(
                  children: [
                    SettingsSwitchRow(
                      icon: LucideIcons.shieldCheck,
                      iconColor: AppColors.accent,
                      tint: AppColors.tintTeal,
                      titleKey: 'on device only'.tr,
                      subtitleKey: 'on device body'.tr,
                      enabled: controller.onDeviceOnly,
                      onChanged: controller.toggleOnDeviceOnly,
                    ),
                    SettingsActionRow(
                      icon: LucideIcons.image,
                      iconColor: AppColors.accent,
                      tint: AppColors.tintTeal,
                      titleKey: 'photo library access',
                      valueKey: controller.isLoadingPhotoCollections
                          ? 'please wait'
                          : 'all photos',
                      onTap: () => _showPhotoCollections(controller),
                    ),
                    SettingsActionRow(
                      icon: LucideIcons.fileText,
                      iconColor: AppColors.iconBlue,
                      tint: AppColors.tintBlue,
                      titleKey: 'Privacy policy',
                      subtitleKey: 'How we handle your data',
                      onTap: _showPrivacyPolicy,
                    ),
                    SettingsActionRow(
                      icon: LucideIcons.helpCircle,
                      iconColor: AppColors.accent,
                      tint: AppColors.tintTeal,
                      titleKey: 'Help & FAQs',
                      subtitleKey: 'Answers to common questions',
                      onTap: () => _showFaqs(),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                SettingsSectionLabel(label: 'Display'),
                const SizedBox(height: 8),
                SettingsGroup(
                  children: [
                    SettingsActionRow(
                      icon: LucideIcons.palette,
                      iconColor: AppColors.iconAmber,
                      tint: AppColors.tintAmber,
                      titleKey: 'Theme',
                      subtitleKey: 'change theme',
                      valueText: controller.selectedThemeLabel,
                      onTap: () => _showThemePicker(controller),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                SettingsSectionLabel(label: 'storage section'.tr),
                const SizedBox(height: 8),
                SettingsGroup(
                  children: [
                    GetBuilder<RecycleBinService>(
                      builder: (bin) => SettingsActionRow(
                        icon: LucideIcons.trash2,
                        iconColor: AppColors.danger,
                        tint: AppColors.dangerBg,
                        titleKey: 'recycle bin',
                        subtitleKey: 'recycle bin subtitle',
                        titleColor: AppColors.danger,
                        valueText: '${bin.count}',
                        onTap: () => Get.toNamed(AppRoutes.recycleBin),
                      ),
                    ),
                    SettingsActionRow(
                      icon: LucideIcons.trash,
                      iconColor: AppColors.danger,
                      tint: AppColors.dangerBg,
                      titleKey: 'Clear scan data',
                      subtitleKey: 'Reset cached scan results (keeps photos)',
                      titleColor: AppColors.danger,
                      onTap: () => _confirmClearScanData(controller),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showPhotoCollections(SettingsController controller) async {
    await controller.openGallery();
    await controller.loadPhotoCollections();
  }

  Future<void> _showThemePicker(SettingsController controller) async {
    await Get.bottomSheet<void>(
      SettingsPickerSheet(
        title: 'choose_theme'.tr,
        children: [
          for (final preference in AppThemePreference.values)
            SettingsPickerTile(
              title: preference.labelKey.tr,
              selected: controller.themePreference == preference,
              onTap: () async {
                Get.back<void>();
                await controller.changeTheme(preference);
              },
            ),
        ],
      ),
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> _showFaqs() async {
    await Get.bottomSheet<void>(
      const FaqSheet(),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  Future<void> _showScanFrequencyPicker(SettingsController controller) async {
    await Get.bottomSheet<void>(
      SettingsPickerSheet(
        title: 'Scan frequency',
        children: [
          for (final freq in ScanFrequency.values)
            SettingsPickerTile(
              title: freq.label,
              selected: controller.scanFrequency == freq,
              onTap: () async {
                Get.back<void>();
                await controller.setScanFrequency(freq);
              },
            ),
        ],
      ),
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> _showPrivacyPolicy() async {
    await Get.dialog<void>(
      AlertDialog(
        title: const Text(
          'Privacy policy',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'Clean Byte runs entirely on your device. Your photos, videos, files '
          'and contacts are never uploaded to any server, and nothing is '
          'deleted without your explicit approval.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back<void>(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClearScanData(SettingsController controller) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text(
          'Clear scan data?',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'This resets cached scan results so the next scan runs fresh. '
          'Your photos and files are not touched.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    final cleared = await controller.clearScanData();
    Get.snackbar(
      'Scan data cleared',
      cleared > 0 ? 'Cached results were reset.' : 'Nothing cached to clear.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
