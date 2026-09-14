import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../src/constants/api_constants.dart';
import '../../src/model/employees_model.dart';
import '../../src/services/audit_log_service.dart';
import '../../src/services/hr/work_report_service.dart';
import '../../src/services/operations/tasks_services.dart';
import '../operations/models/models.dart';
import 'models/work_report_model.dart';

/// Data contract used by the desktop employee profile.
///
/// Keeping this contract separate from the widgets makes it possible to test
/// the UI with server-shaped data without introducing fixtures into runtime
/// code.
abstract class EmployeeProfileDataSource {
  Future<List<AuditLogResponse>> loadActivity(Employee employee);

  Future<List<Task>> loadTasks(Employee employee);

  Future<List<WorkReport>> loadWorkReports(Employee employee);

  Future<WorkReport> loadWorkReport(String reportId);
}

/// API-backed employee profile data source.
///
/// Activity is scoped by the employee's user ID. Tasks are read from the
/// supported management task endpoint and filtered by either the employee's
/// user ID or employee-table ID because the contract exposes assignment IDs,
/// but does not expose an employee filter query parameter. Work reports use
/// the employee-table ID when available.
class ApiEmployeeProfileDataSource implements EmployeeProfileDataSource {
  final AuditLogService _auditLogService;
  final TaskService _taskService;
  final WorkReportService _workReportService;
  final FlutterSecureStorage _storage;
  final Future<String> Function()? _tokenProvider;

  ApiEmployeeProfileDataSource({
    AuditLogService? auditLogService,
    TaskService? taskService,
    WorkReportService? workReportService,
    FlutterSecureStorage? storage,
    Future<String> Function()? tokenProvider,
  })  : _auditLogService = auditLogService ?? AuditLogService(),
        _taskService = taskService ??
            TaskService(baseUrl: ApiConstants.operationsBaseUrl),
        _workReportService = workReportService ?? WorkReportService(),
        _storage = storage ?? const FlutterSecureStorage(),
        _tokenProvider = tokenProvider;

  Future<String> _token() async {
    if (_tokenProvider != null) return _tokenProvider();
    var token = await _storage.read(key: 'access_token');
    if (token == null || token.trim().isEmpty) {
      throw Exception('Not signed in.');
    }
    if (token.startsWith('Bearer ')) token = token.substring(7);
    return token.replaceAll('"', '').trim();
  }

  @override
  Future<List<AuditLogResponse>> loadActivity(Employee employee) async {
    final result = await _auditLogService.getAuditLogs(
      await _token(),
      userId: employee.id,
      limit: 100,
      offset: 0,
    );
    return result.items;
  }

  @override
  Future<List<Task>> loadTasks(Employee employee) async {
    final token = await _token();
    final employeeIds = <String>{
      employee.id,
      if (employee.tableId != null) employee.tableId!,
    };
    const pageSize = 100;
    var offset = 0;
    var total = 0;
    final matching = <Task>[];

    do {
      final page = await _taskService.getTasks(
        accessToken: token,
        limit: pageSize,
        offset: offset,
      );
      total = page.count;
      matching.addAll(page.items.where((task) => task.assignedTo.any(
            (assignedId) => employeeIds.contains(assignedId),
          )));
      offset += page.items.length;
      if (page.items.isEmpty) break;
    } while (offset < total);

    return matching;
  }

  @override
  Future<List<WorkReport>> loadWorkReports(Employee employee) async {
    final employeeId = employee.tableId ?? employee.id;
    final result = await _workReportService.getWorkReports(
      await _token(),
      employeeId: employeeId,
      limit: 100,
      offset: 0,
    );
    return result;
  }

  @override
  Future<WorkReport> loadWorkReport(String reportId) async {
    return _workReportService.getWorkReportById(await _token(), reportId);
  }
}
