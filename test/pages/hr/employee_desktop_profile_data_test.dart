import 'package:bomach_os/pages/hr/employee_profile.dart';
import 'package:bomach_os/pages/hr/employee_profile_data.dart';
import 'package:bomach_os/src/model/employees_model.dart';
import 'package:bomach_os/src/services/audit_log_service.dart';
import 'package:bomach_os/pages/operations/models/models.dart';
import 'package:bomach_os/pages/hr/models/work_report_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeEmployeeProfileDataSource
    implements EmployeeProfileDataSource {
  @override
  Future<List<AuditLogResponse>> loadActivity(Employee employee) async => [
        AuditLogResponse(
          id: 1,
          activity: 'Updated personal information',
          auditType: 'employee',
          auditTypeDisplay: 'Employee',
          auditStatus: 'success',
          auditStatusDisplay: 'Success',
          createdAt: '2026-09-14T10:00:00Z',
          updatedAt: '2026-09-14T10:00:00Z',
        ),
      ];

  @override
  Future<List<Task>> loadTasks(Employee employee) async => [
        Task(
          id: 5,
          projectId: 0,
          milestoneId: null,
          name: 'Prepare monthly report',
          description: 'Compile the monthly report',
          status: 'pending',
          priority: 'high',
          assignedTo: [employee.id],
          dueDate: '2026-09-20',
          estimatedHours: 3,
          createdAt: '2026-09-01T10:00:00Z',
          updatedAt: '2026-09-01T10:00:00Z',
        ),
      ];

  @override
  Future<List<WorkReport>> loadWorkReports(Employee employee) async => [
        WorkReport(
          id: '12',
          employeeId: int.parse(employee.id),
          day: DateTime(2026, 9, 14),
          hoursWorked: 7.5,
          operationalBase: 'Head Office',
          workActivities: 'Completed customer follow-ups',
          taskDetails: 'Followed up with three customers',
          planNextDay: 'Prepare the weekly summary',
          status: 'submitted',
          feedback: null,
          rating: null,
        ),
      ];

  @override
  Future<WorkReport> loadWorkReport(String reportId) async =>
      (await loadWorkReports(_employee())).single;
}

Employee _employee() => Employee(
      id: '42',
      firstName: 'Ada',
      lastName: 'Okafor',
      email: 'ada@example.com',
      designation: 'Product Designer',
      isActive: true,
      isVerified: true,
    );

void main() {
  testWidgets('desktop profile exposes only API-backed sections',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 1024);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(splashFactory: NoSplash.splashFactory),
      home: EmployeeDesktopProfileLayout(
        employee: _employee(),
        dataSource: _FakeEmployeeProfileDataSource(),
      ),
    ));

    expect(find.text('Projects'), findsNothing);
    expect(find.text('Activity'), findsOneWidget);
    expect(find.text('Tasks'), findsOneWidget);
    expect(find.text('Work Reports'), findsOneWidget);
    expect(find.text('Reports Files'), findsNothing);
  });

  testWidgets('desktop profile loads activity, tasks, and work reports',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 1024);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(splashFactory: NoSplash.splashFactory),
      home: EmployeeDesktopProfileLayout(
        employee: _employee(),
        dataSource: _FakeEmployeeProfileDataSource(),
      ),
    ));

    await tester.tap(find.text('Activity'));
    await tester.pumpAndSettle();
    expect(find.text('Updated personal information'), findsOneWidget);

    await tester.tap(find.text('Tasks'));
    await tester.pumpAndSettle();
    expect(find.text('Prepare monthly report'), findsOneWidget);

    await tester.tap(find.text('Work Reports'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Completed customer follow-ups'), findsOneWidget);
  });
}
