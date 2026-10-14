import 'package:bomach_os/pages/company/controllers/role_kpi_controller.dart';
import 'package:bomach_os/pages/company/widget/kpi_dialogs.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/src/model/kpi_metric_model.dart';
import 'package:bomach_os/src/model/role_kpi_model.dart';
import 'package:bomach_os/src/services/permission_service.dart';
import 'package:bomach_os/src/services/role_kpi_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _FakeRoleKpiService extends RoleKpiService {
  _FakeRoleKpiService() : super(dioOverride: Dio());

  final Map<int, List<RoleKpi>> assignments = {};
  Future<RoleKpi> Function(int roleId, Map<String, dynamic> payload)? onCreate;
  Future<RoleKpi> Function(int roleId, int id, Map<String, dynamic> payload)?
      onUpdate;
  Future<void> Function(int roleId, int id)? onDelete;

  @override
  Future<({List<RoleKpi> list, int count})> listRoleKpis(
    String token, {
    required int roleId,
    String? category,
    bool? isActive,
    int limit = 100,
    int offset = 0,
  }) async {
    final rows = assignments[roleId] ?? const <RoleKpi>[];
    final page = rows.skip(offset).take(limit).toList();
    return (list: page, count: rows.length);
  }

  @override
  Future<({List<RoleKpi> list, int count})> listAllRoleKpis(
    String token, {
    String? search,
    int? roleId,
    int limit = 50,
    int offset = 0,
  }) async =>
      (list: <RoleKpi>[], count: 0);

  @override
  Future<RoleKpi> createRoleKpi(
      String token, int roleId, Map<String, dynamic> payload) {
    return onCreate?.call(roleId, payload) ??
        Future.value(_roleKpi(roleId: roleId, id: 30, metricId: 10));
  }

  @override
  Future<RoleKpi> updateRoleKpi(
      String token, int roleId, int id, Map<String, dynamic> payload) {
    return onUpdate?.call(roleId, id, payload) ??
        Future.value(_roleKpi(roleId: roleId, id: id, metricId: 10));
  }

  @override
  Future<void> deleteRoleKpi(String token, int roleId, int id) {
    return onDelete?.call(roleId, id) ?? Future.value();
  }
}

RoleKpi _roleKpi({
  required int roleId,
  required int id,
  required int metricId,
  String metricName = 'Quality reviews',
}) =>
    RoleKpi(
      id: id,
      roleId: roleId,
      metricId: metricId,
      metric: KPIMetricMinimal(
        id: metricId,
        name: metricName,
        description: '',
        unit: 'reviews',
      ),
      trackingMode: 'manual',
      period: 'monthly',
    );

const _metrics = [
  KPIMetric(id: 10, name: 'Quality reviews', description: '', unit: 'reviews'),
  KPIMetric(id: 11, name: 'Client visits', description: '', unit: 'visits'),
];

