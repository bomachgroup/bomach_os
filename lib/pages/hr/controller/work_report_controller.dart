import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../src/services/employees_services.dart';
import '../../../src/services/hr/work_report_service.dart';
import '../../../src/model/employees_model.dart';
import '../models/work_report_model.dart';

class WorkReportController extends GetxController {
  final WorkReportService _service;
  final EmployeeService _employeeService;

  WorkReportController({
    WorkReportService? service,
    EmployeeService? employeeService,
  })  : _service = service ?? WorkReportService(),
        _employeeService = employeeService ?? EmployeeService();

  var isLoading = false.obs;
  var isSaving = false.obs;
  var workReports = <WorkReport>[].obs;
  var errorMessage = ''.obs;
  var employeeNames = <int, String>{}.obs;

  int limit = 100;
  int offset = 0;

  Future<void> fetchReports(String token) async {
    try {
      isLoading(true);
      errorMessage('');
      final result = await _service.getWorkReports(
        token,
        limit: limit,
        offset: offset,
      );
      workReports.assignAll(result);
      await _loadEmployeeNames(token);
    } catch (e) {
      errorMessage('Failed to load reports: $e');
      debugPrint("Fetch Error: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<bool> createReport(String token, WorkReport report) async {
    try {
      isSaving(true);
      await _service.createWorkReport(token, report);
      await fetchReports(token);
      return true;
    } catch (e) {
      debugPrint("Create Error: $e");
      return false;
    } finally {
      isSaving(false);
    }
  }

  Future<bool> updateReport(String token, String id, WorkReport report) async {
    try {
      isSaving(true);
      await _service.updateWorkReport(token, id, report);
      await fetchReports(token);
      return true;
    } catch (e) {
      debugPrint("Update Error: $e");
      return false;
    } finally {
      isSaving(false);
    }
  }

  Future<bool> deleteReport(String token, String id) async {
    try {
      await _service.deleteWorkReport(token, id);
      workReports.removeWhere((r) => r.id == id);
      return true;
    } catch (e) {
      debugPrint("Delete Error: $e");
      fetchReports(token);
      return false;
    }
  }

  Future<WorkReport> getReportById(String token, String id) async {
    return _service.getWorkReportById(token, id);
  }

  /// List responses may contain only summary fields. Always resolve the
  /// server's detail representation before opening a report viewer.
  Future<WorkReport> getReportForViewing(
      String token, WorkReport listedReport) async {
    if (listedReport.id.isEmpty) return listedReport;
    return _service.getWorkReportById(token, listedReport.id);
  }

  String employeeDisplayName(int employeeId) {
    final name = employeeNames[employeeId]?.trim();
    if (name != null && name.isNotEmpty) return name;
    return 'Employee name unavailable (ID: $employeeId)';
  }

  /// WorkReport.employee_id is the employee table's primary key. Employee.id
  /// in the app model is user_id, while tableId maps the employee record's id.
  /// Indexing both creates collisions and can label one employee's report
  /// with another employee's name when those independent ID sequences overlap.
  static Map<int, String> buildEmployeeNameIndex(Iterable<Employee> employees) {
    final names = <int, String>{};
    for (final employee in employees) {
      final employeeRecordId = int.tryParse(employee.tableId ?? '');
      final name = employee.fullName.trim();
      if (employeeRecordId == null || name.isEmpty) continue;
      names.putIfAbsent(employeeRecordId, () => name);
    }
    return names;
  }

  Future<void> _loadEmployeeNames(String token) async {
    try {
      final result = await _employeeService.getEmployees(
        token,
        isActive: null,
        limit: 100,
        offset: 0,
      );
      employeeNames.assignAll(buildEmployeeNameIndex(result.list));
    } catch (e) {
      // Report access should remain usable when employee metadata is not
      // available to the current reviewer; the row displays a clear fallback.
      debugPrint('Employee name lookup failed: $e');
    }
  }

  Future<bool> approveReport(
    String token,
    String id, {
    int? rating,
    String? feedback,
  }) async {
    try {
      await _service.approveWorkReport(
        token,
        id,
        rating: rating,
        feedback: feedback,
      );
      await fetchReports(token);
      return true;
    } catch (e) {
      debugPrint('Approve Error: $e');
      return false;
    }
  }

  Future<bool> rejectReport(String token, String id, String feedback) async {
    try {
      await _service.rejectWorkReport(token, id, feedback: feedback);
      await fetchReports(token);
      return true;
    } catch (e) {
      debugPrint('Reject Error: $e');
      return false;
    }
  }
}
