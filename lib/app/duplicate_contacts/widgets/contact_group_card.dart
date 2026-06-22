import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/duplicate_contacts/duplicate_contacts_controller.dart';

/// One duplicate set: a match header followed by the selectable contact rows.
class ContactGroupCard extends StatelessWidget {
  const ContactGroupCard({
    super.key,
    required this.group,
    required this.controller,
  });

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
