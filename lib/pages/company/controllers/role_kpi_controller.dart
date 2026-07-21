import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../../../src/model/role_kpi_model.dart';
import '../../../src/services/role_kpi_service.dart';
import '../../../src/services/role_service.dart';

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

  String _friendlyError(dynamic e) {
    final msg = e.toString();
    if (msg.contains('403') || msg.contains('permission')) {
      return 'You do not have permission to perform this action.';
    }
    if (msg.contains('422')) return 'Invalid data. Please check your inputs.';
    if (msg.contains('404')) return 'Resource not found.';
    if (msg.contains('500')) return 'Server error. Please try again later.';
    if (msg.contains('DioException')) return 'Network error. Check your connection.';
    // Strip "Exception: API Error: 4xx - " prefix for cleaner display
    final cleaned = msg.replaceFirst(RegExp(r'^Exception:\s*API Error:\s*\d+\s*-\s*'), '');
    return cleaned.length > 120 ? '${cleaned.substring(0, 120)}...' : cleaned;
  }

  // ignore: prefer_const_constructors
  static final _errorBg = Color(0xFFFEF2F2);
  // ignore: prefer_const_constructors
  static final _errorText = Color(0xFF991B1B);
  // ignore: prefer_const_constructors
  static final _successBg = Color(0xFFF0FDF4);
  // ignore: prefer_const_constructors
  static final _successText = Color(0xFF166534);
  static const _snackMargin = EdgeInsets.all(16);

  void _safeSnackbar(String title, String msg, {Color? bg, Color? fg}) {
    try {
      if (Get.context != null && !Get.isSnackbarOpen) {
        Get.snackbar(title, msg,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: bg ?? _successBg,
            colorText: fg ?? _successText,
            margin: _snackMargin,
            duration: const Duration(seconds: 3));
      }
    } catch (_) {}
  }

  void _showError(String msg) {
    _safeSnackbar('Error', msg, bg: _errorBg, fg: _errorText);
  }

  void _showSuccess(String msg) {
    _safeSnackbar('Success', msg);
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

  Future<bool> createKpi({
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
      await fetchKpis(refresh: true, roleId: roleId);
      _showSuccess('KPI created successfully');
      return true;
    } catch (e) {
      log('RoleKpiController.createKpi error: $e');
      _showError(_friendlyError(e));
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> updateKpi({
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
      await fetchKpis(refresh: true, roleId: rId);
      _showSuccess('KPI updated successfully');
      return true;
    } catch (e) {
      log('RoleKpiController.updateKpi error: $e');
      _showError(_friendlyError(e));
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deleteKpi(int id) async {
    try {
      final token = await _getToken();
      if (token == null) return false;
      final rId = scopedRoleId;
      if (rId == null) return false;
      await _service.deleteRoleKpi(token, rId, id);
      await fetchKpis(refresh: true, roleId: rId);
      _showSuccess('KPI deleted');
      return true;
    } catch (e) {
      log('RoleKpiController.deleteKpi error: $e');
      _showError(_friendlyError(e));
      return false;
    }
  }

  /// Fetch KPIs from ALL roles for the management page.
  Future<void> fetchAllKpis({bool refresh = false}) async {
    if (!refresh) isLoading.value = true;
    try {
      final token = await _getToken();
      if (token == null) return;

      // Get all roles first
      final rolesService = RoleService();
      final rolesResult = await rolesService.listRoles(token, limit: 100);
      final allKpis = <RoleKpi>[];
      for (final role in rolesResult.list) {
        try {
          final result = await _service.listRoleKpis(token, roleId: role.id, limit: 100, offset: 0);
          allKpis.addAll(result.list);
        } catch (_) {}
      }
      kpis.assignAll(allKpis);
      totalCount = allKpis.length;
    } catch (e) {
      log('RoleKpiController.fetchAllKpis error: $e');
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
