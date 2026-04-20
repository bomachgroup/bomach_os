import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import 'package:bms_front_end/pages/hr/models/workspace_model.dart';
import 'package:bms_front_end/src/services/biometric_api_service.dart';

/// Admin-facing controller for the Workspace Approvals page.
///
/// Scope is narrow: list every pending submission, approve one (optionally
/// overriding the radius), reject one (with a required reason), or force
/// delete. Each mutation refreshes the list so the table reflects server
/// truth. We deliberately do NOT keep a parallel RxList of approved/rejected
/// submissions — the backend's `/pending` endpoint is the authoritative
/// view for this page and trying to merge historical state locally is a
/// footgun.
class WorkspaceApprovalsController extends GetxController {
  final BiometricApiService _api = BiometricApiService();
  final _storage = const FlutterSecureStorage();

  final isLoading = false.obs;
  final isMutating = false.obs;
  final errorMessage = ''.obs;
  final successMessage = ''.obs;

  /// Every pending submission across the org. Reset on every [fetchPending].
  final pending = <WorkspaceConfig>[].obs;

  /// Free-text search across workspace name + employee name.
  final searchQuery = ''.obs;

  List<WorkspaceConfig> get filteredPending {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return pending;
    return pending.where((w) {
      return w.workspaceName.toLowerCase().contains(q) ||
          (w.employeeName ?? '').toLowerCase().contains(q) ||
          (w.branchName ?? '').toLowerCase().contains(q);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchPending();
  }

  Future<String?> _getToken() async {
    String? t = await _storage.read(key: 'access_token');
    if (t == null) return null;
    if (t.startsWith('Bearer ')) t = t.replaceFirst('Bearer ', '');
    return t.replaceAll('"', '').trim();
  }

  Future<void> fetchPending() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final token = await _getToken();
      if (token == null) {
        errorMessage.value = 'Not authenticated.';
        return;
      }
      final raw = await _api.getPendingWorkspaces(token);
      pending.assignAll(
        raw.map((e) => WorkspaceConfig.fromJson(e)).toList(),
      );
    } catch (e) {
      log('Fetch pending workspaces error: $e');
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      pending.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// Approve a pending submission. [allowedRadiusMeters] is optional — when
  /// null, the backend keeps whatever radius is on the record (the UI will
  /// pre-fill with 100 as the suggested default).
  Future<bool> approve(int locationId, {int? allowedRadiusMeters}) async {
    try {
      isMutating.value = true;
      errorMessage.value = '';
      final token = await _getToken();
      if (token == null) {
        errorMessage.value = 'Not authenticated.';
        return false;
      }
      await _api.approveWorkspace(
        token,
        locationId,
        allowedRadiusMeters: allowedRadiusMeters,
      );
      successMessage.value = 'Workspace approved.';
      // Pending list shrinks by one — drop locally AND refetch so the page
      // reflects concurrent admin activity too.
      pending.removeWhere((w) => w.id == locationId);
      await fetchPending();
      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isMutating.value = false;
    }
  }

  /// Reject a pending submission. [reason] is required by the backend.
  Future<bool> reject(int locationId, {required String reason}) async {
    if (reason.trim().isEmpty) {
      errorMessage.value = 'A rejection reason is required.';
      return false;
    }
    try {
      isMutating.value = true;
      errorMessage.value = '';
      final token = await _getToken();
      if (token == null) {
        errorMessage.value = 'Not authenticated.';
        return false;
      }
      await _api.rejectWorkspace(token, locationId, reason: reason.trim());
      successMessage.value = 'Workspace rejected.';
      pending.removeWhere((w) => w.id == locationId);
      await fetchPending();
      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isMutating.value = false;
    }
  }

  /// Admin force-delete. Works for any status and any owner. Used here only
  /// if an admin wants to clear a pending row without routing a decision.
  Future<bool> forceDelete(int locationId) async {
    try {
      isMutating.value = true;
      errorMessage.value = '';
      final token = await _getToken();
      if (token == null) {
        errorMessage.value = 'Not authenticated.';
        return false;
      }
      await _api.adminForceDeleteWorkspace(token, locationId);
      successMessage.value = 'Workspace deleted.';
      pending.removeWhere((w) => w.id == locationId);
      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isMutating.value = false;
    }
  }
}
