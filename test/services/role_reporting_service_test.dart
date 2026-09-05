import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:bomach_os/src/services/role_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late RoleService service;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
    adapter = DioAdapter(dio: dio);
    service = RoleService(dioOverride: dio);
  });

  test('loads the reporting tree from the role reporting endpoint', () async {
    final payload = {
      'role_id': 12,
      'role_name': 'Operations Lead',
      'reports_to': {'id': 3, 'name': 'Chief Operating Officer'},
      'direct_reports': [
        {'id': 21, 'name': 'Site Manager'},
      ],
    };

    adapter.onGet(
      '/api/v1/roles/12/reporting-tree',
      (server) => server.reply(200, payload),
    );

    final result = await service.getReportingTree('token', 12);

    expect(result['role_id'], 12);
    expect(result['reports_to']['name'], 'Chief Operating Officer');
    expect(result['direct_reports'], hasLength(1));
  });

  test('loads reporting lines with the API response unchanged', () async {
    final payload = {
      'items': [
        {'from_role_id': 12, 'to_role_id': 3, 'relationship': 'reports_to'},
      ],
      'count': 1,
    };

    adapter.onGet(
      '/api/v1/roles/12/reporting-lines',
      (server) => server.reply(200, payload),
    );

    final result = await service.getReportingLines('token', 12);

    expect(result['items'], hasLength(1));
    expect(result['count'], 1);
  });
}
