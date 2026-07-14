import 'dart:developer';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:bomach_os/src/model/succession_plan_model.dart';
import 'package:bomach_os/src/services/succession_plan_service.dart';

class SuccessionPlanController extends GetxController {
  final SuccessionPlanService _service = SuccessionPlanService();
  final _storage = const FlutterSecureStorage();

  final RxList<SuccessionPlan> plans = <SuccessionPlan>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  int scopedRoleId = 0;

  Future<String?> _getToken() async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith('Bearer ')) token = token.substring(7);
    return token.replaceAll('"', '').trim();
  }

  Future<void> fetchPlans(int roleId) async {
    scopedRoleId = roleId; isLoading.value = true;
    try {
      final token = await _getToken(); if (token == null) return;
      plans.value = await _service.getPlans(token, roleId);
    } catch (e) { log('fetchPlans error: $e'); plans.clear(); }
    finally { isLoading.value = false; }
  }

  Future<bool> addPlan(Map<String, dynamic> body) async {
    isSaving.value = true;
    try {
      final token = await _getToken(); if (token == null) return false;
      plans.add(await _service.createPlan(token, body)); return true;
    } catch (e) { log('addPlan error: $e'); return false; }
    finally { isSaving.value = false; }
  }

  Future<bool> updatePlan(int id, Map<String, dynamic> body) async {
    isSaving.value = true;
    try {
      final token = await _getToken(); if (token == null) return false;
      final updated = await _service.updatePlan(token, id, body);
      final idx = plans.indexWhere((p) => p.id == id);
      if (idx != -1) plans[idx] = updated; return true;
    } catch (e) { log('updatePlan error: $e'); return false; }
    finally { isSaving.value = false; }
  }

  Future<bool> deletePlan(int id) async {
    try {
      final token = await _getToken(); if (token == null) return false;
      await _service.deletePlan(token, id);
      plans.removeWhere((p) => p.id == id); return true;
    } catch (e) { log('deletePlan error: $e'); return false; }
  }
}
