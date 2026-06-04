import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';

class DuplicateContactGroup {
  const DuplicateContactGroup({
    required this.key,
    required this.label,
    required this.contacts,
  });

  final String key;
  final String label;
  final List<Contact> contacts;
}

class DuplicateContactsController extends GetxController {
  final Set<String> selectedIds = <String>{};

  bool isLoading = true;
  bool isDeleting = false;
  bool hasAccess = false;
  String? errorMessage;
  List<DuplicateContactGroup> groups = <DuplicateContactGroup>[];

  int get duplicateCount =>
      groups.fold(0, (total, group) => total + group.contacts.length);

  List<Contact> get contacts =>
      groups.expand((group) => group.contacts).toList(growable: false);

  @override
  void onInit() {
    super.onInit();
    loadContacts();
  }

  Future<void> loadContacts() async {
    isLoading = true;
    errorMessage = null;
    update();

    try {
      final permission = await FlutterContacts.permissions
          .request(PermissionType.read)
          .timeout(const Duration(seconds: 20));
      hasAccess =
          permission == PermissionStatus.granted ||
          permission == PermissionStatus.limited;

      if (!hasAccess) {
        groups = <DuplicateContactGroup>[];
        selectedIds.clear();
        isLoading = false;
        update();
        return;
      }

      final loaded = await FlutterContacts.getAll(
        properties: const {
          ContactProperty.name,
          ContactProperty.phone,
          ContactProperty.email,
        },
      ).timeout(const Duration(seconds: 30));
      groups = _findDuplicateGroups(loaded);
      selectedIds.removeWhere(
        (id) => contacts.every((contact) => contact.id != id),
      );
    } on TimeoutException {
      hasAccess = false;
      groups = <DuplicateContactGroup>[];
      selectedIds.clear();
      errorMessage =
          'Contacts did not respond. Please check permission settings and try again.';
    } catch (_) {
      hasAccess = false;
      groups = <DuplicateContactGroup>[];
      selectedIds.clear();
      errorMessage = 'Could not load contacts. Please grant access and retry.';
    }
    isLoading = false;
    update();
  }

  bool isSelected(Contact contact) =>
      contact.id != null && selectedIds.contains(contact.id);

  void toggleContact(Contact contact) {
    final id = contact.id;
    if (id == null) {
      return;
    }
    final isDeselecting = selectedIds.contains(id);
    if (!isDeselecting && _wouldEmptyGroup(id)) {
      Get.snackbar(
        'One contact is kept',
        'At least one contact from each duplicate set stays on your phone.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF111929),
        colorText: const Color(0xFFFFFFFF),
        margin: const EdgeInsets.all(16),
      );
      return;
    }
    if (!selectedIds.add(id)) {
      selectedIds.remove(id);
    }
    update();
  }

  /// Returns true when selecting [id] would mark every contact in its duplicate
  /// group for deletion, leaving no survivor.
  bool _wouldEmptyGroup(String id) {
    final group = _groupForContact(id);
    if (group == null) {
      return false;
    }
    final unselected = group.contacts
        .map((contact) => contact.id)
        .whereType<String>()
        .where((contactId) => !selectedIds.contains(contactId))
        .length;
    return unselected <= 1;
  }

  DuplicateContactGroup? _groupForContact(String id) {
    for (final group in groups) {
      if (group.contacts.any((contact) => contact.id == id)) {
        return group;
      }
    }
    return null;
  }

  /// Every duplicate contact except one survivor per group.
  Set<String> _extraContactIds() {
    final extras = <String>{};
    for (final group in groups) {
      final ids = group.contacts
          .map((contact) => contact.id)
          .whereType<String>()
          .toList(growable: false);
      // Keep the first contact in each group, mark the rest as extras.
      for (var i = 1; i < ids.length; i++) {
        extras.add(ids[i]);
      }
    }
    return extras;
  }

