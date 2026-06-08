import 'package:get/get.dart';
import 'package:sift/models/trashed_item.dart';
import 'package:sift/services/recycle_bin_service.dart';

class RecycleBinController extends GetxController {
  final RecycleBinService _bin = Get.find<RecycleBinService>();

  final Set<String> selectedIds = <String>{};
  bool isBusy = false;
  String? message;

  int get retentionDays => RecycleBinService.retentionDays;

  List<TrashedItem> get items => _bin.items;

  bool get isEmpty => items.isEmpty;

  bool get hasSelection => selectedIds.isNotEmpty;

  bool isSelected(TrashedItem item) => selectedIds.contains(item.id);

  @override
  void onInit() {
    super.onInit();
    // Drop anything that expired while the app was closed.
    _bin.purgeExpired().then((_) => update());
  }

  void toggleSelect(TrashedItem item) {
    if (!selectedIds.add(item.id)) {
      selectedIds.remove(item.id);
    }
    update();
  }

  void selectAll() {
    if (selectedIds.length == items.length) {
      selectedIds.clear();
    } else {
      selectedIds
        ..clear()
        ..addAll(items.map((item) => item.id));
    }
    update();
  }

  void clearSelection() {
    selectedIds.clear();
    update();
  }

  List<TrashedItem> get _selectedItems =>
      items.where((item) => selectedIds.contains(item.id)).toList();

  Future<void> restoreSelected() async {
    if (isBusy || selectedIds.isEmpty) {
      return;
    }
    isBusy = true;
    update();

    final restored = await _bin.restoreMany(_selectedItems);
    selectedIds.clear();
    isBusy = false;
    message = restored > 0 ? 'restored' : null;
    update();
  }

  Future<void> deleteSelected() async {
    if (isBusy || selectedIds.isEmpty) {
      return;
    }
    isBusy = true;
    update();

    await _bin.deleteManyPermanently(_selectedItems);
    selectedIds.clear();
    isBusy = false;
    update();
  }

  Future<void> emptyBin() async {
    if (isBusy || items.isEmpty) {
      return;
    }
    isBusy = true;
    update();

    await _bin.emptyBin();
    selectedIds.clear();
    isBusy = false;
    update();
  }

  void consumeMessage() {
    message = null;
  }
}
