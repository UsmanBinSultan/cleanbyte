import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/sift_top_app_bar.dart';
import 'package:sift/app/components/loading_shimmer.dart';
import 'package:sift/app/duplicate_contacts/duplicate_contacts_controller.dart';

class DuplicateContactsView extends StatelessWidget {
  const DuplicateContactsView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DuplicateContactsController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.pageBackground(context),
          body: SafeArea(
            child: Column(
              children: [
                _ContactsHeader(controller: controller),
                Expanded(child: _ContactsBody(controller: controller)),
                _ContactsBottomAction(controller: controller),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ContactsBody extends StatelessWidget {
  const _ContactsBody({required this.controller});

  final DuplicateContactsController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const ListShimmer();
    }

    if (!controller.hasAccess) {
      return _CenteredContactState(
        icon: LucideIcons.contact,
        title: controller.errorMessage == null
            ? 'Contacts access needed'
            : 'Contacts unavailable',
        body:
            controller.errorMessage ??
            'Allow contacts access to show duplicate contacts here.',
        primaryLabel: 'Open Settings',
        onPrimary: controller.openSettings,
        secondaryLabel: 'Try Again',
        onSecondary: controller.loadContacts,
      );
    }

    if (controller.groups.isEmpty) {
      return _CenteredContactState(
        icon: LucideIcons.contact,
        title: 'No duplicate contacts found',
        body:
            'Contacts with matching phone numbers, emails, or names will appear here.',
        primaryLabel: 'Refresh',
        onPrimary: controller.loadContacts,
      );
    }

    return RefreshIndicator(
      color: AppColors.accent,
      backgroundColor: AppColors.surface(context),
      onRefresh: controller.loadContacts,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _ContactsSummary(controller: controller);
          }
          return _ContactGroupCard(
            group: controller.groups[index - 1],
            controller: controller,
          );
        },
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemCount: controller.groups.length + 1,
      ),
    );
  }
}

class _ContactsSummary extends StatelessWidget {
  const _ContactsSummary({required this.controller});

  final DuplicateContactsController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${controller.duplicateCount} Duplicated Contacts',
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 24,
              letterSpacing: -0.8,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${controller.groups.length} matching groups ready to review',
            style: TextStyle(
              color: AppColors.textMuted(context),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _ContactStatTile(
                value: controller.duplicateCount.toString(),
                label: 'Total Dupes',
                accent: AppColors.accent,
                tint: AppColors.tintTeal,
              ),
              const SizedBox(width: 12),
              _ContactStatTile(
                value: controller.selectedIds.length.toString(),
                label: 'Selected',
                accent: AppColors.iconBlue,
                tint: AppColors.tintBlue,
              ),
              const SizedBox(width: 12),
              _ContactStatTile(
                value: controller.groups.length.toString(),
                label: 'Groups',
                accent: AppColors.accentDeep,
                tint: AppColors.tintMint,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactStatTile extends StatelessWidget {
  const _ContactStatTile({
    required this.value,
    required this.label,
    required this.accent,
    required this.tint,
  });

  final String value;
  final String label;
  final Color accent;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: AppColors.iconChipBg(context, accent, tint),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                color: accent,
                fontSize: 20,
                letterSpacing: -0.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactGroupCard extends StatelessWidget {
  const _ContactGroupCard({required this.group, required this.controller});

  final DuplicateContactGroup group;
  final DuplicateContactsController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderFor(context)),
        boxShadow: AppColors.isLight(context)
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 11),
            decoration: BoxDecoration(
              color: AppColors.surfaceTint(context),
              border: Border(
                bottom: BorderSide(color: AppColors.borderFor(context)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${group.contacts.length} matches · ${group.label}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          for (final contact in group.contacts)
            _ContactRow(
              contact: contact,
              selected: controller.isSelected(contact),
              onTap: () => controller.toggleContact(contact),
            ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.contact,
    required this.selected,
    required this.onTap,
  });

  final Contact contact;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = contact.displayName?.trim().isNotEmpty == true
        ? contact.displayName!.trim()
        : 'Unnamed contact';
    final detail = contact.phones.isNotEmpty
        ? contact.phones.first.number
        : contact.emails.isNotEmpty
        ? contact.emails.first.address
        : 'No phone or email';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.iconChipBg(
                context,
                AppColors.accent,
                AppColors.tintTeal,
              ),
              child: Text(
                name.characters.first.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.accentDeep,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
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
                    detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textMuted(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            _ContactSelectionMark(selected: selected),
          ],
        ),
      ),
    );
  }
}

class _ContactSelectionMark extends StatelessWidget {
  const _ContactSelectionMark({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: selected ? AppColors.accent : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.accent : AppColors.borderFor(context),
        ),
      ),
      child: selected
          ? const Icon(LucideIcons.check, size: 14, color: Colors.white)
          : null,
    );
  }
}

class _CenteredContactState extends StatelessWidget {
  const _CenteredContactState({
    required this.icon,
    required this.title,
    required this.body,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  final IconData icon;
  final String title;
  final String body;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.accent, size: 42),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 22),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextButton(
                onPressed: onPrimary,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.w800),
                ),
                child: Text(primaryLabel),
              ),
            ),
            if (secondaryLabel != null && onSecondary != null) ...[
              const SizedBox(height: 10),
              TextButton(
                onPressed: onSecondary,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.accent,
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
                child: Text(secondaryLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ContactsHeader extends StatelessWidget {
  const _ContactsHeader({required this.controller});

  final DuplicateContactsController controller;

  @override
  Widget build(BuildContext context) {
    final contacts = controller.contacts;
    final allSelected =
        contacts.isNotEmpty && controller.selectedIds.length == contacts.length;

    return SiftTopAppBar(
      title: 'duplicate_contacts'.tr,
      trailing: TextButton(
        onPressed: contacts.isEmpty ? null : controller.toggleSelectAll,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent,
          disabledForegroundColor: AppColors.textFaint(context),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
        child: Text(allSelected ? 'clear'.tr : 'select_all'.tr),
      ),
    );
  }
}

class _ContactsBottomAction extends StatelessWidget {
  const _ContactsBottomAction({required this.controller});

  final DuplicateContactsController controller;

  @override
  Widget build(BuildContext context) {
    final selectedCount = controller.selectedIds.length;
    final enabled = selectedCount > 0 && !controller.isDeleting;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: BoxDecoration(
        color: AppColors.bottomBar(context),
        border: Border(top: BorderSide(color: AppColors.borderFor(context))),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: TextButton.icon(
          onPressed: enabled ? () => _confirmAndDelete(controller) : null,
          icon: controller.isDeleting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(LucideIcons.trash, size: 18),
          label: Text(
            controller.isDeleting
                ? 'Deleting...'
                : 'Delete selected ($selectedCount)',
          ),
          style: TextButton.styleFrom(
            disabledBackgroundColor: AppColors.surfaceTint(context),
            disabledForegroundColor: AppColors.textFaint(context),
            backgroundColor: AppColors.danger,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmAndDelete(DuplicateContactsController controller) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text(
          'Delete selected?',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: Text(
          'This will delete ${controller.selectedIds.length} selected contacts from your phone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    final deleted = await controller.deleteSelected();
    Get.snackbar(
      deleted == 0 ? 'Nothing deleted' : 'Deleted $deleted',
      deleted == 0
          ? 'No contacts were removed.'
          : 'Your contacts have been updated.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
