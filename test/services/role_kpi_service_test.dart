import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:bomach_os/src/model/role_kpi_model.dart';
import 'package:bomach_os/src/services/role_kpi_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late RoleKpiService service;

  const assignment = {
    'id': 14,
    'role_id': 7,
    'metric_id': 22,
    'metric': {
      'id': 22,
      'name': 'Site visits',
      'description': 'Completed visits',
      'unit': 'count',
    },
    'tracking_mode': 'semi_automatic',
    'target_value': null,
    'weight': null,
    'period': 'semi_annual',
    'sequence': 1,
    'is_active': true,
  };

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
    adapter = DioAdapter(dio: dio);
    service = RoleKpiService(dioOverride: dio);
  });

  test(
      'global KPI search uses the cross-role endpoint and preserves pagination',
      () async {
    adapter.onGet(
      '/api/v1/roles/kpis',
      (server) => server.reply(200, {
        'items': [assignment],
        'count': 31,
      }),
      queryParameters: {
        'search': 'site visits',
        'limit': 10,
        'offset': 20,
      },
    );

    final result = await service.listAllRoleKpis(
      'token',
      search: '  site visits  ',
      limit: 10,
      offset: 20,
    );

    expect(result.count, 31);
    expect(result.list.single.roleId, 7);
    expect(result.list.single.metric?.name, 'Site visits');
    expect(result.list.single.trackingMode, 'semi_automatic');
    expect(result.list.single.period, 'semi_annual');
  });

  test('assignment edits use the selected role and send explicit null clears',
      () async {
    final requests = <RequestOptions>[];
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        requests.add(options);
        handler.next(options);
      },
    ));
    adapter.onPatch(
      '/api/v1/roles/7/kpis/14',
      (server) => server.reply(200, assignment),
      data: {
        'metric_id': 22,
        'target_value': null,
        'weight': null,
        'period': 'semi_annual',
      },
    );

    await service.updateRoleKpi('token', 7, 14, {
      'metric_id': 22,
      'target_value': null,
      'weight': null,
      'period': 'semi_annual',
    });

    expect(requests, hasLength(1));
    expect(requests.single.method, 'PATCH');
    expect(requests.single.path, '/api/v1/roles/7/kpis/14');
    expect(requests.single.data, {
      'metric_id': 22,
      'target_value': null,
      'weight': null,
      'period': 'semi_annual',
    });
  });

  test('legacy yearly values remain readable and display as Annual', () {
    expect(RoleKpi.editablePeriod('yearly'), 'annual');
    expect(RoleKpi.editablePeriod('semi_annual'), 'semi_annual');
  });
}
