import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/routes/app_routes.dart';
import 'package:sift/app/settings/settings_controller.dart';
import 'package:sift/services/recycle_bin_service.dart';

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
                  'settings'.tr,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 28,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                // const _CleanerFreeCard(),
                const SizedBox(height: 15),
                _SectionLabel(label: 'Preferences'),
                const SizedBox(height: 8),
                _SettingsGroup(
                  children: [
                    // _SettingsSwitchRow(
                    //   icon: LucideIcons.scanLine,
                    //   iconColor: AppColors.accent,
                    //   tint: AppColors.tintTeal,
                    //   titleKey: 'Auto scan',
                    //   subtitleKey: 'Scan automatically in the background',
                    //   enabled: controller.autoScan,
                    //   onChanged: controller.toggleAutoScan,
                    // ),
                    // _SettingsSwitchRow(
                    //   icon: LucideIcons.copy,
                    //   iconColor: AppColors.iconBlue,
                    //   tint: AppColors.tintBlue,
                    //   titleKey: 'Detect similar photos',
                    //   subtitleKey: 'Group near-identical shots while scanning',
                    //   enabled: controller.detectSimilarPhotos,
                    //   onChanged: controller.toggleDetectSimilarPhotos,
                    // ),
                    // _SettingsSwitchRow(
                    //   icon: LucideIcons.users,
                    //   iconColor: AppColors.iconPurple,
                    //   tint: AppColors.tintPurple,
                    //   titleKey: 'Merge contacts',
                    //   subtitleKey: 'Flag duplicate entries in Contacts',
                    //   enabled: controller.mergeContacts,
                    //   onChanged: controller.toggleMergeContacts,
                    // ),
                    _SettingsSwitchRow(
                      icon: LucideIcons.sparkles,
                      iconColor: AppColors.iconPurple,
                      tint: AppColors.tintPurple,
                      titleKey: 'Smart suggestions',
                      subtitleKey: 'Surface cleanup tips on the home screen',
                      enabled: controller.smartSuggestions,
                      onChanged: controller.toggleSmartSuggestions,
                    ),
                    _SettingsActionRow(
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
                _SectionLabel(label: 'privacy'.tr),
                const SizedBox(height: 8),
                _SettingsGroup(
                  children: [
                    _SettingsSwitchRow(
                      icon: LucideIcons.shieldCheck,
                      iconColor: AppColors.accent,
                      tint: AppColors.tintTeal,
                      titleKey: 'on device only'.tr,
                      subtitleKey: 'on device body'.tr,
                      enabled: controller.onDeviceOnly,
                      onChanged: controller.toggleOnDeviceOnly,
                    ),
                    _SettingsActionRow(
                      icon: LucideIcons.image,
                      iconColor: AppColors.accent,
                      tint: AppColors.tintTeal,
                      titleKey: 'photo library access',
                      valueKey: controller.isLoadingPhotoCollections
                          ? 'please wait'
                          : 'all photos',
                      onTap: () => _showPhotoCollections(controller),
                    ),
                    _SettingsActionRow(
                      icon: LucideIcons.fileText,
                      iconColor: AppColors.iconBlue,
                      tint: AppColors.tintBlue,
                      titleKey: 'Privacy policy',
                      subtitleKey: 'How we handle your data',
                      onTap: _showPrivacyPolicy,
                    ),
                    _SettingsActionRow(
                      icon: LucideIcons.helpCircle,
                      iconColor: AppColors.accent,
                      tint: AppColors.tintTeal,
                      titleKey: 'Help & FAQs',
                      subtitleKey: 'Answers to common questions',
                      onTap: () => _showFaqs(context),
                    ),
                  ],
                ),
                // const SizedBox(height: 10),
                // Text(
                //   'privacy note'.tr,
                //   style: TextStyle(
                //     color: AppColors.textMuted(context),
                //     fontSize: 11,
                //     height: 1.25,
                //     fontWeight: FontWeight.w500,
                //   ),
                // ),
                // const SizedBox(height: 28),
                // _SectionLabel(label: 'Security'),
                // const SizedBox(height: 8),
                // _SettingsGroup(
                //   children: [
                //     _SettingsSwitchRow(
                //       icon: LucideIcons.shieldCheck,
                //       iconColor: AppColors.accent,
                //       tint: AppColors.tintTeal,
                //       titleKey: 'Require approval',
                //       subtitleKey: 'Always confirm before any deletion',
                //       enabled: controller.requireApproval,
                //       onChanged: controller.toggleRequireApproval,
                //     ),
                //   ],
                // ),
                const SizedBox(height: 15),
                _SectionLabel(label: 'Display'),
                const SizedBox(height: 8),
                _SettingsGroup(
                  children: [
                    // _SettingsActionRow(
                    //   icon: LucideIcons.languages,
                    //   iconColor: AppColors.iconBlue,
                    //   tint: AppColors.tintBlue,
                    //   titleKey: 'language',
                    //   subtitleKey: 'change language',
                    //   valueText: controller.selectedLanguageLabel,
                    // onTap: () => _showLanguagePicker(controller),
                    // ),
                    _SettingsActionRow(
                      icon: LucideIcons.palette,
                      iconColor: AppColors.iconAmber,
                      tint: AppColors.tintAmber,
                      titleKey: 'theme',
                      subtitleKey: 'change theme',
                      valueText: controller.selectedThemeLabel,
                      onTap: () => _showThemePicker(controller),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                _SectionLabel(label: 'storage section'.tr),
                const SizedBox(height: 8),
                _SettingsGroup(
                  children: [
                    GetBuilder<RecycleBinService>(
                      builder: (bin) => _SettingsActionRow(
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
                    _SettingsActionRow(
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
                // const SizedBox(height: 28),
                // _SectionLabel(label: 'Support'),
                // const SizedBox(height: 8),
                _SettingsGroup(
                  children: [
                    // _SettingsActionRow(
                    //   icon: LucideIcons.helpCircle,
                    //   iconColor: AppColors.accent,
                    //   tint: AppColors.tintTeal,
                    //   titleKey: 'Help & FAQs',
                    //   subtitleKey: 'Answers to common questions',
                    //   onTap: () => _showFaqs(context),
                    // ),
                    // _SettingsActionRow(
                    //   icon: LucideIcons.mail,
                    //   iconColor: AppColors.iconBlue,
                    //   tint: AppColors.tintBlue,
                    //   titleKey: 'Contact support',
                    //   subtitleKey: 'We usually reply within a day',
                    //   onTap: _contactSupport,
                    // ),
                    // _SettingsActionRow(
                    //   icon: LucideIcons.info,
                    //   iconColor: AppColors.textMuted(context),
                    //   tint: AppColors.surfaceTint(context),
                    //   titleKey: 'App version',
                    //   valueText: '1.0.0',
                    // ),
                  ],
                ),
                // const SizedBox(height: 28),
                // _SectionLabel(label: 'Danger Zone'),
                // const SizedBox(height: 8),
                // _SettingsGroup(
                //   children: [
                //     _SettingsActionRow(
                //       icon: LucideIcons.trash,
                //       iconColor: AppColors.danger,
                //       tint: AppColors.dangerBg,
                //       titleKey: 'Clear scan data',
                //       subtitleKey: 'Reset cached scan results (keeps photos)',
                //       titleColor: AppColors.danger,
                //       onTap: () => _confirmClearScanData(controller),
                //     ),
                //   ],
                // ),
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

  // Future<void> _showLanguagePicker(SettingsController controller) async {
  //   await Get.bottomSheet<void>(
  //     _SettingsPickerSheet(
  //       title: 'choose_language'.tr,
  //       children: [
  //         for (final option in SettingsController.languages)
  //           _SettingsPickerTile(
  //             title: option.nameKey.tr,
  //             subtitle: option.nativeName,
  //             selected:
  //                 option.locale.languageCode ==
  //                     controller.currentLocale.languageCode &&
  //                 option.locale.countryCode ==
  //                     controller.currentLocale.countryCode,
  //             onTap: () async {
  //               Get.back<void>();
  //               await controller.changeLanguage(option);
  //             },
  //           ),
  //       ],
  //     ),
  //     backgroundColor: Colors.transparent,
  //   );
  // }

  Future<void> _showThemePicker(SettingsController controller) async {
    await Get.bottomSheet<void>(
      _SettingsPickerSheet(
        title: 'choose_theme'.tr,
        children: [
          for (final preference in AppThemePreference.values)
            _SettingsPickerTile(
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

  Future<void> _showFaqs(BuildContext context) async {
    await Get.bottomSheet<void>(
      const _FaqSheet(),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  void _contactSupport() {
    Get.snackbar(
      'Contact support',
      'Email us at support@cleanbyte.app — we usually reply within a day.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> _showScanFrequencyPicker(SettingsController controller) async {
    await Get.bottomSheet<void>(
      _SettingsPickerSheet(
        title: 'Scan frequency',
        children: [
          for (final freq in ScanFrequency.values)
            _SettingsPickerTile(
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

// class _CleanerFreeCard extends StatelessWidget {
//   const _CleanerFreeCard();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
//       decoration: BoxDecoration(
//         color: AppColors.surface(context),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: AppColors.borderFor(context)),
//         boxShadow: AppColors.isLight(context)
//             ? [
//                 BoxShadow(
//                   color: Colors.black.withValues(alpha: 0.04),
//                   blurRadius: 12,
//                   offset: const Offset(0, 4),
//                 ),
//               ]
//             : null,
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 48,
//                 height: 48,
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   gradient: AppColors.accentGradient,
//                   borderRadius: BorderRadius.circular(14),
//                 ),
//                 child: SvgPicture.asset('assets/icons/sift_logo.svg'),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'cleaner free'.tr,
//                       style: TextStyle(
//                         color: AppColors.textPrimary(context),
//                         fontSize: 15,
//                         fontWeight: FontWeight.w800,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       'free deletions'.tr,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                         color: AppColors.textMuted(context),
//                         fontSize: 11,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           DecoratedBox(
//             decoration: BoxDecoration(
//               gradient: AppColors.accentGradient,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: SizedBox(
//               width: double.infinity,
//               height: 44,
//               child: TextButton(
//                 onPressed: () => Get.toNamed(AppRoutes.paywall),
//                 style: TextButton.styleFrom(
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   textStyle: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//                 child: Text('upgrade to pro'.tr),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: AppColors.textFaint(context),
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index != children.length - 1)
              Divider(
                height: 1,
                indent: 60,
                color: AppColors.borderFor(context),
              ),
          ],
        ],
      ),
    );
  }
}

class _SettingsActionRow extends StatelessWidget {
  const _SettingsActionRow({
    required this.icon,
    required this.iconColor,
    required this.tint,
    required this.titleKey,
    this.subtitleKey,
    this.valueKey,
    this.valueText,
    this.onTap,
    this.titleColor,
  });

  final IconData icon;
  final Color iconColor;
  final Color tint;
  final String titleKey;
  final String? subtitleKey;
  final String? valueKey;
  final String? valueText;
  final VoidCallback? onTap;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 60,
        child: Row(
          children: [
            const SizedBox(width: 14),
            _SettingsIcon(icon: icon, color: iconColor, tint: tint),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titleKey.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: titleColor ?? AppColors.textPrimary(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitleKey != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitleKey!.tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textMuted(context),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Text(
              valueText ?? valueKey?.tr ?? '',
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? LucideIcons.chevronLeft
                  : LucideIcons.chevronRight,
              color: AppColors.textFaint(context),
              size: 16,
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}

class _SettingsSwitchRow extends StatelessWidget {
  const _SettingsSwitchRow({
    required this.icon,
    required this.iconColor,
    required this.tint,
    required this.titleKey,
    required this.subtitleKey,
    required this.enabled,
    required this.onChanged,
  });

  final IconData icon;
  final Color iconColor;
  final Color tint;
  final String titleKey;
  final String subtitleKey;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Row(
        children: [
          const SizedBox(width: 14),
          _SettingsIcon(icon: icon, color: iconColor, tint: tint),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titleKey.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitleKey.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textMuted(context),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: enabled,
            onChanged: onChanged,
            activeTrackColor: AppColors.accent,
            activeThumbColor: Colors.white,
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _SettingsIcon extends StatelessWidget {
  const _SettingsIcon({
    required this.icon,
    required this.color,
    required this.tint,
  });

  final IconData icon;
  final Color color;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: AppColors.iconChipBg(context, color, tint),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 17),
    );
  }
}

class _SettingsPickerSheet extends StatelessWidget {
  const _SettingsPickerSheet({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(14),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.borderFor(context)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 2, 4, 10),
              child: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            Flexible(child: ListView(shrinkWrap: true, children: children)),
          ],
        ),
      ),
    );
  }
}

class _FaqSheet extends StatelessWidget {
  const _FaqSheet();

  static const _faqs = [
    (
      'Are my photos uploaded anywhere?',
      'No. All scanning happens on your device — nothing is ever uploaded to a server.',
    ),
    (
      'Where do deleted items go?',
      'To the Recycle Bin for 30 days, so you can restore anything you change your mind about.',
    ),
    (
      'Will cleaning delete my originals?',
      'Only the copies you confirm. For similar photos, the best of each group is always kept.',
    ),
    (
      'How does Smart Scan work?',
      'It groups similar photos, screenshots and large files locally so you can review and free space safely.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(14),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.borderFor(context)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Help & FAQs',
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _faqs.length,
                separatorBuilder: (_, _) =>
                    Divider(height: 22, color: AppColors.borderFor(context)),
                itemBuilder: (context, index) {
                  final faq = _faqs[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        faq.$1,
                        style: TextStyle(
                          color: AppColors.textPrimary(context),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        faq.$2,
                        style: TextStyle(
                          color: AppColors.textMuted(context),
                          fontSize: 13,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: Get.back,
                child: Text(
                  'Close',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsPickerTile extends StatelessWidget {
  const _SettingsPickerTile({
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: selected
          ? const Icon(Icons.check_circle, color: AppColors.accent)
          : null,
    );
  }
}
