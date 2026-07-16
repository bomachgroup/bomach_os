import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../../../src/model/role_kpi_model.dart';
import '../../../src/services/role_kpi_service.dart';

class RoleKpiController extends GetxController {
  final RoleKpiService _service = RoleKpiService();
  final _storage = const FlutterSecureStorage();

  var kpis = <RoleKpi>[].obs;
  var isLoading = false.obs;
  var isSaving = false.obs;
  var errorMessage = ''.obs;

  int limit = 100;
  int offset = 0;
  int totalCount = 0;

  int? scopedRoleId;

  @override
  void onInit() {
    super.onInit();
    fetchKpis();
  }

  Future<String?> _getToken() async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith('Bearer ')) token = token.substring(7);
    return token.replaceAll('"', '').trim();
  }

  Future<void> fetchKpis({bool refresh = false, int? roleId}) async {
    if (refresh) offset = 0;
    if (!refresh) isLoading.value = true;
    try {
      final token = await _getToken();
      if (token == null) return;
      final rId = roleId ?? scopedRoleId;
      if (rId == null) return;
      final result = await _service.listRoleKpis(token, roleId: rId, limit: limit, offset: offset);
      if (refresh || offset == 0) {
        kpis.assignAll(result.list);
      } else {
        kpis.addAll(result.list);
      }
      totalCount = result.count;
    } catch (e) {
      log('RoleKpiController.fetchKpis error: $e');
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createKpi(
    BuildContext context, {
    required int roleId,
    required int metricId,
    required String trackingMode,
    required String period,
    double? targetValue,
    double? weight,
    int? sequence,
    bool isActive = true,
  }) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return false;
      final payload = <String, dynamic>{
        'metric_id': metricId,
        'tracking_mode': trackingMode,
        'period': period,
        'is_active': isActive,
      };
      if (targetValue != null) payload['target_value'] = targetValue;
      if (weight != null) payload['weight'] = weight;
      if (sequence != null) payload['sequence'] = sequence;

      await _service.createRoleKpi(token, roleId, payload);
      await fetchKpis(refresh: true, roleId: scopedRoleId);

      if (context.mounted) {
        Get.snackbar('Success', 'KPI created successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade50,
            colorText: Colors.green.shade800);
      }
      return true;
    } catch (e) {
      log('RoleKpiController.createKpi error: $e');
      if (context.mounted) {
        Get.snackbar('Error', 'Failed to create KPI: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade50,
            colorText: Colors.red.shade800);
      }
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> updateKpi(
    BuildContext context, {
    required int id,
    String? trackingMode,
    String? period,
    double? targetValue,
    double? weight,
    int? sequence,
    bool? isActive,
  }) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return false;
      final payload = <String, dynamic>{};
      if (trackingMode != null) payload['tracking_mode'] = trackingMode;
      if (period != null) payload['period'] = period;
      if (targetValue != null) payload['target_value'] = targetValue;
      if (weight != null) payload['weight'] = weight;
      if (sequence != null) payload['sequence'] = sequence;
      if (isActive != null) payload['is_active'] = isActive;

      final rId = scopedRoleId;
      if (rId == null) return false;
      await _service.updateRoleKpi(token, rId, id, payload);
      await fetchKpis(refresh: true, roleId: scopedRoleId);

      if (context.mounted) {
        Get.snackbar('Success', 'KPI updated successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade50,
            colorText: Colors.green.shade800);
      }
      return true;
    } catch (e) {
      log('RoleKpiController.updateKpi error: $e');
      if (context.mounted) {
        Get.snackbar('Error', 'Failed to update KPI: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade50,
            colorText: Colors.red.shade800);
      }
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deleteKpi(BuildContext context, int id) async {
    try {
      final token = await _getToken();
      if (token == null) return false;
      final rId = scopedRoleId;
      if (rId == null) return false;
      await _service.deleteRoleKpi(token, rId, id);
      await fetchKpis(refresh: true, roleId: scopedRoleId);
      if (context.mounted) {
        Get.snackbar('Success', 'KPI deleted',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade50,
            colorText: Colors.green.shade800);
      }
      return true;
    } catch (e) {
      log('RoleKpiController.deleteKpi error: $e');
      if (context.mounted) {
        Get.snackbar('Error', 'Failed to delete KPI: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade50,
            colorText: Colors.red.shade800);
      }
      return false;
    }
  }
}
