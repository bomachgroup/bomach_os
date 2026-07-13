import 'dart:developer';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:bomach_os/src/model/decision_matrix_model.dart';
import 'package:bomach_os/src/services/decision_matrix_service.dart';

class DecisionMatrixController extends GetxController {
  final DecisionMatrixService _service = DecisionMatrixService();
  final _storage = const FlutterSecureStorage();

  final RxList<DecisionMatrixEntry> entries = <DecisionMatrixEntry>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  int scopedRoleId = 0;

  Future<String?> _getToken() async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith('Bearer ')) token = token.substring(7);
    return token.replaceAll('"', '').trim();
  }

  Future<void> fetchEntries(int roleId) async {
    scopedRoleId = roleId;
    isLoading.value = true;
    try {
      final token = await _getToken();
      if (token == null) return;
      entries.value = await _service.getEntries(token, roleId);
    } catch (e) {
      log('fetchEntries error: $e');
      entries.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addEntry(Map<String, dynamic> body) async {
    isSaving.value = true;
    try {
      final token = await _getToken();
      if (token == null) return false;
      final item = await _service.createEntry(token, body);
      entries.add(item);
      return true;
    } catch (e) {
      log('addEntry error: $e');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> updateEntry(int id, Map<String, dynamic> body) async {
    isSaving.value = true;
    try {
      final token = await _getToken();
      if (token == null) return false;
      final updated = await _service.updateEntry(token, id, body);
      final idx = entries.indexWhere((e) => e.id == id);
      if (idx != -1) entries[idx] = updated;
      return true;
    } catch (e) {
      log('updateEntry error: $e');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deleteEntry(int id) async {
    try {
      final token = await _getToken();
      if (token == null) return false;
      await _service.deleteEntry(token, id);
      entries.removeWhere((e) => e.id == id);
      return true;
    } catch (e) {
      log('deleteEntry error: $e');
      return false;
    }
  }
}
