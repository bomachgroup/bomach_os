import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../src/services/finance/payment_service.dart';
import '../models/payment_model.dart';

class PaymentController extends GetxController {
  final PaymentService _service = PaymentService();
  final _storage = const FlutterSecureStorage();

  // ─── Loading state ────────────────────────────────────────────────
  var isLoading = true.obs;
  var isSaving = false.obs;

  // ─── Payment list ─────────────────────────────────────────────────
  var paymentList = <Payment>[].obs;
  var currentPage = 1.obs;
  var limit = 10.obs;
  var totalItems = 0.obs;

  // ─── Filters ──────────────────────────────────────────────────────
  var filterInvoiceId = Rxn<int>();

  @override
  void onInit() {
    super.onInit();
    fetchPayments();
  }

  // ─── FETCH ────────────────────────────────────────────────────────

  Future<void> fetchPayments({bool refresh = false}) async {
    try {
      if (!refresh) isLoading.value = true;

      final token = await _getToken();
      if (token == null) return;

      final offset = (currentPage.value - 1) * limit.value;

      final result = await _service.getPayments(
        token,
        invoiceId: filterInvoiceId.value,
        limit: limit.value,
        offset: offset,
      );

      paymentList.assignAll(result.items);
      totalItems.value = result.total;
    } catch (e) {
      log("Error fetching payments: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ─── CREATE ───────────────────────────────────────────────────────

  Future<void> createPayment(
      BuildContext context, Map<String, dynamic> data) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return;

      log("Create Payment payload: $data");
      await _service.createPayment(token, data);

      if (context.mounted) {
        Navigator.pop(context);
        fetchPayments(refresh: true);
        _showSnackBar(context, "Payment created successfully");
      }
    } catch (e) {
      log("Create Payment Error: $e");
      if (context.mounted) {
        _showErrorDialog(
            context, "Failed to create payment: ${e.toString()}");
      }
    } finally {
      isSaving.value = false;
    }
  }

  // ─── DELETE ───────────────────────────────────────────────────────

  Future<void> deletePayment(BuildContext context, int id) async {
    try {
      final token = await _getToken();
      if (token == null) return;

      await _service.deletePayment(token, id);

      if (context.mounted) {
        fetchPayments(refresh: true);
        _showSnackBar(context, "Payment deleted successfully");
      }
    } catch (e) {
      log("Delete Payment Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to delete payment");
      }
    }
  }

  // ─── FILTER ───────────────────────────────────────────────────────

  void filterByInvoice(int? invoiceId) {
    filterInvoiceId.value = invoiceId;
    currentPage.value = 1;
    fetchPayments();
  }

  // ─── PAGINATION ──────────────────────────────────────────────────

  void goToPage(int page) {
    currentPage.value = page;
    fetchPayments();
  }

  void setLimit(int newLimit) {
    limit.value = newLimit;
    currentPage.value = 1;
    fetchPayments();
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
