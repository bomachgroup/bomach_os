import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import 'package:bomach_os/src/model/career_path_model.dart';
import 'package:bomach_os/src/services/career_path_service.dart';

class CareerPathController extends GetxController {
  final CareerPathService _service = CareerPathService();
  final _storage = const FlutterSecureStorage();

  final RxList<CareerPathStep> steps = <CareerPathStep>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  int scopedRoleId = 0;

  Future<String?> _getToken() async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith('Bearer ')) token = token.substring(7);
    return token.replaceAll('"', '').trim();
  }

  Future<void> fetchSteps(int roleId) async {
    scopedRoleId = roleId;
    isLoading.value = true;
    try {
      final token = await _getToken();
      if (token == null) return;
      steps.value = await _service.getSteps(token, roleId);
    } catch (e) {
      log('fetchSteps error: $e');
      steps.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addStep(Map<String, dynamic> body) async {
    isSaving.value = true;
    try {
      final token = await _getToken();
      if (token == null) return false;
      final step = await _service.createStep(token, scopedRoleId, body);
      steps.add(step);
      return true;
    } catch (e) {
      log('addStep error: $e');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> updateStep(int id, Map<String, dynamic> body) async {
    isSaving.value = true;
    try {
      final token = await _getToken();
      if (token == null) return false;
      final updated = await _service.updateStep(token, scopedRoleId, id, body);
      final idx = steps.indexWhere((s) => s.id == id);
      if (idx != -1) steps[idx] = updated;
      return true;
    } catch (e) {
      log('updateStep error: $e');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deleteStep(int id) async {
    try {
      final token = await _getToken();
      if (token == null) return false;
      await _service.deleteStep(token, scopedRoleId, id);
      steps.removeWhere((s) => s.id == id);
      return true;
    } catch (e) {
      log('deleteStep error: $e');
      return false;
    }
  }
}
