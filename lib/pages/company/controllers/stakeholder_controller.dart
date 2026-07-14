import 'dart:developer';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:bomach_os/src/model/stakeholder_model.dart';
import 'package:bomach_os/src/services/stakeholder_service.dart';

class StakeholderController extends GetxController {
  final StakeholderService _service = StakeholderService();
  final _storage = const FlutterSecureStorage();

  final RxList<RoleStakeholder> stakeholders = <RoleStakeholder>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  int scopedRoleId = 0;

  Future<String?> _getToken() async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith('Bearer ')) token = token.substring(7);
    return token.replaceAll('"', '').trim();
  }

  Future<void> fetchStakeholders(int roleId) async {
    scopedRoleId = roleId; isLoading.value = true;
    try {
      final token = await _getToken(); if (token == null) return;
      stakeholders.value = await _service.getStakeholders(token, roleId);
    } catch (e) { log('fetchStakeholders error: $e'); stakeholders.clear(); }
    finally { isLoading.value = false; }
  }

  Future<bool> addStakeholder(Map<String, dynamic> body) async {
    isSaving.value = true;
    try {
      final token = await _getToken(); if (token == null) return false;
      stakeholders.add(await _service.createStakeholder(token, body)); return true;
    } catch (e) { log('addStakeholder error: $e'); return false; }
    finally { isSaving.value = false; }
  }

  Future<bool> updateStakeholder(int id, Map<String, dynamic> body) async {
    isSaving.value = true;
    try {
      final token = await _getToken(); if (token == null) return false;
      final updated = await _service.updateStakeholder(token, id, body);
      final idx = stakeholders.indexWhere((s) => s.id == id);
      if (idx != -1) stakeholders[idx] = updated; return true;
    } catch (e) { log('updateStakeholder error: $e'); return false; }
    finally { isSaving.value = false; }
  }

  Future<bool> deleteStakeholder(int id) async {
    try {
      final token = await _getToken(); if (token == null) return false;
      await _service.deleteStakeholder(token, id);
      stakeholders.removeWhere((s) => s.id == id); return true;
    } catch (e) { log('deleteStakeholder error: $e'); return false; }
  }
}
