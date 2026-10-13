import 'dart:async';

import 'package:bomach_os/pages/company/controllers/role_kpi_controller.dart';
import 'package:bomach_os/src/model/role_kpi_model.dart';
import 'package:bomach_os/src/services/role_kpi_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

typedef KpiPage = ({List<RoleKpi> list, int count});
typedef KpiListCall = ({String? search, int? roleId, int limit, int offset});
typedef RoleKpiPage = ({int roleId, int limit, int offset});

class _FakeRoleKpiService extends RoleKpiService {
  _FakeRoleKpiService() : super(dioOverride: Dio());

  final calls = <KpiListCall>[];
  final roleCalls = <RoleKpiPage>[];
  Future<KpiPage> Function(KpiListCall call)? respond;
  Future<KpiPage> Function(RoleKpiPage call)? respondRole;
  Future<RoleKpi> Function(int roleId, Map<String, dynamic> payload)? create;
  Future<RoleKpi> Function(int roleId, int id, Map<String, dynamic> payload)?
      update;
  Future<void> Function(int roleId, int id)? delete;

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

  @override
  Future<KpiPage> listRoleKpis(
    String token, {
    required int roleId,
    String? category,
    bool? isActive,
    int limit = 100,
    int offset = 0,
  }) {
    final call = (roleId: roleId, limit: limit, offset: offset);
    roleCalls.add(call);
    return respondRole?.call(call) ??
        Future.value((list: <RoleKpi>[], count: 0));
  }

  @override
  Future<RoleKpi> createRoleKpi(
      String token, int roleId, Map<String, dynamic> payload) {
    return create?.call(roleId, payload) ?? Future.value(_kpi(roleId, 99));
  }

  @override
  Future<RoleKpi> updateRoleKpi(
      String token, int roleId, int kpiId, Map<String, dynamic> payload) {
    return update?.call(roleId, kpiId, payload) ??
        Future.value(_kpi(roleId, kpiId));
  }

  @override
  Future<void> deleteRoleKpi(String token, int roleId, int kpiId) {
    return delete?.call(roleId, kpiId) ?? Future.value();
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

  test('global create refreshes all roles and inserts the new row immediately',
      () async {
    final refresh = Completer<KpiPage>();
    var globalCalls = 0;
    const created = RoleKpi(
      id: 22,
      roleId: 9,
      metricId: 501,
      trackingMode: 'manual',
      period: 'monthly',
    );
    final service = _FakeRoleKpiService()
      ..respond = (_) {
        globalCalls++;
        if (globalCalls == 1) {
          return Future.value((list: [_kpi(4, 1)], count: 1));
        }
        return refresh.future;
      }
      ..create = (_, __) async => created;
    final controller = RoleKpiController(
      service: service,
      tokenReader: () async => 'test-token',
    );
    await controller.fetchAllKpis();

    final result = await controller.createKpi(
      roleId: 9,
      metricId: 501,
      trackingMode: 'manual',
      period: 'monthly',
    );
    await Future<void>.delayed(Duration.zero);

    expect(result.succeeded, isTrue);
    expect(controller.kpis.map((item) => item.id), [22, 1]);
    expect(controller.isLoading.value, isFalse);
    expect(controller.isRefreshing.value, isTrue);
    expect(service.roleCalls, isEmpty);

    refresh.complete((list: [created, _kpi(4, 1)], count: 2));
    await Future<void>.delayed(Duration.zero);
    expect(controller.kpis.map((item) => item.id), [22, 1]);
    expect(controller.isRefreshing.value, isFalse);
  });

  test('duplicate assignment returns inline-ready 409 and resets saving state',
      () async {
    final service = _FakeRoleKpiService()
      ..create = (_, __) async {
        throw Exception('API Error: 409 - Metric already assigned to role.');
      };
    final controller = RoleKpiController(
      service: service,
      tokenReader: () async => 'test-token',
    );

    final result = await controller.createKpi(
      roleId: 3,
      metricId: 501,
      trackingMode: 'manual',
      period: 'monthly',
    );

    expect(result.succeeded, isFalse);
    expect(result.statusCode, 409);
    expect(result.message, 'Metric already assigned to role.');
    expect(controller.isSaving.value, isFalse);
  });

  test('delete removes the row immediately and refreshes without full loading',
      () async {
    final refresh = Completer<KpiPage>();
    var globalCalls = 0;
    final service = _FakeRoleKpiService()
      ..respond = (_) {
        globalCalls++;
        return globalCalls == 1
            ? Future.value((list: [_kpi(2, 1), _kpi(2, 2)], count: 2))
            : refresh.future;
      };
    final controller = RoleKpiController(
      service: service,
      tokenReader: () async => 'test-token',
    );
    await controller.fetchAllKpis();

    final result = await controller.deleteKpi(roleId: 2, id: 1);
    await Future<void>.delayed(Duration.zero);

    expect(result.succeeded, isTrue);
    expect(controller.kpis.map((item) => item.id), [2]);
    expect(controller.isLoading.value, isFalse);
    expect(controller.isRefreshing.value, isTrue);

    refresh.complete((list: [_kpi(2, 2)], count: 1));
    await Future<void>.delayed(Duration.zero);
    expect(controller.kpis.map((item) => item.id), [2]);
    expect(controller.isRefreshing.value, isFalse);
  });

  test('deleting the last row keeps the refresh in the background', () async {
    final refresh = Completer<KpiPage>();
    var globalCalls = 0;
    final service = _FakeRoleKpiService()
      ..respond = (_) {
        globalCalls++;
        return globalCalls == 1
            ? Future.value((list: [_kpi(2, 1)], count: 1))
            : refresh.future;
      };
    final controller = RoleKpiController(
      service: service,
      tokenReader: () async => 'test-token',
    );
    await controller.fetchAllKpis();

    final result = await controller.deleteKpi(roleId: 2, id: 1);
    await Future<void>.delayed(Duration.zero);

    expect(result.succeeded, isTrue);
    expect(controller.kpis, isEmpty);
    expect(controller.isLoading.value, isFalse);
    expect(controller.isRefreshing.value, isTrue);

    refresh.complete((list: <RoleKpi>[], count: 0));
    await Future<void>.delayed(Duration.zero);
    expect(controller.isRefreshing.value, isFalse);
  });
}
