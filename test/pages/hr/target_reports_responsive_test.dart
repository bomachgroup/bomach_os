import 'package:bomach_os/pages/hr/controller/target_report_controller.dart';
import 'package:bomach_os/pages/hr/target_reports.dart';
import 'package:bomach_os/src/model/employee_target_model.dart';
import 'package:bomach_os/src/model/target_report_model.dart';
import 'package:bomach_os/src/services/target_report_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _FakeTargetReportService extends TargetReportService {
  _FakeTargetReportService() : super(dioOverride: Dio());

  @override
  Future<List<EmployeeTarget>> listMyAssignedTargets(String token) async => [];

  @override
  Future<({List<TargetReport> list, int count})> listMine(
    String token, {
    int? employeeTargetId,
    String? status,
    String? periodStart,
    String? periodEnd,
    String? submittedFrom,
    String? submittedTo,
    String? search,
    int limit = 100,
    int offset = 0,
  }) async =>
      (
        list: [
          TargetReport(
            id: 1,
            employeeTargetId: 3,
            summary:
                'Completed a long multi-step deliverable across the reporting period.',
            progressValue: 18,
            status: 'rejected',
            rejectionReason:
                'Please attach the review evidence before resubmitting this progress report.',
            targetTitle:
                'Complete customer onboarding and quality review documentation',
            targetValue: 25,
            targetUnit: 'approved customer records per reporting period',
            targetPeriod: 'monthly',
            employeeCode: 'BOM-0003',
            createdAt: DateTime.utc(2026, 10, 5),
            updatedAt: null,
            reviewedAt: null,
          ),
        ],
        count: 1,
      );
}

void main() {
  tearDown(Get.reset);

  testWidgets('target report page and submission dialog fit common widths',
      (tester) async {
    const viewports = [
      Size(320, 740),
      Size(390, 844),
      Size(768, 1024),
      Size(1440, 900),
    ];

    for (final viewport in viewports) {
      Get.reset();
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = viewport;
      Get.put(
        TargetReportController(
          service: _FakeTargetReportService(),
          tokenReader: () async => 'test-token',
        ),
      );
      await tester.pumpWidget(
        const GetMaterialApp(
          home: Scaffold(body: TargetReportsPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(
          find.textContaining('Complete customer onboarding'), findsOneWidget,
          reason: 'Report card should render at $viewport');
      expect(tester.takeException(), isNull,
          reason: 'Target report page should fit at $viewport');

      await tester.ensureVisible(find.text('Submit progress'));
      await tester.tap(find.text('Submit progress').first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull,
          reason: 'Progress dialog should fit at $viewport');
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    }

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
