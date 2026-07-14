import 'dart:developer';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../../hr/models/work_report_model.dart';
import '../../../src/model/employees_model.dart';
import '../../../src/services/employees_services.dart';
import '../../../src/services/hr/work_report_service.dart';

class DailyRoutineController extends GetxController {
  final WorkReportService _wrService = WorkReportService();
  final EmployeeService _empService = EmployeeService();
  final _storage = const FlutterSecureStorage();

  var employees = <Employee>[].obs;
  var workReports = <WorkReport>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  int? scopedRoleId;

  Future<String?> _getToken() async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith('Bearer ')) token = token.substring(7);
    return token.replaceAll('"', '').trim();
  }

  Future<void> fetchData({int? roleId}) async {
    isLoading.value = true;
    try {
      final token = await _getToken();
      if (token == null) return;

      final role = roleId ?? scopedRoleId;
      if (role == null) return;

      final empResult = await _empService.getEmployees(token, limit: 500);
      final roleEmployees =
          empResult.list.where((e) => e.roleId == role).toList();
      employees.assignAll(roleEmployees);

      final reports = <WorkReport>[];
      for (final emp in roleEmployees) {
        try {
          final result = await _wrService.getWorkReports(
            token,
            employeeId: emp.id,
            limit: 50,
          );
          reports.addAll(result);
        } catch (_) {}
      }
      reports.sort((a, b) {
        if (a.day == null && b.day == null) return 0;
        if (a.day == null) return 1;
        if (b.day == null) return -1;
        return b.day!.compareTo(a.day!);
      });
      workReports.assignAll(reports);
    } catch (e) {
      log('DailyRoutineController.fetchData error: $e');
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
