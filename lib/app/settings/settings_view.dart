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
        final light = Theme.of(context).brightness == Brightness.light;
        final pageBg = light
            ? const Color(0xFFF8F4EC)
            : const Color(0xFF071120);
        final titleColor = light ? const Color(0xFF111827) : Colors.white;
        final labelColor = light
            ? const Color(0xFF9AA1AD)
            : const Color(0xFF7C8594);
        final privacyText = light
            ? const Color(0xFF828A96)
            : const Color(0xFF8791A0);

        return ColoredBox(
          color: pageBg,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 34, 20, 104),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'settings'.tr,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 30,
                    height: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                const _CleanerFreeCard(),
                const SizedBox(height: 30),
                _SectionLabel(label: 'privacy'.tr, color: labelColor),
                const SizedBox(height: 8),
                _SettingsGroup(
                  children: [
                    _SettingsSwitchRow(
                      icon: LucideIcons.shieldCheck,
                      iconColor: const Color(0xFF18D0B8),
                      titleKey: 'on device only'.tr,
                      subtitleKey: 'on device body'.tr,
                      enabled: controller.onDeviceOnly,
                      onChanged: controller.toggleOnDeviceOnly,
                    ),
                    _SettingsActionRow(
                      icon: LucideIcons.image,
                      iconColor: const Color(0xFF18D0B8),
                      titleKey: 'photo library access',
                      valueKey: controller.isLoadingPhotoCollections
                          ? 'please wait'
                          : 'all photos',
                      onTap: () => _showPhotoCollections(controller),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'privacy note'.tr,
                  style: TextStyle(
                    color: privacyText,
                    fontSize: 11,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 30),
                _SectionLabel(label: 'storage section'.tr, color: labelColor),
                const SizedBox(height: 8),
                _SettingsGroup(
                  children: [
                    GetBuilder<RecycleBinService>(
                      builder: (bin) => _SettingsActionRow(
                        icon: LucideIcons.trash2,
                        iconColor: const Color(0xFFFF7A5F),
                        titleKey: 'recycle bin',
                        subtitleKey: 'recycle bin subtitle',
                        valueText: '${bin.count}',
                        onTap: () => Get.toNamed(AppRoutes.recycleBin),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                _SectionLabel(label: 'preferences'.tr, color: labelColor),
                const SizedBox(height: 8),
                _SettingsGroup(
                  children: [
                    _SettingsActionRow(
                      icon: LucideIcons.languages,
                      iconColor: const Color(0xFF18D0B8),
                      titleKey: 'language',
                      subtitleKey: 'change language',
                      valueText: controller.selectedLanguageLabel,
                      onTap: () => _showLanguagePicker(controller),
                    ),
                    _SettingsActionRow(
                      icon: LucideIcons.palette,
                      iconColor: const Color(0xFFFF9500),
                      titleKey: 'theme',
                      subtitleKey: 'change theme',
                      valueText: controller.selectedThemeLabel,
                      onTap: () => _showThemePicker(controller),
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
    // await Get.bottomSheet<void>(
    // _SettingsPickerSheet(
    //   title: 'photo collections'.tr,
    //   children: controller.photoCollections.isEmpty
    //       ? [
    //           Padding(
    //             padding: const EdgeInsets.all(18),
    //             child: Text('no photo collections'.tr),
    //           ),
    //         ]
    //       : [
    //           for (final collection in controller.photoCollections)
    //             _SettingsPickerTile(
    //               title: collection.name,
    //               subtitle: 'photos_count'.trParams({
    //                 'count': collection.count.toString(),
    //               }),
    //               selected: false,
    //               onTap: Get.back<void>,
    //             ),
    //         ],
    // ),
    // backgroundColor: Colors.transparent,
    // );
  }

  Future<void> _showLanguagePicker(SettingsController controller) async {
    await Get.bottomSheet<void>(
      _SettingsPickerSheet(
        title: 'choose_language'.tr,
        children: [
          for (final option in SettingsController.languages)
            _SettingsPickerTile(
              title: option.nameKey.tr,
              subtitle: option.nativeName,
              selected:
                  option.locale.languageCode ==
                      controller.currentLocale.languageCode &&
                  option.locale.countryCode ==
                      controller.currentLocale.countryCode,
              onTap: () async {
                Get.back<void>();
                await controller.changeLanguage(option);
              },
            ),
        ],
      ),
      backgroundColor: Colors.transparent,
    );
  }

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
}

class _CleanerFreeCard extends StatelessWidget {
  const _CleanerFreeCard();

  @override
  Widget build(BuildContext context) {
    final light = Theme.of(context).brightness == Brightness.light;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: light ? Colors.white : const Color(0xFF111929),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: light ? const Color(0xFFE6E8EF) : const Color(0xFF202B3F),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.splashGradient,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: SvgPicture.asset('assets/icons/sift_logo.svg'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'cleaner free'.tr,
                      style: TextStyle(
                        color: light ? const Color(0xFF242936) : Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'free deletions'.tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: light
                            ? const Color(0xFF9097A4)
                            : const Color(0xFF8B94A3),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: TextButton(
              onPressed: () => Get.toNamed(AppRoutes.paywall),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF18D0B8),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              child: Text('upgrade to pro'.tr),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w900),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final light = Theme.of(context).brightness == Brightness.light;
    return Container(
      decoration: BoxDecoration(
        color: light ? Colors.white : const Color(0xFF111929),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: light ? const Color(0xFFE2E5EC) : const Color(0xFF202B3F),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index != children.length - 1)
              Divider(
                height: 1,
                indent: 54,
                color: light
                    ? const Color(0xFFE5E7ED)
                    : const Color(0xFF1B2537),
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
    required this.titleKey,
    this.subtitleKey,
    this.valueKey,
    this.valueText,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String titleKey;
  final String? subtitleKey;
  final String? valueKey;
  final String? valueText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final light = Theme.of(context).brightness == Brightness.light;
    final titleColor = light ? const Color(0xFF2F3440) : Colors.white;
    final mutedColor = light
        ? const Color(0xFF9AA1AD)
        : const Color(0xFF8B94A3);
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            const SizedBox(width: 14),
            _SettingsIcon(icon: icon, color: iconColor),
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
                      color: titleColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (subtitleKey != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitleKey!.tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: mutedColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Text(
              valueText ?? valueKey?.tr ?? '',
              style: TextStyle(
                color: mutedColor,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? LucideIcons.chevronLeft
                  : LucideIcons.chevronRight,
              color: mutedColor,
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
    required this.titleKey,
    required this.subtitleKey,
    required this.enabled,
    required this.onChanged,
  });

  final IconData icon;
  final Color iconColor;
  final String titleKey;
  final String subtitleKey;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final light = Theme.of(context).brightness == Brightness.light;
    final titleColor = light ? const Color(0xFF2F3440) : Colors.white;
    final mutedColor = light
        ? const Color(0xFF9AA1AD)
        : const Color(0xFF8B94A3);
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          const SizedBox(width: 14),
          _SettingsIcon(icon: icon, color: iconColor),
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
                    color: titleColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitleKey.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: mutedColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: enabled,
            onChanged: onChanged,
            activeTrackColor: const Color(0xFF34C759),
            activeThumbColor: Colors.white,
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _SettingsIcon extends StatelessWidget {
  const _SettingsIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: Colors.white, size: 17),
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
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0x1F94A3B8)),
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
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
            Flexible(child: ListView(shrinkWrap: true, children: children)),
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
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: selected ? const Icon(Icons.check_circle) : null,
    );
  }
}
