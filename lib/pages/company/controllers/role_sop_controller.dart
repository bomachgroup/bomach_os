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
  var availableSops = <Map<String, dynamic>>[].obs;
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
      final rId = roleId ?? scopedRoleId;
      if (rId == null) return;

      final result = await _service.listSops(
        token,
        roleId: rId,
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

  Future<void> fetchAvailableSops({int? deptId}) async {
    try {
      final token = await _getToken();
      if (token == null) return;
      final list = await _service.fetchAvailableSops(token, deptId: deptId);
      availableSops.assignAll(list);
    } catch (e) {
      log('RoleSopController.fetchAvailableSops error: $e');
    }
  }

  Future<bool> attachSop(
    BuildContext context, {
    required int roleId,
    required int sopId,
    bool isActive = true,
  }) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return false;

      await _service.attachSopToRole(token, roleId, sopId, isActive: isActive);
      await fetchSops(roleId: scopedRoleId);

      if (context.mounted) {
        Get.snackbar('Success', 'SOP linked to role',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade50,
            colorText: Colors.green.shade800);
      }
      return true;
    } catch (e) {
      log('RoleSopController.attachSop error: $e');
      if (context.mounted) {
        Get.snackbar('Error', 'Failed to link SOP: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade50,
            colorText: Colors.red.shade800);
      }
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> updateRoleSop(
    BuildContext context, {
    required int roleSopId,
    int? sopId,
    bool? isActive,
  }) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return false;

      final rId = scopedRoleId;
      if (rId == null) return false;

      await _service.updateRoleSop(token, rId, roleSopId,
          sopId: sopId, isActive: isActive);
      await fetchSops(roleId: scopedRoleId);

      if (context.mounted) {
        Get.snackbar('Success', 'SOP link updated',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade50,
            colorText: Colors.green.shade800);
      }
      return true;
    } catch (e) {
      log('RoleSopController.updateRoleSop error: $e');
      if (context.mounted) {
        Get.snackbar('Error', 'Failed to update SOP link: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade50,
            colorText: Colors.red.shade800);
      }
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deleteSop(BuildContext context, int roleSopId) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      final rId = scopedRoleId;
      if (rId == null) return false;
      await _service.deleteRoleSop(token, rId, roleSopId);
      await fetchSops(roleId: scopedRoleId);

      if (context.mounted) {
        Get.snackbar('Success', 'SOP removed from role',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade50,
            colorText: Colors.green.shade800);
      }
      return true;
    } catch (e) {
      log('RoleSopController.deleteSop error: $e');
      if (context.mounted) {
        Get.snackbar('Error', 'Failed to remove SOP: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade50,
            colorText: Colors.red.shade800);
      }
      return false;
    }
  }
}
