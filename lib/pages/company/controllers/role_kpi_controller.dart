import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../../../src/model/role_kpi_model.dart';
import '../../../src/services/role_kpi_service.dart';

class RoleKpiController extends GetxController {
  final RoleKpiService _service;
  final FlutterSecureStorage _storage;
  final Future<String?> Function()? _tokenReader;

  RoleKpiController({
    RoleKpiService? service,
    FlutterSecureStorage? storage,
    Future<String?> Function()? tokenReader,
  })  : _service = service ?? RoleKpiService(),
        _storage = storage ?? const FlutterSecureStorage(),
        _tokenReader = tokenReader;

  var kpis = <RoleKpi>[].obs;
  var isLoading = false.obs;
  var isSaving = false.obs;
  var errorMessage = ''.obs;

  int limit = 100;
  int offset = 0;
  int totalCount = 0;
  String? _lastSearch;
  int _allKpisRequestId = 0;

  int? scopedRoleId;

  Future<String?> _getToken() async {
    String? token = _tokenReader == null
        ? await _storage.read(key: 'access_token')
        : await _tokenReader();
    if (token == null) return null;
    if (token.startsWith('Bearer ')) token = token.substring(7);
    return token.replaceAll('"', '').trim();
  }

  String _friendlyError(dynamic e) {
    final msg = e.toString();
    if (msg.contains('403') || msg.contains('permission')) {
      return 'You do not have permission to perform this action.';
    }
    if (msg.contains('409')) {
      return msg.replaceFirst(
          RegExp(r'^Exception:\s*API Error:\s*409\s*-\s*'), '');
    }
    if (msg.contains('400') || msg.contains('422')) {
      return msg.replaceFirst(
          RegExp(r'^Exception:\s*API Error:\s*\d+\s*-\s*'), '');
    }
    if (msg.contains('404')) return 'Resource not found.';
    if (msg.contains('500')) return 'Server error. Please try again later.';
    if (msg.contains('DioException'))
      return 'Network error. Check your connection.';
    // Strip "Exception: API Error: 4xx - " prefix for cleaner display
    final cleaned =
        msg.replaceFirst(RegExp(r'^Exception:\s*API Error:\s*\d+\s*-\s*'), '');
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
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final token = await _getToken();
      if (token == null) {
        errorMessage.value = 'Authentication required. Sign in again.';
        return;
      }
      final rId = roleId ?? scopedRoleId;
      if (rId == null) {
        errorMessage.value = 'Select a role to load its KPIs.';
        return;
      }
      final result = await _service.listRoleKpis(token,
          roleId: rId, limit: limit, offset: offset);
      if (refresh || offset == 0) {
        kpis.assignAll(result.list);
      } else {
        kpis.addAll(result.list);
      }
      totalCount = result.count;
    } catch (e) {
      log('RoleKpiController.fetchKpis error: $e');
      errorMessage.value = _friendlyError(e);
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
    required int roleId,
    required int id,
    required int metricId,
    String? trackingMode,
    String? period,
    required double? targetValue,
    required double? weight,
    int? sequence,
    bool? isActive,
  }) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return false;
      final payload = <String, dynamic>{
        'metric_id': metricId,
        'target_value': targetValue,
        'weight': weight,
      };
      if (trackingMode != null) payload['tracking_mode'] = trackingMode;
      if (period != null) payload['period'] = period;
      if (sequence != null) payload['sequence'] = sequence;
      if (isActive != null) payload['is_active'] = isActive;

      await _service.updateRoleKpi(token, roleId, id, payload);
      if (scopedRoleId == null) {
        await fetchAllKpis(refresh: true, search: _lastSearch);
      } else {
        await fetchKpis(refresh: true, roleId: roleId);
      }
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

  Future<bool> deleteKpi({required int roleId, required int id}) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return false;
      await _service.deleteRoleKpi(token, roleId, id);
      if (scopedRoleId == null) {
        await fetchAllKpis(refresh: true, search: _lastSearch);
      } else {
        await fetchKpis(refresh: true, roleId: roleId);
      }
      _showSuccess('KPI deleted');
      return true;
    } catch (e) {
      log('RoleKpiController.deleteKpi error: $e');
      _showError(_friendlyError(e));
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Fetch KPIs from ALL roles for the management page.
  Future<void> fetchAllKpis({bool refresh = false, String? search}) async {
    if (refresh) offset = 0;
    _lastSearch = search ?? _lastSearch;
    final requestId = ++_allKpisRequestId;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final token = await _getToken();
      if (token == null) {
        if (requestId == _allKpisRequestId) {
          errorMessage.value = 'Authentication required. Sign in again.';
        }
        return;
      }
      final result = await _service.listAllRoleKpis(
        token,
        search: _lastSearch,
        limit: limit,
        offset: offset,
      );
      if (requestId != _allKpisRequestId) return;
      kpis.assignAll(result.list);
      totalCount = result.count;
    } catch (e) {
      log('RoleKpiController.fetchAllKpis error: $e');
      if (requestId == _allKpisRequestId) {
        errorMessage.value = _friendlyError(e);
      }
    } finally {
      if (requestId == _allKpisRequestId) isLoading.value = false;
    }
  }

  Future<void> setAllKpisPage(int page) async {
    final lastPage = totalCount == 0 ? 0 : (totalCount - 1) ~/ limit;
    final safePage = page.clamp(0, lastPage).toInt();
    offset = safePage * limit;
    await fetchAllKpis(search: _lastSearch);
  }
}
