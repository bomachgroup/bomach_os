import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import 'package:bomach_os/pages/hr/models/workspace_model.dart';
import 'package:bomach_os/src/services/biometric_api_service.dart';

/// Which slice of submissions the admin is looking at.
///
/// `pending` hits `GET /biometric/location/pending` and only lists rows
/// still awaiting a decision.
///
/// Every other value hits the broad `GET /biometric/location/whitelisted`
/// endpoint — which returns *all* locations when the caller has the admin
/// `list` permission — and filters in-memory. The broad endpoint is the
/// only way to see already-approved or rejected rows org-wide today.
enum ApprovalsView { pending, approved, rejected, all }

extension ApprovalsViewX on ApprovalsView {
  String get label {
    switch (this) {
      case ApprovalsView.pending:
        return 'Pending';
      case ApprovalsView.approved:
        return 'Approved';
      case ApprovalsView.rejected:
        return 'Rejected';
      case ApprovalsView.all:
        return 'All';
    }
  }
}

/// Admin-facing controller for the Workspace Approvals page.
///
/// Holds one source of truth ([submissions]) for whatever slice the admin
/// is currently viewing. Each mutation refreshes the list so the table
/// reflects server truth after approve/reject/update/delete.
class WorkspaceApprovalsController extends GetxController {
  final BiometricApiService _api = BiometricApiService();
  final _storage = const FlutterSecureStorage();

  final isLoading = false.obs;
  final isMutating = false.obs;
  final errorMessage = ''.obs;
  final successMessage = ''.obs;

  /// Current filter — switches the endpoint we hit on the next fetch.
  final view = ApprovalsView.pending.obs;

  /// Submissions matching the current [view]. Pending view = backend's
  /// pending endpoint; every other view filters the broad admin list.
  final submissions = <WorkspaceConfig>[].obs;

  /// Free-text search across workspace name + employee + branch.
  final searchQuery = ''.obs;

  List<WorkspaceConfig> get filtered {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return submissions;
    return submissions.where((w) {
      return w.workspaceName.toLowerCase().contains(q) ||
          (w.employeeName ?? '').toLowerCase().contains(q) ||
          (w.branchName ?? '').toLowerCase().contains(q);
    }).toList();
  }

  /// Counts for the tab badges — computed off the pending endpoint only
  /// for the pending count (cheapest, most accurate), and off the broad
  /// endpoint for approved/rejected when it's already loaded.
  int get pendingCountInView => submissions
      .where((w) => w.status == WorkspaceStatus.pending)
      .length;

  @override
  void onInit() {
    super.onInit();
    fetch();
  }

  Future<String?> _getToken() async {
    String? t = await _storage.read(key: 'access_token');
    if (t == null) return null;
    if (t.startsWith('Bearer ')) t = t.replaceFirst('Bearer ', '');
    return t.replaceAll('"', '').trim();
  }

  /// Switch view and refetch. Safe to call with the same value — behaves
  /// like a refresh.
  Future<void> setView(ApprovalsView v) async {
    view.value = v;
    await fetch();
  }

  Future<void> fetch() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final token = await _getToken();
      if (token == null) {
        errorMessage.value = 'Not authenticated.';
        return;
      }

      final raw = view.value == ApprovalsView.pending
          ? await _api.getPendingWorkspaces(token)
          : await _api.getWorkspaces(token);

      final parsed =
          raw.map((e) => WorkspaceConfig.fromJson(e)).toList();

      // Filter the broad list in-memory to the selected slice.
      final filtered = switch (view.value) {
        ApprovalsView.pending => parsed,
        ApprovalsView.approved =>
          parsed.where((w) => w.status == WorkspaceStatus.approved).toList(),
        ApprovalsView.rejected =>
          parsed.where((w) => w.status == WorkspaceStatus.rejected).toList(),
        ApprovalsView.all => parsed,
      };

      submissions.assignAll(filtered);
    } catch (e) {
      log('Fetch workspaces (${view.value}) error: $e');
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      submissions.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // ── Mutations ──────────────────────────────────────────────────────

  /// Approve a pending submission. [allowedRadiusMeters] is optional —
  /// when null, the backend keeps whatever radius is on the record.
  Future<bool> approve(int locationId, {int? allowedRadiusMeters}) async {
    return _run(() async {
      final token = await _requireToken();
      await _api.approveWorkspace(
        token,
        locationId,
        allowedRadiusMeters: allowedRadiusMeters,
      );
      successMessage.value = 'Workspace approved.';
    });
  }

  /// Reject a pending submission. Reason is required by the backend.
  Future<bool> reject(int locationId, {required String reason}) async {
    if (reason.trim().isEmpty) {
      errorMessage.value = 'A rejection reason is required.';
      return false;
    }
    return _run(() async {
      final token = await _requireToken();
      await _api.rejectWorkspace(token, locationId, reason: reason.trim());
      successMessage.value = 'Workspace rejected.';
    });
  }

  /// Admin edit of an already-existing location. Only non-null fields are
  /// sent. Used to fix radius mistakes, extend expiry, or deactivate a
  /// site without deleting history.
  ///
  /// Named `adminUpdate` (not `update`) because `GetxController` already
  /// defines a no-arg `update()` method.
  Future<bool> adminUpdate(
    int locationId, {
    String? name,
    double? latitude,
    double? longitude,
    int? allowedRadiusMeters,
    bool? isActive,
    String? expiresAt,
    String? notes,
  }) async {
    return _run(() async {
      final token = await _requireToken();
      await _api.adminUpdateWorkspace(
        token,
        locationId,
        name: name,
        latitude: latitude,
        longitude: longitude,
        allowedRadiusMeters: allowedRadiusMeters,
        isActive: isActive,
        expiresAt: expiresAt,
        notes: notes,
      );
      successMessage.value = 'Workspace updated.';
    });
  }

  /// Admin force-delete. Works for any status and any owner.
  Future<bool> forceDelete(int locationId) async {
    return _run(() async {
      final token = await _requireToken();
      await _api.adminForceDeleteWorkspace(token, locationId);
      successMessage.value = 'Workspace deleted.';
    });
  }

  // ── Shared plumbing for mutations ──────────────────────────────────

  /// Wrap a mutation in the standard spinner + refetch cycle. Every
  /// approve/reject/update/delete pulls the list again so the admin always
  /// sees server truth — the alternative (local mutation only) drifts fast
  /// when two admins work at once.
  Future<bool> _run(Future<void> Function() body) async {
    try {
      isMutating.value = true;
      errorMessage.value = '';
      await body();
      await fetch();
      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isMutating.value = false;
    }
  }

  Future<String> _requireToken() async {
    final t = await _getToken();
    if (t == null) {
      throw Exception('Not authenticated.');
    }
    return t;
  }
}
