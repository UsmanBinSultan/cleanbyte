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
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? const Color(0xFFFFFBF5)
              : const Color(0xFF071120),
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
      color: const Color(0xFF18D0B8),
      backgroundColor: AppColors.surface(context),
      onRefresh: controller.loadContacts,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
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
            '${controller.duplicateCount} duplicate contacts',
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${controller.groups.length} matching groups ready to review',
            style: TextStyle(
              color: AppColors.textMuted(context),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
            child: Text(
              '${group.contacts.length} matches - ${group.label}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.isLight(context)
                    ? const Color(0xFF0E8F80)
                    : const Color(0xFF18D0B8),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
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
        padding: const EdgeInsets.fromLTRB(14, 9, 14, 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.isLight(context)
                  ? AppColors.lightSurfaceTint
                  : const Color(0xFF172133),
              child: Text(
                name.characters.first.toUpperCase(),
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
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
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textMuted(context),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
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
        color: selected ? const Color(0xFF18D0B8) : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? const Color(0xFF18D0B8) : const Color(0xFF697385),
        ),
      ),
      child: selected
          ? const Icon(LucideIcons.check, size: 14, color: Color(0xFF062322))
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
            Icon(icon, color: const Color(0xFF18D0B8), size: 42),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 20,
                fontWeight: FontWeight.w900,
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
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 22),
            TextButton(
              onPressed: onPrimary,
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF18D0B8),
                foregroundColor: const Color(0xFF062322),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.w900),
              ),
              child: Text(primaryLabel),
            ),
            if (secondaryLabel != null && onSecondary != null) ...[
              const SizedBox(height: 10),
              TextButton(
                onPressed: onSecondary,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF18D0B8),
                  textStyle: const TextStyle(fontWeight: FontWeight.w800),
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
          foregroundColor: const Color(0xFF18D0B8),
          disabledForegroundColor: const Color(0xFF4A5362),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
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
            disabledBackgroundColor: AppColors.isLight(context)
                ? AppColors.lightBorder
                : const Color(0xFF111929),
            disabledForegroundColor: const Color(0xFF586274),
            backgroundColor: const Color(0xFFFF7A5F),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmAndDelete(DuplicateContactsController controller) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: const Color(0xFF111929),
        title: const Text(
          'Delete selected?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        content: Text(
          'This will delete ${controller.selectedIds.length} selected contacts from your phone.',
          style: const TextStyle(color: Color(0xFFC2CAD6)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF7A5F),
            ),
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
      backgroundColor: const Color(0xFF111929),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }
}
