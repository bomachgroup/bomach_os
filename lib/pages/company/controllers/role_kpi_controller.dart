import 'dart:async';
import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../../../src/model/role_kpi_model.dart';
import '../../../src/services/role_kpi_service.dart';

class KpiActionResult {
  final bool succeeded;
  final String message;
  final int? statusCode;

  const KpiActionResult.success(this.message)
      : succeeded = true,
        statusCode = null;

  const KpiActionResult.failure(this.message, {this.statusCode})
      : succeeded = false;
}

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
  var isRefreshing = false.obs;
  var isSaving = false.obs;
  var errorMessage = ''.obs;

  int limit = 100;
  int offset = 0;
  int totalCount = 0;
  String? _lastSearch;
  int _roleKpisRequestId = 0;
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

  int? _statusCode(dynamic error) {
    final match = RegExp(r'API Error:\s*(\d+)').firstMatch(error.toString());
    return match == null ? null : int.tryParse(match.group(1)!);
  }

  KpiActionResult _actionFailure(dynamic error) => KpiActionResult.failure(
        _friendlyError(error),
        statusCode: _statusCode(error),
      );

  void _refreshVisibleList() {
    if (scopedRoleId == null) {
      unawaited(fetchAllKpis(search: _lastSearch, background: true));
    } else {
      unawaited(fetchKpis(roleId: scopedRoleId, background: true));
    }
  }

  void _insertCreatedKpi(RoleKpi created, int roleId) {
    if (created.id == null) return;
    if (scopedRoleId != null && scopedRoleId != roleId) return;
    if (scopedRoleId == null && (_lastSearch?.trim().isNotEmpty ?? false)) {
      return;
    }
    if (offset != 0) return;
    final alreadyPresent = kpis.any((item) => item.id == created.id);
    kpis.removeWhere((item) => item.id == created.id);
    kpis.insert(0, created);
    if (!alreadyPresent) {
      totalCount += 1;
      if (kpis.length > limit) kpis.removeLast();
    }
  }

  void _replaceKpi(RoleKpi updated) {
    final index = kpis.indexWhere((item) => item.id == updated.id);
    if (index >= 0) kpis[index] = updated;
  }

  /// Loads every assignment for a role without replacing the visible KPI list.
  Future<({List<RoleKpi> list, String? error})> loadRoleAssignments(
      int roleId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return (
          list: <RoleKpi>[],
          error: 'Authentication required. Sign in again.'
        );
      }
      final assignments = <RoleKpi>[];
      var nextOffset = 0;
      var count = 0;
      do {
        final page = await _service.listRoleKpis(
          token,
          roleId: roleId,
          limit: 100,
          offset: nextOffset,
        );
        assignments.addAll(page.list);
        count = page.count;
        if (page.list.isEmpty) break;
        nextOffset += page.list.length;
      } while (nextOffset < count);
      return (list: assignments, error: null);
    } catch (error) {
      return (list: <RoleKpi>[], error: _friendlyError(error));
    }
  }

  Future<void> fetchKpis({
    bool refresh = false,
    bool background = false,
    int? roleId,
  }) async {
    if (refresh) offset = 0;
    final requestId = ++_roleKpisRequestId;
    final hasVisibleRows = kpis.isNotEmpty;
    isLoading.value = !background && !hasVisibleRows;
    isRefreshing.value = background || hasVisibleRows;
    errorMessage.value = '';
    try {
      final token = await _getToken();
      if (token == null) {
        if (requestId == _roleKpisRequestId) {
          errorMessage.value = 'Authentication required. Sign in again.';
        }
        return;
      }
      final rId = roleId ?? scopedRoleId;
      if (rId == null) {
        if (requestId == _roleKpisRequestId) {
          errorMessage.value = 'Select a role to load its KPIs.';
        }
        return;
      }
      final result = await _service.listRoleKpis(token,
          roleId: rId, limit: limit, offset: offset);
      if (requestId != _roleKpisRequestId) return;
      if (refresh || offset == 0) {
        kpis.assignAll(result.list);
      } else {
        kpis.addAll(result.list);
      }
      totalCount = result.count;
    } catch (e) {
      log('RoleKpiController.fetchKpis error: $e');
      if (requestId == _roleKpisRequestId) {
        errorMessage.value = _friendlyError(e);
      }
    } finally {
      if (requestId == _roleKpisRequestId) {
        isLoading.value = false;
        isRefreshing.value = false;
      }
    }
  }

  Future<KpiActionResult> createKpi({
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
      if (token == null) {
        return const KpiActionResult.failure(
            'Authentication required. Sign in again.');
      }
      final payload = <String, dynamic>{
        'metric_id': metricId,
        'tracking_mode': trackingMode,
        'period': period,
        'is_active': isActive,
      };
      if (targetValue != null) payload['target_value'] = targetValue;
      if (weight != null) payload['weight'] = weight;
      if (sequence != null) payload['sequence'] = sequence;

      final created = await _service.createRoleKpi(token, roleId, payload);
      _insertCreatedKpi(created, roleId);
      _refreshVisibleList();
      return const KpiActionResult.success('KPI added to the role.');
    } catch (e) {
      log('RoleKpiController.createKpi error: $e');
      return _actionFailure(e);
    } finally {
      isSaving.value = false;
    }
  }

  Future<KpiActionResult> updateKpi({
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
      if (token == null) {
        return const KpiActionResult.failure(
            'Authentication required. Sign in again.');
      }
      final payload = <String, dynamic>{
        'metric_id': metricId,
        'target_value': targetValue,
        'weight': weight,
      };
      if (trackingMode != null) payload['tracking_mode'] = trackingMode;
      if (period != null) payload['period'] = period;
      if (sequence != null) payload['sequence'] = sequence;
      if (isActive != null) payload['is_active'] = isActive;

      final updated = await _service.updateRoleKpi(token, roleId, id, payload);
      _replaceKpi(updated);
      _refreshVisibleList();
      return const KpiActionResult.success('KPI updated.');
    } catch (e) {
      log('RoleKpiController.updateKpi error: $e');
      return _actionFailure(e);
    } finally {
      isSaving.value = false;
    }
  }

  Future<KpiActionResult> deleteKpi(
      {required int roleId, required int id}) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) {
        return const KpiActionResult.failure(
            'Authentication required. Sign in again.');
      }
      await _service.deleteRoleKpi(token, roleId, id);
      final previousLength = kpis.length;
      kpis.removeWhere((item) => item.id == id);
      final removed = kpis.length != previousLength;
      if (removed) {
        totalCount = (totalCount - 1).clamp(0, totalCount).toInt();
        final lastOffset =
            totalCount == 0 ? 0 : ((totalCount - 1) ~/ limit) * limit;
        if (offset > lastOffset) offset = lastOffset;
      }
      _refreshVisibleList();
      return const KpiActionResult.success('KPI removed from the role.');
    } catch (e) {
      log('RoleKpiController.deleteKpi error: $e');
      return _actionFailure(e);
    } finally {
      isSaving.value = false;
    }
  }

  /// Fetch KPIs from ALL roles for the management page.
  Future<void> fetchAllKpis({
    bool refresh = false,
    bool background = false,
    String? search,
  }) async {
    if (refresh) offset = 0;
    _lastSearch = search ?? _lastSearch;
    final requestId = ++_allKpisRequestId;
    final hasVisibleRows = kpis.isNotEmpty;
    isLoading.value = !background && !hasVisibleRows;
    isRefreshing.value = background || hasVisibleRows;
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
      if (requestId == _allKpisRequestId) {
        isLoading.value = false;
        isRefreshing.value = false;
      }
    }
  }

  Future<void> setAllKpisPage(int page) async {
    final lastPage = totalCount == 0 ? 0 : (totalCount - 1) ~/ limit;
    final safePage = page.clamp(0, lastPage).toInt();
    offset = safePage * limit;
    await fetchAllKpis(search: _lastSearch);
  }
}
