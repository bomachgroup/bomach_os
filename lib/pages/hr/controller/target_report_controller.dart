import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../../../src/model/employee_target_model.dart';
import '../../../src/model/target_report_model.dart';
import '../../../src/services/target_report_service.dart';

class TargetReportController extends GetxController {
  final TargetReportService _service;
  final Future<String?> Function() _tokenReader;

  TargetReportController({
    TargetReportService? service,
    Future<String?> Function()? tokenReader,
  })  : _service = service ?? TargetReportService(),
        _tokenReader = tokenReader ?? _readStoredToken;

  static Future<String?> _readStoredToken() async {
    var token = await const FlutterSecureStorage().read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith('Bearer ')) token = token.substring(7);
    return token.replaceAll('"', '').trim();
  }

  final reports = <TargetReport>[].obs;
  final assignedTargets = <EmployeeTarget>[].obs;
  final isLoading = false.obs;
  final isLoadingTargets = false.obs;
  final isSaving = false.obs;
  final errorMessage = ''.obs;
  final targetLoadError = ''.obs;
  final selectedStatus = RxnString();
  final searchQuery = ''.obs;
  final count = 0.obs;

  Future<void> fetchMyAssignedTargets() async {
    isLoadingTargets.value = true;
    targetLoadError.value = '';
    try {
      final token = await _tokenReader();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication is required to load assigned targets.');
      }
      assignedTargets.assignAll(await _service.listMyAssignedTargets(token));
    } catch (error) {
      log('TargetReportController.fetchMyAssignedTargets error: $error');
      assignedTargets.clear();
      targetLoadError.value = error.toString();
    } finally {
      isLoadingTargets.value = false;
    }
  }

  Future<void> fetchMine() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final token = await _tokenReader();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication is required to load target reports.');
      }
      final result = await _service.listMine(
        token,
        status: selectedStatus.value,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
      );
      reports.assignAll(result.list);
      count.value = result.count;
    } catch (error) {
      log('TargetReportController.fetchMine error: $error');
      reports.clear();
      count.value = 0;
      errorMessage.value = error.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void setStatus(String? status) {
    selectedStatus.value = status;
    fetchMine();
  }

  void setSearch(String value) {
    searchQuery.value = value;
    fetchMine();
  }

  Future<bool> createReport({
    required int employeeTargetId,
    required String summary,
    required num progressValue,
  }) async {
    isSaving.value = true;
    errorMessage.value = '';
    try {
      final token = await _tokenReader();
      if (token == null || token.isEmpty) {
        throw Exception(
            'Authentication is required to submit a target report.');
      }
      await _service.create(
        token,
        employeeTargetId: employeeTargetId,
        summary: summary,
        progressValue: progressValue,
      );
      await fetchMine();
      return true;
    } catch (error) {
      errorMessage.value = error.toString();
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> approveReport(int reportId) async {
    return _review(() async {
      final token = await _requiredToken();
      await _service.approve(token, reportId);
    });
  }

  Future<bool> rejectReport(int reportId, String reason) async {
    return _review(() async {
      final token = await _requiredToken();
      await _service.reject(token, reportId, reason);
    });
  }

  Future<String> _requiredToken() async {
    final token = await _tokenReader();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication is required to review target reports.');
    }
    return token;
  }

  Future<bool> _review(Future<void> Function() action) async {
    isSaving.value = true;
    errorMessage.value = '';
    try {
      await action();
      await fetchMine();
      return true;
    } catch (error) {
      errorMessage.value = error.toString();
      return false;
    } finally {
      isSaving.value = false;
    }
  }
}
