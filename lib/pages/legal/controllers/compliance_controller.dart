import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../src/services/legal/compliance_service.dart';
import '../models/compliance_record_model.dart';

class ComplianceController extends GetxController {
  final ComplianceService _service = ComplianceService();
  final _storage = const FlutterSecureStorage();

  var isLoading = true.obs;
  var isSaving = false.obs;

  var recordList = <ComplianceRecord>[].obs;
  var searchQuery = ''.obs;
  var currentPage = 1.obs;
  var limit = 10.obs;
  var totalItems = 0.obs;

  var selectedType = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRecords();
  }

  Future<void> fetchRecords({bool refresh = false}) async {
    try {
      if (!refresh) isLoading.value = true;

      final token = await _getToken();
      if (token == null) return;

      final offset = (currentPage.value - 1) * limit.value;

      final result = await _service.getRecords(
        token,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        complianceType:
            selectedType.value.isNotEmpty ? selectedType.value : null,
        limit: limit.value,
        offset: offset,
      );

      recordList.assignAll(result.items);
      totalItems.value = result.total;
    } catch (e) {
      log("Error fetching compliance records: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createRecord(
      BuildContext context, Map<String, dynamic> data) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return;

      log("Create Compliance Record payload: $data");
      await _service.createRecord(token, data);

      if (context.mounted) {
        Navigator.pop(context);
        fetchRecords(refresh: true);
        _showSnackBar(context, "Compliance record created successfully");
      }
    } catch (e) {
      log("Create Compliance Record Error: $e");
      if (context.mounted) {
        _showErrorDialog(
            context, "Failed to create record: ${e.toString()}");
      }
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> updateRecord(
      BuildContext context, int id, Map<String, dynamic> data) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return;

      log("Update Compliance Record payload: $data");
      await _service.updateRecord(token, id, data);

      if (context.mounted) {
        Navigator.pop(context);
        fetchRecords(refresh: true);
        _showSnackBar(context, "Compliance record updated successfully");
      }
    } catch (e) {
      log("Update Compliance Record Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to update record");
      }
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteRecord(BuildContext context, int id) async {
    try {
      final token = await _getToken();
      if (token == null) return;

      await _service.deleteRecord(token, id);

      if (context.mounted) {
        fetchRecords(refresh: true);
        _showSnackBar(context, "Compliance record deleted successfully");
      }
    } catch (e) {
      log("Delete Compliance Record Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to delete record");
      }
    }
  }

  void onSearchChanged(String val) {
    searchQuery.value = val;
    currentPage.value = 1;
    fetchRecords();
  }

  void onFilterChanged() {
    currentPage.value = 1;
    fetchRecords();
  }

  void goToPage(int page) {
    currentPage.value = page;
    fetchRecords();
  }

  void setLimit(int newLimit) {
    limit.value = newLimit;
    currentPage.value = 1;
    fetchRecords();
  }

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
