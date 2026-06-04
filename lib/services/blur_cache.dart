import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sift/models/blur_result.dart';

class BlurCache {
  BlurCache._();

  static final BlurCache instance = BlurCache._();
  static const _fileName = 'blur_results_cache.json';

  Map<String, BlurScanResult>? _memory;

  Future<BlurScanResult?> get(String assetId) async {
    final cache = await _load();
    final result = cache[assetId];
    if (result == null || result.isExpired) {
      return null;
    }
    return result;
  }

  Future<void> putAll(Iterable<BlurScanResult> results) async {
    final cache = await _load();
    for (final result in results) {
      cache[result.assetId] = result;
    }
    await _save(cache);
  }

  Future<List<BlurScanResult>> validForAssetIds(Iterable<String> ids) async {
    final cache = await _load();
    final idSet = ids.toSet();
    return cache.values
        .where((result) => idSet.contains(result.assetId) && !result.isExpired)
        .toList(growable: false);
  }

  Future<void> clear() async {
    _memory = <String, BlurScanResult>{};
    final file = await _file();
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<Map<String, BlurScanResult>> _load() async {
    final memory = _memory;
    if (memory != null) {
      return memory;
    }
    try {
      final file = await _file();
      if (!await file.exists()) {
        return _memory = <String, BlurScanResult>{};
      }
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! List) {
        return _memory = <String, BlurScanResult>{};
      }
      return _memory = {
        for (final item in decoded.whereType<Map>())
          BlurScanResult.fromJson(Map<String, dynamic>.from(item)).assetId:
              BlurScanResult.fromJson(Map<String, dynamic>.from(item)),
      }..removeWhere((_, result) => result.assetId.isEmpty);
    } catch (_) {
      return _memory = <String, BlurScanResult>{};
    }
  }

  Future<void> _save(Map<String, BlurScanResult> cache) async {
    final file = await _file();
    await file.writeAsString(
      jsonEncode(cache.values.map((result) => result.toJson()).toList()),
      flush: true,
    );
  }

  Future<File> _file() async {
    final directory = await getApplicationSupportDirectory();
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return File('${directory.path}${Platform.pathSeparator}$_fileName');
  }
}
