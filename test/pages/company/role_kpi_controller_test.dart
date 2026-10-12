import 'dart:async';

import 'package:bomach_os/pages/company/controllers/role_kpi_controller.dart';
import 'package:bomach_os/src/model/role_kpi_model.dart';
import 'package:bomach_os/src/services/role_kpi_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

typedef KpiPage = ({List<RoleKpi> list, int count});
typedef KpiListCall = ({String? search, int? roleId, int limit, int offset});

class _FakeRoleKpiService extends RoleKpiService {
  _FakeRoleKpiService() : super(dioOverride: Dio());

  final calls = <KpiListCall>[];
  Future<KpiPage> Function(KpiListCall call)? respond;

  @override
  Future<KpiPage> listAllRoleKpis(
    String token, {
    String? search,
    int? roleId,
    int limit = 50,
    int offset = 0,
  }) {
    final call = (
      search: search,
      roleId: roleId,
      limit: limit,
      offset: offset,
    );
    calls.add(call);
    return respond?.call(call) ?? Future.value((list: <RoleKpi>[], count: 0));
  }
}

RoleKpi _kpi(int roleId, int id) => RoleKpi(
      id: id,
      roleId: roleId,
      metricId: id + 100,
      trackingMode: 'manual',
      period: 'monthly',
    );

void main() {
  test('global search keeps assignments from different roles and paginates',
      () async {
    final service = _FakeRoleKpiService()
      ..respond = (_) async => (list: [_kpi(4, 1), _kpi(9, 2)], count: 5);
    final controller = RoleKpiController(
      service: service,
      tokenReader: () async => 'test-token',
    )..limit = 2;

    await controller.fetchAllKpis(refresh: true, search: 'visits');

    expect(controller.kpis.map((kpi) => kpi.roleId), [4, 9]);
    expect(service.calls.single.search, 'visits');
    expect(service.calls.single.roleId, isNull);
    expect(controller.totalCount, 5);

    await controller.setAllKpisPage(1);
    expect(service.calls.last.offset, 2);
    expect(service.calls.last.search, 'visits');
  });

  test('global KPI fetch errors are visible and can be retried', () async {
    final service = _FakeRoleKpiService();
    var shouldFail = true;
    service.respond = (_) async {
      if (shouldFail) throw Exception('API Error: 500 - unavailable');
      return (list: [_kpi(5, 3)], count: 1);
    };
    final controller = RoleKpiController(
      service: service,
      tokenReader: () async => 'test-token',
    );

    await controller.fetchAllKpis(refresh: true);
    expect(
        controller.errorMessage.value, 'Server error. Please try again later.');

    shouldFail = false;
    await controller.fetchAllKpis(refresh: true);
    expect(controller.errorMessage.value, isEmpty);
    expect(controller.kpis.single.roleId, 5);
  });

  test('a slower prior search cannot replace the latest results', () async {
    final oldResult = Completer<KpiPage>();
    final newResult = Completer<KpiPage>();
    final service = _FakeRoleKpiService()
      ..respond =
          (call) => call.search == 'old' ? oldResult.future : newResult.future;
    final controller = RoleKpiController(
      service: service,
      tokenReader: () async => 'test-token',
    );

    final oldRequest = controller.fetchAllKpis(refresh: true, search: 'old');
    await Future<void>.delayed(Duration.zero);
    final newRequest = controller.fetchAllKpis(refresh: true, search: 'new');
    await Future<void>.delayed(Duration.zero);

    newResult.complete((list: [_kpi(8, 2)], count: 1));
    await newRequest;
    oldResult.complete((list: [_kpi(3, 1)], count: 1));
    await oldRequest;

    expect(controller.kpis.single.roleId, 8);
    expect(controller.isLoading.value, isFalse);
  });
}
