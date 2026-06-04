import 'package:get/get.dart';
import 'package:sift/app/whatsapp_cleaner/whatsapp_cleaner_controller.dart';

class WhatsappCleanerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => WhatsappCleanerController());
  }
}
