import 'dart:developer';
import 'package:bms_front_end/components/dialog/dialog_scaffold.dart';
import 'package:bms_front_end/components/feedback/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../src/services/finance/budget_service.dart';
import '../models/budget_model.dart';

class BudgetController extends GetxController {
  final BudgetService _service = BudgetService();
  final _storage = const FlutterSecureStorage();

  // ─── Loading state ────────────────────────────────────────────────
  var isLoading = true.obs;
  var isSaving = false.obs;

  // ─── Budget list ──────────────────────────────────────────────────
  var budgetList = <Budget>[].obs;
  var searchQuery = ''.obs;
  var currentPage = 1.obs;
  var limit = 10.obs;
  var totalItems = 0.obs;

  // ─── Filters ──────────────────────────────────────────────────────
  var selectedBranch = 'All'.obs;
  var selectedDepartment = 'All'.obs;
  var selectedFiscalPeriod = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBudgets();
  }

  // ─── FETCH ────────────────────────────────────────────────────────

  Future<void> fetchBudgets({bool refresh = false}) async {
    try {
      if (!refresh) isLoading.value = true;

      final token = await _getToken();
      if (token == null) return;

      final offset = (currentPage.value - 1) * limit.value;

      final result = await _service.getBudgets(
        token,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        branch: selectedBranch.value,
        department: selectedDepartment.value,
        fiscalPeriod: selectedFiscalPeriod.value.isNotEmpty
            ? selectedFiscalPeriod.value
            : null,
        limit: limit.value,
        offset: offset,
      );

      budgetList.assignAll(result.items);
      totalItems.value = result.total;
    } catch (e) {
      log("Error fetching budgets: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ─── CREATE ───────────────────────────────────────────────────────

  Future<void> createBudget(
      BuildContext context, Map<String, dynamic> data) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return;

      log("Create Budget payload: $data");
      await _service.createBudget(token, data);

      if (context.mounted) {
        Navigator.pop(context);
        fetchBudgets(refresh: true);
        _showSnackBar(context, "Budget created successfully");
      }
    } catch (e) {
      log("Create Budget Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to create budget: ${e.toString()}");
      }
    } finally {
      isSaving.value = false;
    }
  }

  // ─── UPDATE ───────────────────────────────────────────────────────

  Future<void> updateBudget(
      BuildContext context, int id, Map<String, dynamic> data) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return;

      log("Update Budget payload: $data");
      await _service.updateBudget(token, id, data);

      if (context.mounted) {
        Navigator.pop(context);
        fetchBudgets(refresh: true);
        _showSnackBar(context, "Budget updated successfully");
      }
    } catch (e) {
      log("Update Budget Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to update budget");
      }
    } finally {
      isSaving.value = false;
    }
  }

  // ─── DELETE ───────────────────────────────────────────────────────

  Future<void> deleteBudget(BuildContext context, int id) async {
    try {
      final token = await _getToken();
      if (token == null) return;

      await _service.deleteBudget(token, id);

      if (context.mounted) {
        fetchBudgets(refresh: true);
        _showSnackBar(context, "Budget deleted successfully");
      }
    } catch (e) {
      log("Delete Budget Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to delete budget");
      }
    }
  }

  // ─── SEARCH / FILTER ─────────────────────────────────────────────

  void onSearchChanged(String val) {
    searchQuery.value = val;
    currentPage.value = 1;
    fetchBudgets();
  }

  void onFilterChanged() {
    currentPage.value = 1;
    fetchBudgets();
  }

  // ─── PAGINATION ──────────────────────────────────────────────────

  void goToPage(int page) {
    currentPage.value = page;
    fetchBudgets();
  }

  void setLimit(int newLimit) {
    limit.value = newLimit;
    currentPage.value = 1;
    fetchBudgets();
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
