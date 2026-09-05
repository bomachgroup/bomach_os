import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:bomach_os/src/services/role_daily_routine_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late RoleDailyRoutineService service;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
    adapter = DioAdapter(dio: dio);
    service = RoleDailyRoutineService(dioOverride: dio);
  });

  test('loads role daily routine using the published endpoint and filters',
      () async {
    adapter.onGet(
      '/api/v1/roles/12/daily-routine',
      (server) => server.reply(
        200,
        {
          'items': [
            {
              'id': 1,
              'role_id': 12,
              'title': 'Review the daily queue',
              'description': 'Check outstanding work before stand-up.',
              'sequence': 1,
              'time_of_day': '08:30:00',
              'estimated_minutes': 20,
              'is_active': true,
              'created_at': '2026-09-04T08:00:00Z',
              'updated_at': '2026-09-04T08:00:00Z',
            },
          ],
          'count': 1,
        },
      ),
      queryParameters: {'limit': 25, 'offset': 10, 'search': 'queue'},
    );

    final result = await service.listRoutine(
      'token',
      roleId: 12,
      search: 'queue',
      limit: 25,
      offset: 10,
    );

    expect(result.count, 1);
    expect(result.list.single.title, 'Review the daily queue');
    expect(result.list.single.estimatedMinutes, 20);
  });
}
