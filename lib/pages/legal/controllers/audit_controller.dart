import 'dart:developer';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../src/services/legal/audit_service.dart';
import '../models/audit_model.dart';

class AuditController extends GetxController {
  final AuditService _service = AuditService();
  final _storage = const FlutterSecureStorage();

  // ─── Loading state ────────────────────────────────────────────────
  var isLoading = true.obs;
  var isSaving = false.obs;

  // ─── Audit list ─────────────────────────────────────────────────
  var auditList = <Audit>[].obs;
  var searchQuery = ''.obs;
  var currentPage = 1.obs;
  var limit = 10.obs;
  var totalItems = 0.obs;

  // ─── Statistics ─────────────────────────────────────────────────
  var statistics = Rxn<AuditStatistics>();

  // ─── Filters ──────────────────────────────────────────────────────
  var selectedAuditType = ''.obs;
  var selectedStatus = ''.obs;
  var selectedDepartment = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAudits();
  }

  // ─── FETCH ────────────────────────────────────────────────────────

  Future<void> fetchAudits({bool refresh = false}) async {
    try {
      if (!refresh) isLoading.value = true;

      final token = await _getToken();
      if (token == null) return;

      final offset = (currentPage.value - 1) * limit.value;

      final result = await _service.getAudits(
        token,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        auditType:
            selectedAuditType.value.isNotEmpty ? selectedAuditType.value : null,
        status: selectedStatus.value.isNotEmpty ? selectedStatus.value : null,
        department: selectedDepartment.value.isNotEmpty
            ? selectedDepartment.value
            : null,
        limit: limit.value,
        offset: offset,
      );

      auditList.assignAll(result.items);
      totalItems.value = result.total;
    } catch (e) {
      log("Error fetching audits: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ─── CREATE ───────────────────────────────────────────────────────

  Future<void> createAudit(
      BuildContext context, Map<String, dynamic> data) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return;

      log("Create Audit payload: $data");
      await _service.createAudit(token, data);

      if (context.mounted) {
        Navigator.pop(context);
        fetchAudits(refresh: true);
        _showSnackBar(context, "Audit created successfully");
      }
    } catch (e) {
      log("Create Audit Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to create audit: ${e.toString()}");
      }
    } finally {
      isSaving.value = false;
    }
  }

  // ─── UPDATE ───────────────────────────────────────────────────────

  Future<void> updateAudit(
      BuildContext context, int id, Map<String, dynamic> data) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return;

      log("Update Audit payload: $data");
      await _service.updateAudit(token, id, data);

      if (context.mounted) {
        Navigator.pop(context);
        fetchAudits(refresh: true);
        _showSnackBar(context, "Audit updated successfully");
      }
    } catch (e) {
      log("Update Audit Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to update audit");
      }
    } finally {
      isSaving.value = false;
    }
  }

  // ─── DELETE ───────────────────────────────────────────────────────

  Future<void> deleteAudit(BuildContext context, int id) async {
    try {
      final token = await _getToken();
      if (token == null) return;

      await _service.deleteAudit(token, id);

      if (context.mounted) {
        fetchAudits(refresh: true);
        _showSnackBar(context, "Audit deleted successfully");
      }
    } catch (e) {
      log("Delete Audit Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to delete audit");
      }
    }
  }

  // ─── UPDATE STATUS ────────────────────────────────────────────────

  Future<void> updateAuditStatus(
      BuildContext context, int id, String status) async {
    try {
      final token = await _getToken();
      if (token == null) return;

      await _service.updateAuditStatus(token, id, status);

      if (context.mounted) {
        fetchAudits(refresh: true);
        _showSnackBar(context, "Audit status updated successfully");
      }
    } catch (e) {
      log("Update Audit Status Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to update audit status");
      }
    }
  }

  // ─── UPDATE SCORE ─────────────────────────────────────────────────

  Future<void> updateAuditScore(BuildContext context, int id, int score) async {
    try {
      final token = await _getToken();
      if (token == null) return;

      await _service.updateAuditScore(token, id, score);

      if (context.mounted) {
        fetchAudits(refresh: true);
        _showSnackBar(context, "Audit score updated successfully");
      }
    } catch (e) {
      log("Update Audit Score Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to update audit score");
      }
    }
  }

  // ─── STATISTICS ───────────────────────────────────────────────────

  Future<void> fetchStatistics() async {
    try {
      final token = await _getToken();
      if (token == null) return;

      statistics.value = await _service.getStatistics(token);
    } catch (e) {
      log("Error fetching audit statistics: $e");
    }
  }

  // ─── SEARCH / FILTER ─────────────────────────────────────────────

  void onSearchChanged(String val) {
    searchQuery.value = val;
    currentPage.value = 1;
    fetchAudits();
  }

  void onFilterChanged() {
    currentPage.value = 1;
    fetchAudits();
  }

  // ─── PAGINATION ──────────────────────────────────────────────────

  void goToPage(int page) {
    currentPage.value = page;
    fetchAudits();
  }

  void setLimit(int newLimit) {
    limit.value = newLimit;
    currentPage.value = 1;
    fetchAudits();
  }

  // ─── HELPERS ─────────────────────────────────────────────────────

  Future<String?> _getToken() async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith("Bearer ")) {
      token = token.replaceFirst("Bearer ", "");
    }
    return token.replaceAll('"', '').trim();
  }

  void _showSnackBar(BuildContext context, String message) {
    AppToast.success(context, message);
  }

  void _showErrorDialog(BuildContext context, String message) {
    DialogScaffold.show(
      context,
      title: "Error",
      size: DialogSize.sm,
      body: Text(message),
      actions: [TextButton(
              onPressed: () => Navigator.pop(context), child: const Text("OK")),],
    );
  }
}
