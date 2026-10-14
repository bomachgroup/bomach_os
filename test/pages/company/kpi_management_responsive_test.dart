import 'package:bomach_os/pages/company/controllers/role_kpi_controller.dart';
import 'package:bomach_os/pages/company/kpi_management.dart';
import 'package:bomach_os/src/model/role_kpi_model.dart';
import 'package:bomach_os/src/services/permission_service.dart';
import 'package:bomach_os/src/services/role_kpi_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _FakeRoleKpiService extends RoleKpiService {
  _FakeRoleKpiService() : super(dioOverride: Dio());

  @override
  Future<({List<RoleKpi> list, int count})> listAllRoleKpis(
    String token, {
    String? search,
    int? roleId,
    int limit = 50,
    int offset = 0,
  }) async =>
      (
        list: [
          const RoleKpi(
            id: 9,
            roleId: 4,
            metricId: 3,
            metric: KPIMetricMinimal(
              id: 3,
              name: 'Qualified leads',
              description: 'Qualified leads generated for active projects.',
              unit: 'percentage',
            ),
            trackingMode: 'manual',
            targetValue: 45,
            weight: 25,
            period: 'monthly',
          ),
        ],
        count: 1,
      );
}

void main() {
  tearDown(Get.reset);

  testWidgets('KPI management cards fit phone, tablet, and desktop widths',
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
      Get.put(PermissionService()).testInjectPermissions({
        'role_kpis': {'create', 'update', 'delete'},
        'kpis': {'list'},
      });
      Get.put(
        RoleKpiController(
          service: _FakeRoleKpiService(),
          tokenReader: () async => 'test-token',
        ),
        tag: 'kpi_management',
      );

      await tester.pumpWidget(
        const GetMaterialApp(home: Scaffold(body: KpiManagementPage())),
      );
      await tester.pumpAndSettle();

      expect(find.text('Qualified leads'), findsOneWidget,
          reason: 'KPI card should render at $viewport');
      expect(find.text('45%'), findsOneWidget,
          reason:
              'Percentage targets should use the percent symbol at $viewport');
      expect(find.text('45 percentage'), findsNothing);
      expect(tester.takeException(), isNull,
          reason: 'KPI management should fit at $viewport');

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    }

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
