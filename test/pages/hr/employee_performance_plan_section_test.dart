import 'package:bomach_os/pages/hr/widget/employee_performance_plan_section.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/src/services/employee_performance_plan_service.dart';
import 'package:bomach_os/src/services/permission_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _FakePerformancePlanService extends EmployeePerformancePlanService {
  _FakePerformancePlanService() : super(dioOverride: Dio());

  int previewCount = 0;
  int applyCount = 0;
  bool returnStaleOnce = false;
  List<dynamic> kpis = <dynamic>[];
  List<dynamic> targets = <dynamic>[];

  @override
  Future<Map<String, dynamic>> getEmployee(
    String token,
    int userId, {
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async =>
      {
        'employee_id': userId,
        'role_id': 7,
        'period_start': '2026-10-01',
        'period_end': '2026-10-31',
        'revision': null,
        'source': 'role_default',
        'kpis': kpis,
        'targets': targets,
      };

  @override
  Future<Map<String, dynamic>> previewRefresh(
    String token,
    int userId, {
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    previewCount++;
    final name = previewCount == 1 ? 'New quality KPI' : 'Updated quality KPI';
    return {
      'preview_token': 'preview-$previewCount',
      'diff': {
        'added': [
          {'kind': 'kpi', 'name': name}
        ],
        'updated': <dynamic>[],
        'retired': <dynamic>[],
        'detached': <dynamic>[],
        'preserved': <dynamic>[],
      },
    };
  }

  @override
  Future<Map<String, dynamic>> applyRefresh(
    String token,
    int userId, {
    required DateTime periodStart,
    required DateTime periodEnd,
    required String reason,
    required String previewToken,
  }) async {
    applyCount++;
    if (returnStaleOnce && applyCount == 1) {
      throw const EmployeePerformancePlanApiException(
        'This preview is stale.',
        statusCode: 409,
      );
    }
    return {'revision': 8};
  }

  @override
  Future<List<Map<String, dynamic>>> history(String token, int userId) async =>
      [
        {
          'id': 3,
          'action': 'carry_forward',
          'change_scope': 'carry_forward',
          'period_start': '2026-10-01',
          'period_end': '2026-10-31',
          'reason': 'Adjusted workload',
          'created_at': '2026-10-05T10:30:00Z',
          'actor__email': 'manager@example.com',
          'before_snapshot': {
            'kpis': [
              {
                'item_key': 'kpi-one',
                'config': {'name': 'New leads', 'target_value': '10'}
              }
            ],
            'targets': <dynamic>[],
          },
          'after_snapshot': {
            'kpis': [
              {
                'item_key': 'kpi-one',
                'config': {'name': 'New leads', 'target_value': '12'}
              }
            ],
            'targets': <dynamic>[],
          },
        }
      ];
}

void main() {
  late PermissionService permissions;

  setUp(() {
    Get.reset();
    permissions = Get.put(PermissionService());
    permissions.testInjectPermissions({
      'employee_kpis': {'update'},
      'employee_targets': {'update'},
    });
  });

  tearDown(Get.reset);

  Future<void> pumpPlan(
    WidgetTester tester,
    _FakePerformancePlanService service,
  ) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: EmployeePerformancePlanSection(
            employeeUserId: 42,
            service: service,
            tokenReader: () async => 'test-token',
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('blank refresh reason keeps the dialog open with an error',
      (tester) async {
    final service = _FakePerformancePlanService();
    await pumpPlan(tester, service);

    await tester.ensureVisible(find.text('Preview role refresh'));
    await tester.tap(find.text('Preview role refresh'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('New quality KPI'), findsOneWidget);

    await tester.tap(find.text('Apply refresh'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const Key('refresh-dialog-reason')), findsOneWidget);
    expect(find.text('Enter a reason before applying this refresh.'),
        findsOneWidget);
    expect(service.applyCount, 0);
  });

  testWidgets('stale refresh updates the preview and waits for reconfirmation',
      (tester) async {
    final service = _FakePerformancePlanService()..returnStaleOnce = true;
    await pumpPlan(tester, service);

    await tester.ensureVisible(find.text('Preview role refresh'));
    await tester.tap(find.text('Preview role refresh'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(
        find.byKey(const Key('refresh-dialog-reason')), 'Workload change');
    await tester.tap(find.text('Apply refresh'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const Key('refresh-dialog-error')), findsOneWidget);
    expect(find.textContaining('Review the updated changes'), findsOneWidget);
    expect(find.textContaining('Updated quality KPI'), findsOneWidget);
    expect(find.byKey(const Key('refresh-dialog-reason')), findsOneWidget);
    expect(service.applyCount, 1);

    await tester.tap(find.text('Apply refresh'));
    await tester.pumpAndSettle();
    expect(service.applyCount, 2);
    expect(find.text('Refresh from role defaults'), findsNothing);
  });

  testWidgets('history exposes the timestamp and before-after values',
      (tester) async {
    final service = _FakePerformancePlanService();
    await pumpPlan(tester, service);

    await tester.ensureVisible(find.text('Change history'));
    await tester.tap(find.text('Change history'));
    await tester.pumpAndSettle();
    expect(find.textContaining('05 Oct 2026'), findsOneWidget);
    await tester.ensureVisible(find.textContaining('manager@example.com'));
    await tester.tap(find.textContaining('manager@example.com'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Target Value: 10 → 12'), findsOneWidget);
  });

  testWidgets('employee-only items are not labeled as inherited or customized',
      (tester) async {
    final service = _FakePerformancePlanService()
      ..kpis = [
        {
          'source': 'employee',
          'is_customized': true,
          'actual_value': '2.5',
          'config': {
            'name': 'Personal KPI',
            'role_kpi_metric_id': null,
            'target_value': '5',
            'unit': 'percentage',
            'period': 'monthly',
            'is_active': true,
          },
        }
      ]
      ..targets = [
        {
          'source': 'employee',
          'is_customized': true,
          'config': {
            'title': 'Personal target',
            'role_target_template_id': null,
            'target_value': '3',
            'unit': 'deliverables',
            'period': 'monthly',
            'is_active': true,
          },
        }
      ];
    await pumpPlan(tester, service);

    expect(find.textContaining('Employee-only'), findsNWidgets(2));
    expect(find.textContaining('Inherited'), findsNothing);
    expect(find.textContaining('Customized'), findsNothing);
    expect(find.text('5%'), findsOneWidget);
    expect(find.text('2.50%'), findsOneWidget);
  });

  testWidgets('refresh requires confirmation before replacing a draft',
      (tester) async {
    final service = _FakePerformancePlanService();
    await pumpPlan(tester, service);

    await tester.ensureVisible(find.text('Add KPI'));
    await tester.tap(find.text('Add KPI'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const Key('employee-plan-kpi-name')), 'Draft KPI');
    await tester.tap(find.text('Add to draft'));
    await tester.pumpAndSettle();
    expect(find.text('Draft KPI'), findsOneWidget);

    await tester.ensureVisible(find.byTooltip('Refresh plan'));
    await tester.tap(find.byTooltip('Refresh plan'));
    await tester.pumpAndSettle();
    expect(find.text('Discard unsaved plan changes?'), findsOneWidget);
    await tester.tap(find.text('Keep editing'));
    await tester.pumpAndSettle();
    expect(find.text('Draft KPI'), findsOneWidget);

    await tester.ensureVisible(find.byTooltip('Refresh plan'));
    await tester.tap(find.byTooltip('Refresh plan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard draft'));
    await tester.pumpAndSettle();
    expect(find.text('Draft KPI'), findsNothing);
  });

  testWidgets('KPI editor validates sequence bounds and closes safely',
      (tester) async {
    final service = _FakePerformancePlanService();
    await pumpPlan(tester, service);

    await tester.ensureVisible(find.text('Add KPI'));
    await tester.tap(find.text('Add KPI'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const Key('employee-plan-kpi-name')), 'UI QA KPI');
    await tester.ensureVisible(find.text('Plan settings').first);
    await tester.tap(find.text('Plan settings').first);
    await tester.pumpAndSettle();
    await tester
        .ensureVisible(find.byKey(const Key('employee-plan-kpi-sequence')));
    await tester.enterText(
        find.byKey(const Key('employee-plan-kpi-sequence')), '2147483648');
    await tester.tap(find.text('Add to draft'));
    await tester.pumpAndSettle();

    expect(
      find.text('Display order must be between 1 and 2,147,483,647.'),
      findsOneWidget,
    );
    expect(find.byType(DialogScaffold), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.enterText(
        find.byKey(const Key('employee-plan-kpi-sequence')), '2147483647');
    await tester.tap(find.text('Add to draft'));
    await tester.pumpAndSettle();

    expect(find.text('UI QA KPI'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('target editor validates sequence bounds and closes safely',
      (tester) async {
    final service = _FakePerformancePlanService();
    await pumpPlan(tester, service);

    await tester.ensureVisible(find.text('Add target'));
    await tester.tap(find.text('Add target'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const Key('employee-plan-target-title')), 'UI QA target');
    await tester.enterText(
        find.byKey(const Key('employee-plan-target-value')), '5');
    await tester.ensureVisible(find.text('Plan settings').first);
    await tester.tap(find.text('Plan settings').first);
    await tester.pumpAndSettle();
    await tester
        .ensureVisible(find.byKey(const Key('employee-plan-target-sequence')));
    await tester.enterText(
        find.byKey(const Key('employee-plan-target-sequence')), '2147483648');
    await tester.tap(find.text('Add to draft'));
    await tester.pumpAndSettle();

    expect(
      find.text('Display order must be between 1 and 2,147,483,647.'),
      findsOneWidget,
    );
    expect(find.byType(DialogScaffold), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.enterText(
        find.byKey(const Key('employee-plan-target-sequence')), '2147483647');
    await tester.tap(find.text('Add to draft'));
    await tester.pumpAndSettle();

    expect(find.text('UI QA target'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('employee plan editors fit phone, tablet, and desktop widths',
      (tester) async {
    final service = _FakePerformancePlanService();
    const viewports = [
      Size(320, 740),
      Size(390, 844),
      Size(768, 1024),
      Size(1440, 900),
    ];

    for (final viewport in viewports) {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = viewport;
      await pumpPlan(tester, service);

      await tester.ensureVisible(find.text('Add KPI'));
      await tester.tap(find.text('Add KPI'));
      await tester.pumpAndSettle();
      expect(find.byType(DialogScaffold), findsOneWidget,
          reason: 'KPI editor should open at $viewport');
      expect(tester.takeException(), isNull,
          reason: 'KPI editor should fit at $viewport');
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Add target'));
      await tester.tap(find.text('Add target'));
      await tester.pumpAndSettle();
      expect(find.byType(DialogScaffold), findsOneWidget,
          reason: 'Target editor should open at $viewport');
      expect(tester.takeException(), isNull,
          reason: 'Target editor should fit at $viewport');
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    }

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
