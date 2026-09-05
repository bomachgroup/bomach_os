import 'package:bomach_os/pages/company/controllers/daily_routine_controller.dart';
import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:bomach_os/src/services/role_daily_routine_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late DailyRoutineController controller;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
    adapter = DioAdapter(dio: dio);
    controller = DailyRoutineController(
      service: RoleDailyRoutineService(dioOverride: dio),
      tokenReader: () async => 'token',
    );
  });

  test('exposes API routine items and count', () async {
    adapter.onGet(
      '/api/v1/roles/12/daily-routine',
      (server) => server.reply(200, {
        'items': [
          {
            'id': 1,
            'role_id': 12,
            'title': 'Review queue',
            'description': '',
            'sequence': 1,
            'time_of_day': null,
            'estimated_minutes': null,
            'is_active': true,
            'created_at': '2026-09-04T08:00:00Z',
            'updated_at': '2026-09-04T08:00:00Z',
          },
        ],
        'count': 1,
      }),
    );

    await controller.fetchData(roleId: 12);

    expect(controller.isLoading.value, isFalse);
    expect(controller.errorMessage.value, isEmpty);
    expect(controller.items.single.title, 'Review queue');
    expect(controller.count.value, 1);
  });

  test('keeps API failures visible instead of showing a false empty state',
      () async {
    adapter.onGet(
      '/api/v1/roles/12/daily-routine',
      (server) => server.reply(403, {'detail': 'Forbidden'}),
    );

    await controller.fetchData(roleId: 12);

    expect(controller.items, isEmpty);
    expect(controller.errorMessage.value, contains('403'));
  });
}
