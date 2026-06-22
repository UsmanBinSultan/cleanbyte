import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/loading_shimmer.dart';
import 'package:sift/app/duplicate_contacts/duplicate_contacts_controller.dart';
import 'package:sift/app/duplicate_contacts/widgets/centered_contact_state.dart';
import 'package:sift/app/duplicate_contacts/widgets/contact_group_card.dart';
import 'package:sift/app/duplicate_contacts/widgets/contacts_summary.dart';

/// Routes to the correct duplicate-contacts body: loading, no-access, empty, or
/// the summary header followed by the duplicate group cards.
class ContactsBody extends StatelessWidget {
  const ContactsBody({super.key, required this.controller});

  final DuplicateContactsController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const ListShimmer();
    }

    if (!controller.hasAccess) {
      return CenteredContactState(
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
      return CenteredContactState(
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
            return ContactsSummary(controller: controller);
          }
          return ContactGroupCard(
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
