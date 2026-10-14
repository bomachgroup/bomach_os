import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:bomach_os/src/services/employee_performance_plan_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late EmployeePerformancePlanService service;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
    adapter = DioAdapter(dio: dio);
    service = EmployeePerformancePlanService(dioOverride: dio);
  });

  test('reads the employee plan for the selected period', () async {
    adapter.onGet(
      '/api/v1/employees/42/performance-plan',
      (server) => server.reply(200, {
        'employee_id': 42,
        'role_id': 7,
        'period_start': '2026-10-01',
        'period_end': '2026-10-31',
        'revision': 3,
        'source': 'employee_plan',
        'kpis': <dynamic>[],
        'targets': <dynamic>[],
      }),
      queryParameters: {
        'period_start': '2026-10-01',
        'period_end': '2026-10-31',
      },
    );

    final result = await service.getEmployee(
      'access-token',
      42,
      periodStart: DateTime(2026, 10),
      periodEnd: DateTime(2026, 10, 31),
    );

    expect(result['employee_id'], 42);
    expect(result['revision'], 3);
    expect(result['source'], 'employee_plan');
  });

  test('sends a complete plan with required reason and selected scope',
      () async {
    const payload = {
      'period_start': '2026-10-01',
      'period_end': '2026-10-31',
      'change_scope': 'carry_forward',
      'reason': 'Approved workload adjustment',
      'kpis': [
        {
          'item_key': 'employee-kpi-one',
          'name': 'Client follow-ups',
          'tracking_mode': 'manual',
          'target_value': null,
          'weight': null,
          'period': 'monthly',
          'sequence': 1,
          'is_active': true,
        },
      ],
      'targets': <dynamic>[],
    };
    final requests = <RequestOptions>[];
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        requests.add(options);
        handler.next(options);
      },
    ));
    adapter.onPut(
      '/api/v1/employees/42/performance-plan',
      (server) => server.reply(200, {
        'employee_id': 42,
        'revision': 4,
        'source': 'period_snapshot',
      }),
      data: payload,
    );

    final result = await service.updateEmployee('access-token', 42, payload);

    expect(result['revision'], 4);
    expect(requests, hasLength(1));
    expect(requests.single.method, 'PUT');
    expect(requests.single.headers['Authorization'], 'Bearer access-token');
    expect(requests.single.data, payload);
  });

  test('keeps backend conflict details available to the editor', () async {
    adapter.onPut(
      '/api/v1/employees/42/performance-plan',
      (server) =>
          server.reply(409, {'detail': 'A KPI metric is already used.'}),
      data: {'period_start': '2026-10-01'},
    );

    await expectLater(
      service.updateEmployee(
        'access-token',
        42,
        {'period_start': '2026-10-01'},
      ),
      throwsA(isA<Exception>().having(
        (error) => error.toString(),
        'message',
        contains('A KPI metric is already used.'),
      )),
    );
  });

  test('sends the preview token when applying a role refresh', () async {
    const payload = {
      'period_start': '2026-10-01',
      'period_end': '2026-10-31',
      'reason': 'Reviewed role changes',
      'preview_token': 'preview-digest',
    };
    final requests = <RequestOptions>[];
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        requests.add(options);
        handler.next(options);
      },
    ));
    adapter.onPost(
      '/api/v1/employees/42/performance-plan/refresh',
      (server) => server.reply(200, {'revision': 5}),
      data: payload,
    );

    final result = await service.applyRefresh(
      'access-token',
      42,
      periodStart: DateTime(2026, 10),
      periodEnd: DateTime(2026, 10, 31),
      reason: 'Reviewed role changes',
      previewToken: 'preview-digest',
    );

    expect(result['revision'], 5);
    expect(requests.single.data, payload);
  });

  test('preserves the status code for stale preview conflicts', () async {
    adapter.onPost(
      '/api/v1/employees/42/performance-plan/refresh',
      (server) => server.reply(409, {'detail': 'Preview is stale.'}),
      data: {
        'period_start': '2026-10-01',
        'period_end': '2026-10-31',
        'reason': 'Reviewed role changes',
        'preview_token': 'preview-digest',
      },
    );

    await expectLater(
      service.applyRefresh(
        'access-token',
        42,
        periodStart: DateTime(2026, 10),
        periodEnd: DateTime(2026, 10, 31),
        reason: 'Reviewed role changes',
        previewToken: 'preview-digest',
      ),
      throwsA(isA<EmployeePerformancePlanApiException>().having(
        (error) => error.statusCode,
        'statusCode',
        409,
      )),
    );
  });
}