void main() {
  late _FakeRoleKpiService service;
  late RoleKpiController controller;

  setUp(() {
    Get.put(PermissionService()).loadSuperAdminPermissions();
    service = _FakeRoleKpiService();
    controller = RoleKpiController(
      service: service,
      tokenReader: () async => 'test-token',
    );
  });

  tearDown(Get.reset);

  Future<void> pumpHost(
    WidgetTester tester, {
    required int roleId,
    RoleKpi? kpi,
    bool useEditorHelper = false,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () {
                if (useEditorHelper) {
                  showKpiEditorDialog(
                    context,
                    ctrl: controller,
                    kpi: kpi,
                    presetRoleId: roleId,
                    loadMetrics: () async => List<KPIMetric>.of(_metrics),
                  );
                } else {
                  showDialog<void>(
                    context: context,
                    builder: (_) => CreateEditKpiDialog(
                      ctrl: controller,
                      kpi: kpi,
                      presetRoleId: roleId,
                      loadMetrics: () async => List<KPIMetric>.of(_metrics),
                    ),
                  );
                }
              },
              child: const Text('Open editor'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open editor'));
    await tester.pumpAndSettle();
  }

  Future<void> selectMetric(WidgetTester tester, String name) async {
    await tester.tap(find.text('Select a metric'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(name).last);
    await tester.pumpAndSettle();
  }

  testWidgets('assigned metric is disabled and offers edit for its role',
      (tester) async {
    service.assignments[1] = [_roleKpi(roleId: 1, id: 4, metricId: 10)];
    await pumpHost(tester, roleId: 1);

    await tester.tap(find.text('Select a metric'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Already assigned'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(find.text('Edit KPI'), findsOneWidget);
    expect(find.text('Quality reviews'), findsAtLeastNWidgets(1));
    await tester.tap(find.text('Quality reviews'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Already assigned'), findsNothing);
    expect(find.text('Quality reviews'), findsAtLeastNWidgets(1));
  });

  testWidgets('role KPI editor and metric picker fit common widths',
      (tester) async {
    const viewports = [
      Size(320, 740),
      Size(390, 844),
      Size(768, 1024),
      Size(1440, 900),
    ];

    for (final viewport in viewports) {
      Get.reset();
      Get.put(PermissionService()).loadSuperAdminPermissions();
      service = _FakeRoleKpiService();
      controller = RoleKpiController(
        service: service,
        tokenReader: () async => 'test-token',
      );
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = viewport;
      await pumpHost(tester, roleId: 2);

      await tester.tap(find.text('Select a metric'));
      await tester.pumpAndSettle();
      expect(find.byType(DialogScaffold), findsNWidgets(2));
      expect(tester.takeException(), isNull,
          reason: 'Metric picker should fit at $viewport');
      await tester.tap(find.text('Quality reviews').last);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull,
          reason: 'KPI editor should fit at $viewport');

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    }

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('a metric assigned to one role remains selectable for another',
      (tester) async {
    service.assignments[1] = [_roleKpi(roleId: 1, id: 4, metricId: 10)];
    service.assignments[2] = [];
    await pumpHost(tester, roleId: 2);

    await selectMetric(tester, 'Quality reviews');

    expect(find.text('Quality reviews'), findsOneWidget);
    expect(find.textContaining('Already assigned'), findsNothing);
  });

  testWidgets(
      '409 stays in form, shows backend detail, and clears saving state',
      (tester) async {
    service.onCreate = (_, __) async {
      throw Exception(
          'API Error: 409 - This metric is already assigned to this role.');
    };
    await pumpHost(tester, roleId: 1);
    await selectMetric(tester, 'Quality reviews');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add KPI'));
    await tester.pumpAndSettle();

    expect(find.byType(CreateEditKpiDialog), findsOneWidget);
    expect(find.text('This metric is already assigned to this role.'),
        findsOneWidget);
    expect(controller.isSaving.value, isFalse);
  });

  testWidgets('successful create closes the form and shows success feedback',
      (tester) async {
    service.onCreate = (roleId, payload) async => _roleKpi(
          roleId: roleId,
          id: 30,
          metricId: payload['metric_id'] as int,
        );
    await pumpHost(tester, roleId: 2, useEditorHelper: true);
    await selectMetric(tester, 'Quality reviews');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add KPI'));
    await tester.pumpAndSettle();

    expect(find.byType(CreateEditKpiDialog), findsNothing);
    expect(find.text('KPI added to the role.'), findsOneWidget);
  });

  testWidgets('successful update closes the form and shows success feedback',
      (tester) async {
    final existing = _roleKpi(roleId: 2, id: 7, metricId: 10);
    service.assignments[2] = [existing];
    service.onUpdate = (roleId, id, payload) async => _roleKpi(
          roleId: roleId,
          id: id,
          metricId: payload['metric_id'] as int,
        );
    await pumpHost(
      tester,
      roleId: 2,
      kpi: existing,
      useEditorHelper: true,
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Save Changes'));
    await tester.pumpAndSettle();

    expect(find.byType(CreateEditKpiDialog), findsNothing);
    expect(find.text('KPI updated.'), findsOneWidget);
  });

  testWidgets('delete failure remains in confirmation with clear error',
      (tester) async {
    var shouldFail = true;
    service.onDelete = (_, __) async {
      if (shouldFail) throw Exception('API Error: 409 - Assignment is in use.');
    };
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showRemoveKpiConfirmation(
                context,
                ctrl: controller,
                roleId: 1,
                id: 4,
                metricName: 'Quality reviews',
              ),
              child: const Text('Remove KPI'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Remove KPI'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove from role'));
    await tester.pumpAndSettle();

    expect(find.text('Remove KPI from role?'), findsOneWidget);
    expect(find.text('Assignment is in use.'), findsOneWidget);

    shouldFail = false;
    await tester.tap(find.text('Remove from role'));
    await tester.pumpAndSettle();
    expect(find.text('Remove KPI from role?'), findsNothing);
    expect(find.text('KPI removed from the role.'), findsOneWidget);
  });
}