  void toggleSelectAll() {
    // "Select all" keeps one survivor per group, so it can never wipe an
    // entire duplicate set.
    final extras = _extraContactIds();
    if (extras.isEmpty) {
      return;
    }
    final allExtrasSelected = extras.every(selectedIds.contains);
    selectedIds.clear();
    if (!allExtrasSelected) {
      selectedIds.addAll(extras);
    }
    update();
  }

  /// Auto-clean: select every duplicate contact except one survivor per group.
  void autoSelectExtras() {
    final extras = _extraContactIds();
    selectedIds
      ..clear()
      ..addAll(extras);
    update();
  }

  Future<int> deleteSelected() async {
    if (selectedIds.isEmpty || isDeleting) {
      return 0;
    }

    isDeleting = true;
    errorMessage = null;
    update();

    final permission = await FlutterContacts.permissions.request(
      PermissionType.readWrite,
    );
    final canDelete =
        permission == PermissionStatus.granted ||
        permission == PermissionStatus.limited;
    if (!canDelete) {
      isDeleting = false;
      errorMessage = 'Contacts write permission is needed to delete contacts.';
      update();
      return 0;
    }

    final ids = selectedIds.toList(growable: false);
    await FlutterContacts.deleteAll(ids);
    // Keep any surviving contact on screen (even if a group now has a single
    // member) so it is obvious the kept copy was not deleted. Empty groups are
    // dropped; a later refresh re-evaluates what is still a duplicate.
    groups = groups
        .map(
          (group) => DuplicateContactGroup(
            key: group.key,
            label: group.label,
            contacts: group.contacts
                .where((contact) => !ids.contains(contact.id))
                .toList(),
          ),
        )
        .where((group) => group.contacts.isNotEmpty)
        .toList();
    selectedIds.clear();
    isDeleting = false;
    update();

    return ids.length;
  }

  Future<void> openSettings() => FlutterContacts.permissions.openSettings();

  List<DuplicateContactGroup> _findDuplicateGroups(List<Contact> contacts) {
    final byKey = <String, List<Contact>>{};
    final labels = <String, String>{};

    for (final contact in contacts) {
      final keys = _duplicateKeys(contact);
      for (final entry in keys.entries) {
        byKey.putIfAbsent(entry.key, () => <Contact>[]).add(contact);
        labels.putIfAbsent(entry.key, () => entry.value);
      }
    }

    final usedIds = <String>{};
    final result = <DuplicateContactGroup>[];
    for (final entry in byKey.entries) {
      final uniqueContacts = <Contact>[];
      final localIds = <String>{};
      for (final contact in entry.value) {
        final id = contact.id;
        if (id == null || usedIds.contains(id) || !localIds.add(id)) {
          continue;
        }
        uniqueContacts.add(contact);
      }
      if (uniqueContacts.length < 2) {
        continue;
      }
      usedIds.addAll(
        uniqueContacts.map((contact) => contact.id).whereType<String>(),
      );
      result.add(
        DuplicateContactGroup(
          key: entry.key,
          label: labels[entry.key] ?? 'Matching contact details',
          contacts: uniqueContacts,
        ),
      );
    }

    result.sort((a, b) => b.contacts.length.compareTo(a.contacts.length));
    return result;
  }

  Map<String, String> _duplicateKeys(Contact contact) {
    final keys = <String, String>{};

    for (final phone in contact.phones) {
      final normalized = _normalizePhone(
        phone.normalizedNumber ?? phone.number,
      );
      if (normalized.length >= 7) {
        keys['phone:$normalized'] = phone.number;
      }
    }

    for (final email in contact.emails) {
      final normalized = email.address.trim().toLowerCase();
      if (normalized.isNotEmpty) {
        keys['email:$normalized'] = email.address;
      }
    }

    if (keys.isEmpty) {
      final name = (contact.displayName ?? '').trim().toLowerCase();
      if (name.length >= 3) {
        keys['name:$name'] = contact.displayName ?? name;
      }
    }

    return keys;
  }

  String _normalizePhone(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.startsWith('+')) {
      return '+${digits.substring(1).replaceAll(RegExp(r'[^0-9]'), '')}';
    }
    return digits.replaceAll(RegExp(r'[^0-9]'), '');
  }
}
