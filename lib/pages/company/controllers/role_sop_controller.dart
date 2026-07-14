import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../../../src/model/role_sop_model.dart';
import '../../../src/services/role_sop_service.dart';

class RoleSopController extends GetxController {
  final RoleSopService _service = RoleSopService();
  final _storage = const FlutterSecureStorage();

  var sops = <RoleSop>[].obs;
  var isLoading = false.obs;
  var isSaving = false.obs;
  var errorMessage = ''.obs;

  int? scopedRoleId;

  Future<String?> _getToken() async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith('Bearer ')) token = token.substring(7);
    return token.replaceAll('"', '').trim();
  }

  Future<void> fetchSops({int? roleId}) async {
    isLoading.value = true;
    try {
      final token = await _getToken();
      if (token == null) return;

      final result = await _service.listSops(
        token,
        roleId: roleId ?? scopedRoleId,
        limit: 100,
      );

      sops.assignAll(result.list);
    } catch (e) {
      log('RoleSopController.fetchSops error: $e');
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createSop(
    BuildContext context, {
    required int roleId,
    required String title,
    String? description,
    List<SopStep> steps = const [],
    String? category,
  }) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return false;

      final payload = <String, dynamic>{
        'role_id': roleId,
        'title': title,
        if (description != null && description.isNotEmpty) 'description': description,
        'steps': steps.map((s) => s.toJson()).toList(),
        'version': 1,
        'is_latest': true,
        if (category != null && category.isNotEmpty) 'category': category,
      };

      await _service.createSop(token, payload);
      await fetchSops(roleId: scopedRoleId);

      if (context.mounted) {
        Get.snackbar('Success', 'SOP created',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade50,
            colorText: Colors.green.shade800);
      }
      return true;
    } catch (e) {
      log('RoleSopController.createSop error: $e');
      if (context.mounted) {
        Get.snackbar('Error', 'Failed to create SOP: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade50,
            colorText: Colors.red.shade800);
      }
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> updateSop(
    BuildContext context, {
    required int id,
    String? title,
    String? description,
    List<SopStep>? steps,
    int? version,
    bool? isLatest,
    String? category,
  }) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return false;

      final payload = <String, dynamic>{};
      if (title != null) payload['title'] = title;
      if (description != null) payload['description'] = description;
      if (steps != null) payload['steps'] = steps.map((s) => s.toJson()).toList();
      if (version != null) payload['version'] = version;
      if (isLatest != null) payload['is_latest'] = isLatest;
      if (category != null) payload['category'] = category;

      await _service.updateSop(token, id, payload);
      await fetchSops(roleId: scopedRoleId);

      if (context.mounted) {
        Get.snackbar('Success', 'SOP updated',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade50,
            colorText: Colors.green.shade800);
      }
      return true;
    } catch (e) {
      log('RoleSopController.updateSop error: $e');
      if (context.mounted) {
        Get.snackbar('Error', 'Failed to update SOP: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade50,
            colorText: Colors.red.shade800);
      }
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deleteSop(BuildContext context, int id) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      await _service.deleteSop(token, id);
      await fetchSops(roleId: scopedRoleId);

      if (context.mounted) {
        Get.snackbar('Success', 'SOP deleted',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade50,
            colorText: Colors.green.shade800);
      }
      return true;
    } catch (e) {
      log('RoleSopController.deleteSop error: $e');
      if (context.mounted) {
        Get.snackbar('Error', 'Failed to delete SOP: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade50,
            colorText: Colors.red.shade800);
      }
      return false;
    }
  }
}
