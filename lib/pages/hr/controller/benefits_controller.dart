import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../src/services/hr/payroll_service.dart';
import '../models/benefits_model.dart';

class BenefitsController extends GetxController {
  final PayrollService _payrollService = PayrollService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // --- State ---
  var isLoading = false.obs;
  var isSaving = false.obs;
  var employeeList = <BenefitRecord>[].obs;
  var availableBenefits = <String>[].obs;
  var totalCount = 0.obs;
  var errorMessage = ''.obs;
  var hasError = false.obs;

  // Filters & Pagination
  final searchController = TextEditingController();
  var currentPage = 1.obs;
  var itemsPerPage = 10.obs;

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // --- Fetch Benefits from Payroll Data ---

  Future<void> fetchBenefits(BuildContext context, {bool refresh = false}) async {
    try {
      if (!refresh) isLoading.value = true;
      hasError.value = false;

      final token = await _getToken(context);
      if (token == null) {
        hasError.value = true;
        errorMessage.value = 'Authentication failed.';
        return;
      }

      final payrolls = await _payrollService.getPayrolls(
        token,
        search: searchController.text.trim().isNotEmpty
            ? searchController.text.trim()
            : null,
        limit: itemsPerPage.value,
        offset: (currentPage.value - 1) * itemsPerPage.value,
      );

      // Convert payroll records to benefit records
      final benefits =
          payrolls.map((p) => BenefitRecord.fromPayroll(p)).toList();

      employeeList.assignAll(benefits);
      totalCount.value = benefits.length;

      // Collect all unique benefit names across records
      final allBenefitNames = <String>{};
      for (final record in benefits) {
        allBenefitNames.addAll(record.activeBenefits);
      }
      availableBenefits.assignAll(allBenefitNames.toList()..sort());
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      log('Fetch benefits error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // --- Actions ---

  bool addBenefitType(String name) {
    if (name.isNotEmpty && !availableBenefits.contains(name)) {
      availableBenefits.add(name);
      return true;
    }
    return false;
  }

  void removeBenefitType(String name) {
    availableBenefits.remove(name);
  }

  void updateEmployeeBenefits(String empId, List<String> newBenefits) {
    int index = employeeList.indexWhere((e) => e.id == empId);
    if (index != -1) {
      final old = employeeList[index];
      employeeList[index] = BenefitRecord(
        id: old.id,
        employeeName: old.employeeName,
        employeeId: old.employeeId,
        employeeRole: old.employeeRole,
        activeBenefits: newBenefits,
        startDate: old.startDate,
        status: old.status,
        imageUrl: old.imageUrl,
        grossSalary: old.grossSalary,
        netSalary: old.netSalary,
        totalAllowances: old.totalAllowances,
        totalDeductions: old.totalDeductions,
      );
      employeeList.refresh();
    }
  }

  void changePage(int page, BuildContext context) {
    currentPage.value = page;
    fetchBenefits(context, refresh: true);
  }

  void changeLimit(int limit, BuildContext context) {
    itemsPerPage.value = limit;
    currentPage.value = 1;
    fetchBenefits(context, refresh: true);
  }

  // --- Utilities ---

  Future<String?> _getToken(BuildContext context) async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith('Bearer ')) token = token.replaceFirst('Bearer ', '');
    return token.replaceAll('"', '').trim();
  }
}
