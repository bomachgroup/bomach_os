import 'package:bomach_os/pages/hr/employee_profile_data.dart';
import 'package:bomach_os/pages/hr/models/work_report_model.dart';
import 'package:bomach_os/pages/operations/models/models.dart';
import 'package:bomach_os/src/model/employees_model.dart';
import 'package:bomach_os/src/services/audit_log_service.dart';
import 'package:bomach_os/src/services/hr/work_report_service.dart';
import 'package:bomach_os/src/services/operations/tasks_services.dart';
import 'package:flutter_test/flutter_test.dart';

class _AuditFake extends AuditLogService {
  String? userId;

  _AuditFake() : super();

  @override
  Future<({List<AuditLogResponse> items, int total})> getAuditLogs(
    String token, {
    String? search,
    String? userId,
    String? auditType,
    String? auditStatus,
    String? startDate,
    String? endDate,
    int limit = 100,
    int offset = 0,
  }) async {
    this.userId = userId;
    return (items: <AuditLogResponse>[], total: 0);
  }
}

class _TaskFake extends TaskService {
  _TaskFake() : super(baseUrl: 'https://example.test');

  @override
  Future<({List<Task> items, int count})> getTasks({
    required String accessToken,
    int? projectId,
    String? status,
    String? priority,
    String? search,
    int limit = 100,
    int offset = 0,
  }) async {
    return (
      items: [
        _task(1, ['42']),
        _task(2, ['7']),
      ],
      count: 2,
    );
  }

  static Task _task(int id, List<String> assignedTo) => Task(
        id: id,
        projectId: 0,
        milestoneId: null,
        name: 'Task $id',
        description: '',
        status: 'pending',
        priority: 'medium',
        assignedTo: assignedTo,
        dueDate: '',
        estimatedHours: 0,
        createdAt: '',
        updatedAt: '',
      );
}

class _WorkReportFake extends WorkReportService {
  String? employeeId;

  _WorkReportFake() : super();

  @override
  Future<List<WorkReport>> getWorkReports(
    String token, {
    String? search,
    String? employeeId,
    String? status,
    String? mood,
    String? dateFrom,
    String? dateTo,
    int limit = 100,
    int offset = 0,
  }) async {
    this.employeeId = employeeId;
    return <WorkReport>[];
  }
}

void main() {
  test('maps audit to user id and work reports to employee table id', () async {
    final audit = _AuditFake();
    final workReports = _WorkReportFake();
    final source = ApiEmployeeProfileDataSource(
      auditLogService: audit,
      taskService: _TaskFake(),
      workReportService: workReports,
      tokenProvider: () async => 'test-token',
    );
    final employee = Employee(
      id: '42',
      tableId: '9001',
      firstName: 'Ada',
      lastName: 'Okafor',
      email: 'ada@example.com',
    );

    await source.loadActivity(employee);
    final tasks = await source.loadTasks(employee);
    await source.loadWorkReports(employee);

    expect(audit.userId, '42');
    expect(tasks.map((task) => task.id), [1]);
    expect(workReports.employeeId, '9001');
  });
}
