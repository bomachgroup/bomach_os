import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:bomach_os/src/services/company_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late CompanyService service;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
    adapter = DioAdapter(dio: dio);
    service = CompanyService(dioOverride: dio);
  });

  test('passes every supported audit filter to the API', () async {
    adapter.onGet(
      '/api/v1/audit-logs/',
      (server) => server.reply(200, {'items': [], 'count': 0}),
      queryParameters: {
        'search': 'login',
        'user_id': '10',
        'audit_type': 'auth',
        'audit_status': 'success',
        'start_date': '2026-03-01',
        'end_date': '2026-03-18',
        'limit': 10,
        'offset': 20,
      },
    );

    final result = await service.getAuditLogs(
      'test-token',
      search: 'login',
      userId: '10',
      auditType: 'auth',
      auditStatus: 'success',
      startDate: '2026-03-01',
      endDate: '2026-03-18',
      limit: 10,
      offset: 20,
    );

    expect(result.items, isEmpty);
    expect(result.count, 0);
  });
}
