import 'dart:io';

import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class LargeFileItem {
  const LargeFileItem({
    required this.path,
    required this.name,
    required this.size,
    required this.modified,
  });

  final String path;
  final String name;
  final int size;
  final DateTime modified;

  String get extension {
    final dot = name.lastIndexOf('.');
    if (dot == -1 || dot == name.length - 1) {
      return 'FILE';
    }
    return name.substring(dot + 1).toUpperCase();
  }
}

class LargeFilesController extends GetxController {
  final Set<String> selectedPaths = <String>{};

  bool isLoading = true;
  bool isDeleting = false;
  bool hasAccess = false;
  String? errorMessage;
  List<LargeFileItem> files = <LargeFileItem>[];

  static const int _maxFiles = 300;
  static const int _minBytes = 256 * 1024;

  int get selectedCount => selectedPaths.length;

  @override
  void onInit() {
    super.onInit();
    loadFiles();
  }

  Future<void> loadFiles() async {
    isLoading = true;
    errorMessage = null;
    update();

    hasAccess = await _requestStorageAccess();
    if (!hasAccess) {
      files = <LargeFileItem>[];
      selectedPaths.clear();
      isLoading = false;
      update();
      return;
    }

    try {
      files = await _scanLargeDocuments();
      selectedPaths.removeWhere(
        (path) => files.every((file) => file.path != path),
      );
    } catch (_) {
      files = <LargeFileItem>[];
      selectedPaths.clear();
      errorMessage =
          'Could not scan documents. Allow all files access and try again.';
    }

    isLoading = false;
    update();
  }

  bool isSelected(LargeFileItem file) => selectedPaths.contains(file.path);

  void toggleFile(LargeFileItem file) {
    if (!selectedPaths.add(file.path)) {
      selectedPaths.remove(file.path);
    }
    update();
  }

  void toggleSelectAll() {
    if (files.isEmpty) {
      return;
    }
    if (selectedPaths.length == files.length) {
      selectedPaths.clear();
    } else {
      selectedPaths
        ..clear()
        ..addAll(files.map((file) => file.path));
    }
    update();
  }

  Future<int> deleteSelected() async {
    if (selectedPaths.isEmpty || isDeleting) {
      return 0;
    }

    isDeleting = true;
    update();

    var deleted = 0;
    final paths = selectedPaths.toList(growable: false);
    for (final path in paths) {
      try {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
          deleted++;
        }
      } catch (_) {
        // Keep going so one locked file does not block the cleanup.
      }
    }

    files = files.where((file) => !paths.contains(file.path)).toList();
    selectedPaths.clear();
    isDeleting = false;
    update();
    return deleted;
  }

  Future<void> openSettings() => openAppSettings();

  Future<bool> _requestStorageAccess() async {
    if (!Platform.isAndroid) {
      return true;
    }

    if (await Permission.manageExternalStorage.isGranted) {
      return true;
    }

    final manageStatus = await Permission.manageExternalStorage.request();
    if (manageStatus.isGranted) {
      return true;
    }

    final storageStatus = await Permission.storage.request();
    return storageStatus.isGranted || storageStatus.isLimited;
  }

  Future<List<LargeFileItem>> _scanLargeDocuments() async {
    final roots = await _documentRoots();
    final byPath = <String, LargeFileItem>{};

    for (final root in roots) {
      if (!await root.exists()) {
        continue;
      }
      await for (final entity in root.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is! File || !_looksLikeDocument(entity.path)) {
          continue;
        }
        try {
          final stat = await entity.stat();
          if (stat.size < _minBytes) {
            continue;
          }
          byPath[entity.path] = LargeFileItem(
            path: entity.path,
            name: entity.uri.pathSegments.isEmpty
                ? entity.path
                : entity.uri.pathSegments.last,
            size: stat.size,
            modified: stat.modified,
          );
        } catch (_) {
          // Ignore files we cannot stat.
        }
      }
    }

    final items = byPath.values.toList()
      ..sort((a, b) {
        final sizeCompare = b.size.compareTo(a.size);
        if (sizeCompare != 0) {
          return sizeCompare;
        }
        return b.modified.compareTo(a.modified);
      });
    return items.take(_maxFiles).toList();
  }

  Future<List<Directory>> _documentRoots() async {
    if (Platform.isAndroid) {
      return [
        Directory('/storage/emulated/0/Download'),
        Directory('/storage/emulated/0/Documents'),
        Directory('/storage/emulated/0/DCIM'),
        Directory('/storage/emulated/0/WhatsApp/Media/WhatsApp Documents'),
        Directory(
          '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Documents',
        ),
      ];
    }

    final docs = await getApplicationDocumentsDirectory();
    final downloads = await getDownloadsDirectory();
    return [docs, ?downloads];
  }

  bool _looksLikeDocument(String path) {
    final lower = path.toLowerCase();
    const extensions = [
      '.pdf',
      '.doc',
      '.docx',
      '.xls',
      '.xlsx',
      '.ppt',
      '.pptx',
      '.txt',
      '.rtf',
      '.csv',
      '.zip',
      '.rar',
      '.7z',
      '.apk',
      '.epub',
    ];
    return extensions.any(lower.endsWith);
  }
}
