import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sift/app/components/app_colors.dart';
import 'package:sift/app/duplicate_contacts/duplicate_contacts_controller.dart';
import 'package:sift/app/duplicate_contacts/widgets/contacts_body.dart';
import 'package:sift/app/duplicate_contacts/widgets/contacts_bottom_action.dart';
import 'package:sift/app/duplicate_contacts/widgets/contacts_header.dart';

/// Duplicate Contacts: review matching contacts grouped by phone/email/name and
/// delete the extras. Sub-widgets live under `widgets/`.
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
                ContactsHeader(controller: controller),
                Expanded(child: ContactsBody(controller: controller)),
                ContactsBottomAction(controller: controller),
              ],
            ),
          ),
        );
      },
    );
  }
}
