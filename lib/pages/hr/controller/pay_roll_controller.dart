import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'
    show FlutterSecureStorage;
import 'package:get/get.dart';

import '../../../src/services/hr/payroll_service.dart';
import '../models/payroll_model.dart';

class PayrollController extends GetxController {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final PayrollService _service = PayrollService();

  var isLoading = false.obs;
  var isSaving = false.obs;
  var payrollList = <Payroll>[].obs;
  var errorMessage = ''.obs;

  int limit = 100;
  int offset = 0;

  Future<String?> _getToken(BuildContext context) async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith("Bearer ")) token = token.replaceFirst("Bearer ", "");
    return token.replaceAll('"', '').trim();
  }

  @override
  void onInit() {
    super.onInit();
    fetchPayrolls();
  }

  Future<void> fetchPayrolls() async {
    try {
      isLoading(true);
      errorMessage('');
      final context = Get.context;
      if (context == null) return;
      final token = await _getToken(context);
      if (token == null) {
        errorMessage('Authentication token not found');
        return;
      }
      final result = await _service.getPayrolls(
        token,
        limit: limit,
        offset: offset,
      );
      payrollList.assignAll(result);
    } catch (e) {
      errorMessage('Failed to load payrolls: $e');
      log('$e');
    } finally {
      isLoading(false);
    }
  }

  Future<bool> createPayroll(Payroll payroll) async {
    try {
      isSaving(true);
      final context = Get.context;
      if (context == null) return false;
      final token = await _getToken(context);
      if (token == null) return false;
      await _service.createPayroll(token, payroll);
      await fetchPayrolls();
      return true;
    } catch (e) {
      log('Create Error: $e');
      return false;
    } finally {
      isSaving(false);
    }
  }

  Future<bool> updatePayroll(String id, Payroll payroll) async {
    try {
      isSaving(true);
      final context = Get.context;
      if (context == null) return false;
      final token = await _getToken(context);
      if (token == null) return false;
      await _service.updatePayroll(token, id, payroll);
      await fetchPayrolls(); 
      return true;
    } catch (e) {
      log('Update Error: $e');
      return false;
    } finally {
      isSaving(false);
    }
  }

  Future<bool> updateStatus(String id, String status) async {
    try {
      final context = Get.context;
      if (context == null) return false;
      final token = await _getToken(context);
      if (token == null) return false;
      await _service.updatePayrollStatus(token, id, status);
      final index = payrollList.indexWhere((p) => p.id == id);
      if (index != -1) {
        final old = payrollList[index];
        payrollList[index] = Payroll(
          id: old.id,
          employeeId: old.employeeId,
          payrollPeriod: old.payrollPeriod,
          status: status,
          grossSalary: old.grossSalary,
          netSalary: old.netSalary,
          totalDeductions: old.totalDeductions,
          totalAllowances: old.totalAllowances,
          disbursementDate: old.disbursementDate,
          deductions: old.deductions,
          additions: old.additions,
          createdAt: old.createdAt,
          updatedAt: DateTime.now(),
        );
      }
      return true;
    } catch (e) {
      log('Status Update Error: $e');
      fetchPayrolls();
      return false;
    }
  }

  Future<bool> deletePayroll(String id) async {
    try {
      final context = Get.context;
      if (context == null) return false;
      final token = await _getToken(context);
      if (token == null) return false;
      await _service.deletePayroll(token, id);
      payrollList.removeWhere((p) => p.id == id);
      return true;
    } catch (e) {
      log('Delete Error: $e');
      return false;
    }
  }
}
