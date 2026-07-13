import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../../../src/model/role_okr_model.dart';
import '../../../src/services/role_okr_service.dart';

class RoleOkrController extends GetxController {
  final RoleOkrService _service = RoleOkrService();
  final _storage = const FlutterSecureStorage();

  var okrs = <RoleOkr>[].obs;
  var isLoading = false.obs;
  var isSaving = false.obs;
  var errorMessage = ''.obs;

  int limit = 100;
  int offset = 0;
  int totalCount = 0;

  /// Optional scoping — set before fetch to filter by role.
  int? scopedRoleId;
  int? filterQuarter;
  int? filterYear;
  String filterStatus = '';

  @override
  void onInit() {
    super.onInit();
    fetchOkrs();
  }

  Future<String?> _getToken() async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith('Bearer ')) token = token.substring(7);
    return token.replaceAll('"', '').trim();
  }

  Future<void> fetchOkrs({bool refresh = false, int? roleId}) async {
    if (refresh) offset = 0;
    if (!refresh) isLoading.value = true;

    try {
      final token = await _getToken();
      if (token == null) return;

      final result = await _service.listRoleOkrs(
        token,
        roleId: roleId ?? scopedRoleId,
        quarter: filterQuarter,
        year: filterYear,
        status: filterStatus.isNotEmpty ? filterStatus : null,
        limit: limit,
        offset: offset,
      );

      if (refresh || offset == 0) {
        okrs.assignAll(result.list);
      } else {
        okrs.addAll(result.list);
      }
      totalCount = result.count;
    } catch (e) {
      log('RoleOkrController.fetchOkrs error: $e');
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createOkr(
    BuildContext context, {
    required int roleId,
    required String objective,
    required int quarter,
    required int year,
    String? description,
    String status = 'active',
    List<Map<String, dynamic>> keyResults = const [],
  }) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return false;

      final payload = <String, dynamic>{
        'role_id': roleId,
        'objective': objective,
        'quarter': quarter,
        'year': year,
        if (description != null && description.isNotEmpty)
          'description': description,
        'status': status,
        if (keyResults.isNotEmpty) 'key_results': keyResults,
      };

      await _service.createRoleOkr(token, payload);
      await fetchOkrs(refresh: true, roleId: scopedRoleId);

      if (context.mounted) {
        Get.snackbar('Success', 'OKR created successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade50,
            colorText: Colors.green.shade800);
      }
      return true;
    } catch (e) {
      log('RoleOkrController.createOkr error: $e');
      if (context.mounted) {
        Get.snackbar('Error', 'Failed to create OKR: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade50,
            colorText: Colors.red.shade800);
      }
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> updateOkr(
    BuildContext context, {
    required int id,
    String? objective,
    String? description,
    int? quarter,
    int? year,
    String? status,
  }) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return false;

      final payload = <String, dynamic>{};
      if (objective != null) payload['objective'] = objective;
      if (description != null) payload['description'] = description;
      if (quarter != null) payload['quarter'] = quarter;
      if (year != null) payload['year'] = year;
      if (status != null) payload['status'] = status;

      await _service.updateRoleOkr(token, id, payload);
      await fetchOkrs(refresh: true, roleId: scopedRoleId);

      if (context.mounted) {
        Get.snackbar('Success', 'OKR updated successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade50,
            colorText: Colors.green.shade800);
      }
      return true;
    } catch (e) {
      log('RoleOkrController.updateOkr error: $e');
      if (context.mounted) {
        Get.snackbar('Error', 'Failed to update OKR: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade50,
            colorText: Colors.red.shade800);
      }
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deleteOkr(BuildContext context, int id) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      await _service.deleteRoleOkr(token, id);
      await fetchOkrs(refresh: true, roleId: scopedRoleId);

      if (context.mounted) {
        Get.snackbar('Success', 'OKR deleted',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade50,
            colorText: Colors.green.shade800);
      }
      return true;
    } catch (e) {
      log('RoleOkrController.deleteOkr error: $e');
      if (context.mounted) {
        Get.snackbar('Error', 'Failed to delete OKR: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade50,
            colorText: Colors.red.shade800);
      }
      return false;
    }
  }
}
