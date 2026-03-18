import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../src/services/legal/legal_case_service.dart';
import '../models/legal_case_model.dart';

class LegalCaseController extends GetxController {
  final LegalCaseService _service = LegalCaseService();
  final _storage = const FlutterSecureStorage();

  // ─── Loading state ────────────────────────────────────────────────
  var isLoading = true.obs;
  var isSaving = false.obs;

  // ─── Case list ──────────────────────────────────────────────────
  var caseList = <LegalCase>[].obs;
  var searchQuery = ''.obs;
  var currentPage = 1.obs;
  var limit = 10.obs;
  var totalItems = 0.obs;

  // ─── Statistics ─────────────────────────────────────────────────
  var statistics = Rxn<LegalCaseStatistics>();
  var upcomingHearings = <LegalCase>[].obs;

  // ─── Filters ──────────────────────────────────────────────────────
  var selectedCaseType = ''.obs;
  var selectedStatus = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCases();
  }

  // ─── FETCH ────────────────────────────────────────────────────────

  Future<void> fetchCases({bool refresh = false}) async {
    try {
      if (!refresh) isLoading.value = true;

      final token = await _getToken();
      if (token == null) return;

      final offset = (currentPage.value - 1) * limit.value;

      final result = await _service.getCases(
        token,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        caseType: selectedCaseType.value.isNotEmpty
            ? selectedCaseType.value
            : null,
        status: selectedStatus.value.isNotEmpty ? selectedStatus.value : null,
        limit: limit.value,
        offset: offset,
      );

      caseList.assignAll(result.items);
      totalItems.value = result.total;
    } catch (e) {
      log("Error fetching cases: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ─── CREATE ───────────────────────────────────────────────────────

  Future<void> createCase(
      BuildContext context, Map<String, dynamic> data) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return;

      log("Create Case payload: $data");
      await _service.createCase(token, data);

      if (context.mounted) {
        Navigator.pop(context);
        fetchCases(refresh: true);
        _showSnackBar(context, "Legal case created successfully");
      }
    } catch (e) {
      log("Create Case Error: $e");
      if (context.mounted) {
        _showErrorDialog(
            context, "Failed to create case: ${e.toString()}");
      }
    } finally {
      isSaving.value = false;
    }
  }

  // ─── UPDATE ───────────────────────────────────────────────────────

  Future<void> updateCase(
      BuildContext context, int id, Map<String, dynamic> data) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return;

      log("Update Case payload: $data");
      await _service.updateCase(token, id, data);

      if (context.mounted) {
        Navigator.pop(context);
        fetchCases(refresh: true);
        _showSnackBar(context, "Legal case updated successfully");
      }
    } catch (e) {
      log("Update Case Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to update case");
      }
    } finally {
      isSaving.value = false;
    }
  }

  // ─── DELETE ───────────────────────────────────────────────────────

  Future<void> deleteCase(BuildContext context, int id) async {
    try {
      final token = await _getToken();
      if (token == null) return;

      await _service.deleteCase(token, id);

      if (context.mounted) {
        fetchCases(refresh: true);
        _showSnackBar(context, "Legal case deleted successfully");
      }
    } catch (e) {
      log("Delete Case Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to delete case");
      }
    }
  }

  // ─── UPDATE STATUS ────────────────────────────────────────────────

  Future<void> updateCaseStatus(
      BuildContext context, int id, String status) async {
    try {
      final token = await _getToken();
      if (token == null) return;

      await _service.updateCaseStatus(token, id, status);

      if (context.mounted) {
        fetchCases(refresh: true);
        _showSnackBar(context, "Case status updated successfully");
      }
    } catch (e) {
      log("Update Case Status Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to update case status");
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
      log("Error fetching case statistics: $e");
    }
  }

  // ─── UPCOMING HEARINGS ───────────────────────────────────────────

  Future<void> fetchUpcomingHearings({int days = 30}) async {
    try {
      final token = await _getToken();
      if (token == null) return;

      final result = await _service.getUpcomingHearings(token, days: days);
      upcomingHearings.assignAll(result);
    } catch (e) {
      log("Error fetching upcoming hearings: $e");
    }
  }

  // ─── SEARCH / FILTER ─────────────────────────────────────────────

  void onSearchChanged(String val) {
    searchQuery.value = val;
    currentPage.value = 1;
    fetchCases();
  }

  void onFilterChanged() {
    currentPage.value = 1;
    fetchCases();
  }

  // ─── PAGINATION ──────────────────────────────────────────────────

  void goToPage(int page) {
    currentPage.value = page;
    fetchCases();
  }

  void setLimit(int newLimit) {
    limit.value = newLimit;
    currentPage.value = 1;
    fetchCases();
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c), child: const Text("OK")),
        ],
      ),
    );
  }
}
