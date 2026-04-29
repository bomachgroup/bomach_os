import 'dart:developer';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../src/services/finance/expense_service.dart';
import '../models/expense_model.dart';

class ExpenseController extends GetxController {
  final ExpenseService _service = ExpenseService();
  final _storage = const FlutterSecureStorage();

  // ─── Loading state ────────────────────────────────────────────────
  var isLoading = true.obs;
  var isSaving = false.obs;

  // ─── Expense list ─────────────────────────────────────────────────
  var expenseList = <Expense>[].obs;
  var searchQuery = ''.obs;
  var currentPage = 1.obs;
  var limit = 10.obs;
  var totalItems = 0.obs;

  // ─── Filters ──────────────────────────────────────────────────────
  var selectedStatus = 'All'.obs;
  var selectedCategory = 'All'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchExpenses();
  }

  // ─── FETCH ────────────────────────────────────────────────────────

  Future<void> fetchExpenses({bool refresh = false}) async {
    try {
      if (!refresh) isLoading.value = true;

      final token = await _getToken();
      if (token == null) return;

      final offset = (currentPage.value - 1) * limit.value;

      final result = await _service.getExpenses(
        token,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        status: selectedStatus.value,
        category: selectedCategory.value,
        limit: limit.value,
        offset: offset,
      );

      expenseList.assignAll(result.items);
      totalItems.value = result.total;
    } catch (e) {
      log("Error fetching expenses: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ─── CREATE ───────────────────────────────────────────────────────

  Future<void> createExpense(
      BuildContext context, Map<String, dynamic> data) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return;

      log("Create Expense payload: $data");
      await _service.createExpense(token, data);

      if (context.mounted) {
        Navigator.pop(context);
        fetchExpenses(refresh: true);
        _showSnackBar(context, "Expense created successfully");
      }
    } catch (e) {
      log("Create Expense Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to create expense: ${e.toString()}");
      }
    } finally {
      isSaving.value = false;
    }
  }

  // ─── UPDATE ───────────────────────────────────────────────────────

  Future<void> updateExpense(
      BuildContext context, int id, Map<String, dynamic> data) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return;

      log("Update Expense payload: $data");
      await _service.updateExpense(token, id, data);

      if (context.mounted) {
        Navigator.pop(context);
        fetchExpenses(refresh: true);
        _showSnackBar(context, "Expense updated successfully");
      }
    } catch (e) {
      log("Update Expense Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to update expense");
      }
    } finally {
      isSaving.value = false;
    }
  }

  // ─── DELETE ───────────────────────────────────────────────────────

  Future<void> deleteExpense(BuildContext context, int id) async {
    try {
      final token = await _getToken();
      if (token == null) return;

      await _service.deleteExpense(token, id);

      if (context.mounted) {
        fetchExpenses(refresh: true);
        _showSnackBar(context, "Expense deleted successfully");
      }
    } catch (e) {
      log("Delete Expense Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to delete expense");
      }
    }
  }

  // ─── APPROVE / REJECT ─────────────────────────────────────────────

  Future<void> approveExpense(BuildContext context, int id) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return;

      await _service.approveExpense(token, id);

      if (context.mounted) {
        fetchExpenses(refresh: true);
        _showSnackBar(context, "Expense approved successfully");
      }
    } catch (e) {
      log("Approve Expense Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to approve expense");
      }
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> rejectExpense(BuildContext context, int id) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return;

      await _service.rejectExpense(token, id);

      if (context.mounted) {
        fetchExpenses(refresh: true);
        _showSnackBar(context, "Expense rejected successfully");
      }
    } catch (e) {
      log("Reject Expense Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to reject expense");
      }
    } finally {
      isSaving.value = false;
    }
  }

  // ─── SEARCH / FILTER ─────────────────────────────────────────────

  void onSearchChanged(String val) {
    searchQuery.value = val;
    currentPage.value = 1;
    fetchExpenses();
  }

  void onFilterChanged() {
    currentPage.value = 1;
    fetchExpenses();
  }

  // ─── PAGINATION ──────────────────────────────────────────────────

  void goToPage(int page) {
    currentPage.value = page;
    fetchExpenses();
  }

  void setLimit(int newLimit) {
    limit.value = newLimit;
    currentPage.value = 1;
    fetchExpenses();
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
