import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/components/sift_top_app_bar.dart';
import 'package:sift/app/duplicate_contacts/duplicate_contacts_controller.dart';

/// App bar for the duplicate contacts screen with a select-all / clear toggle.
class ContactsHeader extends StatelessWidget {
  const ContactsHeader({super.key, required this.controller});

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
        child: Text(allSelected ? 'clear'.tr : 'select all'.tr),
      ),
    );
  }
}
