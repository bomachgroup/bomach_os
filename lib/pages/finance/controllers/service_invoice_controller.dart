import 'dart:developer';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../src/services/finance/service_invoice_service.dart';
import '../models/service_invoice_model_api.dart';

class ServiceInvoiceController extends GetxController {
  final ServiceInvoiceService _service = ServiceInvoiceService();
  final _storage = const FlutterSecureStorage();

  // ─── Loading state ────────────────────────────────────────────────
  var isLoading = true.obs;
  var isSaving = false.obs;

  // ─── Invoice list ─────────────────────────────────────────────────
  var invoiceList = <ServiceInvoice>[].obs;
  var searchQuery = ''.obs;
  var currentPage = 1.obs;
  var limit = 10.obs;
  var totalItems = 0.obs;

  // ─── Filters ──────────────────────────────────────────────────────
  var selectedStatus = 'All'.obs;
  var filterClientId = Rxn<int>();

  @override
  void onInit() {
    super.onInit();
    fetchInvoices();
  }

  // ─── FETCH ────────────────────────────────────────────────────────

  Future<void> fetchInvoices({bool refresh = false}) async {
    try {
      if (!refresh) isLoading.value = true;

      final token = await _getToken();
      if (token == null) return;

      final offset = (currentPage.value - 1) * limit.value;

      final result = await _service.getInvoices(
        token,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        status: selectedStatus.value,
        clientId: filterClientId.value,
        limit: limit.value,
        offset: offset,
      );

      invoiceList.assignAll(result.items);
      totalItems.value = result.total;
    } catch (e) {
      log("Error fetching invoices: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ─── CREATE ───────────────────────────────────────────────────────

  Future<void> createInvoice(
      BuildContext context, Map<String, dynamic> data) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return;

      log("Create Invoice payload: $data");
      await _service.createInvoice(token, data);

      if (context.mounted) {
        Navigator.pop(context);
        fetchInvoices(refresh: true);
        _showSnackBar(context, "Invoice created successfully");
      }
    } catch (e) {
      log("Create Invoice Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to create invoice: ${e.toString()}");
      }
    } finally {
      isSaving.value = false;
    }
  }

  // ─── UPDATE ───────────────────────────────────────────────────────

  Future<void> updateInvoice(
      BuildContext context, int id, Map<String, dynamic> data) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return;

      log("Update Invoice payload: $data");
      await _service.updateInvoice(token, id, data);

      if (context.mounted) {
        Navigator.pop(context);
        fetchInvoices(refresh: true);
        _showSnackBar(context, "Invoice updated successfully");
      }
    } catch (e) {
      log("Update Invoice Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to update invoice");
      }
    } finally {
      isSaving.value = false;
    }
  }

  // ─── DELETE ───────────────────────────────────────────────────────

  Future<void> deleteInvoice(BuildContext context, int id) async {
    try {
      final token = await _getToken();
      if (token == null) return;

      await _service.deleteInvoice(token, id);

      if (context.mounted) {
        fetchInvoices(refresh: true);
        _showSnackBar(context, "Invoice deleted successfully");
      }
    } catch (e) {
      log("Delete Invoice Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to delete invoice");
      }
    }
  }

  // ─── SEARCH / FILTER ─────────────────────────────────────────────

  void onSearchChanged(String val) {
    searchQuery.value = val;
    currentPage.value = 1;
    fetchInvoices();
  }

  void onFilterChanged() {
    currentPage.value = 1;
    fetchInvoices();
  }

  void filterByClient(int? clientId) {
    filterClientId.value = clientId;
    currentPage.value = 1;
    fetchInvoices();
  }

  // ─── PAGINATION ──────────────────────────────────────────────────

  void goToPage(int page) {
    currentPage.value = page;
    fetchInvoices();
  }

  void setLimit(int newLimit) {
    limit.value = newLimit;
    currentPage.value = 1;
    fetchInvoices();
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
