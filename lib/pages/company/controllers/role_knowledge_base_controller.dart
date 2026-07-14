import 'dart:developer';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:bomach_os/src/model/role_knowledge_base_model.dart';
import 'package:bomach_os/src/services/role_knowledge_base_service.dart';

class RoleKnowledgeBaseController extends GetxController {
  final RoleKnowledgeBaseService _service = RoleKnowledgeBaseService();
  final _storage = const FlutterSecureStorage();

  final RxList<RoleKnowledgeEntry> entries = <RoleKnowledgeEntry>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxString searchQuery = ''.obs;

  int scopedRoleId = 0;

  Future<String?> _getToken() async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith('Bearer ')) token = token.substring(7);
    return token.replaceAll('"', '').trim();
  }

  Future<void> fetchEntries({int? roleId, String? category, String? search}) async {
    if (roleId != null) scopedRoleId = roleId;
    isLoading.value = true;
    try {
      final token = await _getToken(); if (token == null) return;
      entries.value = await _service.getEntries(token, roleId: roleId ?? scopedRoleId, category: category, search: search);
    } catch (e) { log('fetchEntries error: $e'); entries.clear(); }
    finally { isLoading.value = false; }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    fetchEntries(search: query.isNotEmpty ? query : null);
  }

  Future<bool> addEntry(Map<String, dynamic> body) async {
    isSaving.value = true;
    try {
      final token = await _getToken(); if (token == null) return false;
      entries.add(await _service.createEntry(token, body)); return true;
    } catch (e) { log('addEntry error: $e'); return false; }
    finally { isSaving.value = false; }
  }

  Future<bool> updateEntry(int id, Map<String, dynamic> body) async {
    isSaving.value = true;
    try {
      final token = await _getToken(); if (token == null) return false;
      final updated = await _service.updateEntry(token, id, body);
      final idx = entries.indexWhere((e) => e.id == id);
      if (idx != -1) entries[idx] = updated; return true;
    } catch (e) { log('updateEntry error: $e'); return false; }
    finally { isSaving.value = false; }
  }

  Future<bool> deleteEntry(int id) async {
    try {
      final token = await _getToken(); if (token == null) return false;
      await _service.deleteEntry(token, id);
      entries.removeWhere((e) => e.id == id); return true;
    } catch (e) { log('deleteEntry error: $e'); return false; }
  }
}
