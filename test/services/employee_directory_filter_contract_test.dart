import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:bomach_os/src/services/employees_services.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late EmployeeService service;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
    adapter = DioAdapter(dio: dio);
    service = EmployeeService(dioOverride: dio);
  });

  test('forwards all published employee directory filters', () async {
    adapter.onGet(
      '/api/v1/employees/employees',
      (server) => server.reply(200, {'items': <Map<String, dynamic>>[], 'count': 0}),
      queryParameters: {
        'add_shareholders': true,
        'offboarded': true,
        'sort_by_dob': 'asc',
        'limit': 20,
        'offset': 40,
      },
    );

    final result = await service.getEmployees(
      'test-token',
      addShareholders: true,
      offboarded: true,
      sortByDob: 'asc',
      limit: 20,
      offset: 40,
    );

    expect(result.list, isEmpty);
    expect(result.count, 0);
  });
}
