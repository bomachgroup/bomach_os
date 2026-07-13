import 'dart:developer';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:bomach_os/src/model/role_risk_profile_model.dart';
import 'package:bomach_os/src/services/role_risk_service.dart';

class RoleRiskController extends GetxController {
  final RoleRiskService _service = RoleRiskService();
  final _storage = const FlutterSecureStorage();

  final RxList<RoleRiskProfile> riskProfiles = <RoleRiskProfile>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  final RxInt totalCount = 0.obs;
  final RxInt compliantCount = 0.obs;
  final RxInt atRiskCount = 0.obs;
  final RxInt overdueCount = 0.obs;

  int scopedRoleId = 0;

  Future<String?> _getToken() async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith('Bearer ')) token = token.substring(7);
    return token.replaceAll('"', '').trim();
  }

  Future<void> fetchRiskProfiles(int roleId) async {
    scopedRoleId = roleId;
    isLoading.value = true;
    try {
      final token = await _getToken();
      if (token == null) return;
      riskProfiles.value = await _service.getRiskProfiles(token, roleId);
    } catch (e) {
      log('fetchRiskProfiles error: $e');
      riskProfiles.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchComplianceSummary() async {
    try {
      final token = await _getToken();
      if (token == null) return;
      final summary = await _service.getComplianceSummary(token);
      totalCount.value = summary.total;
      compliantCount.value = summary.compliant;
      atRiskCount.value = summary.atRisk;
      overdueCount.value = summary.overdue;
    } catch (e) {
      log('fetchComplianceSummary error: $e');
    }
  }

  Future<bool> addRiskProfile(Map<String, dynamic> body) async {
    isSaving.value = true;
    try {
      final token = await _getToken();
      if (token == null) return false;
      final item = await _service.createRiskProfile(token, body);
      riskProfiles.add(item);
      return true;
    } catch (e) {
      log('addRiskProfile error: $e');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> updateRiskProfile(int id, Map<String, dynamic> body) async {
    isSaving.value = true;
    try {
      final token = await _getToken();
      if (token == null) return false;
      final updated = await _service.updateRiskProfile(token, id, body);
      final idx = riskProfiles.indexWhere((r) => r.id == id);
      if (idx != -1) riskProfiles[idx] = updated;
      return true;
    } catch (e) {
      log('updateRiskProfile error: $e');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deleteRiskProfile(int id) async {
    try {
      final token = await _getToken();
      if (token == null) return false;
      await _service.deleteRiskProfile(token, id);
      riskProfiles.removeWhere((r) => r.id == id);
      return true;
    } catch (e) {
      log('deleteRiskProfile error: $e');
      return false;
    }
  }
}
