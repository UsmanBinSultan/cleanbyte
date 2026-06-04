import 'package:get/get.dart';
import 'package:sift/app/duplicate_contacts/duplicate_contacts_controller.dart';

class DuplicateContactsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DuplicateContactsController());
  }
}
