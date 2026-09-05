import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:bomach_os/src/services/role_task_template_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late RoleTaskTemplateService service;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
    adapter = DioAdapter(dio: dio);
    service = RoleTaskTemplateService(dioOverride: dio);
  });

  test('updates a role task template with the contract PATCH method', () async {
    const payload = {
      'title': 'Review daily queue',
      'description': 'Review and triage the daily queue.',
      'sequence': 2,
      'default_priority': 'high',
      'estimated_minutes': 45,
      'is_active': true,
    };

    adapter.onPatch(
      '/api/v1/roles/12/task-templates/9',
      (server) => server.reply(200, {
        'id': 9,
        'role_id': 12,
        ...payload,
      }),
      data: payload,
    );

    final result = await service.updateTaskTemplate(
      'token',
      12,
      9,
      payload,
    );

    expect(result.id, 9);
    expect(result.title, 'Review daily queue');
    expect(result.defaultPriority, 'high');
  });

  test('maps the task-template priority filter to default_priority', () async {
    adapter.onGet(
      '/api/v1/roles/12/task-templates',
      (server) => server.reply(200, {'items': <dynamic>[], 'count': 0}),
      queryParameters: {
        'default_priority': 'high',
        'is_active': true,
        'limit': 20,
        'offset': 40,
      },
    );

    final result = await service.listTaskTemplates(
      'token',
      roleId: 12,
      priority: 'high',
      isActive: true,
      limit: 20,
      offset: 40,
    );

    expect(result.list, isEmpty);
    expect(result.count, 0);
  });

  test('forwards the published task-template search filter', () async {
    adapter.onGet(
      '/api/v1/roles/12/task-templates',
      (server) => server.reply(200, {'items': <dynamic>[], 'count': 0}),
      queryParameters: {
        'search': 'review',
        'limit': 20,
        'offset': 0,
      },
    );

    final dynamic dynamicService = service;
    final result = await dynamicService.listTaskTemplates(
      'token',
      roleId: 12,
      search: 'review',
      limit: 20,
    );

    expect(result.list, isEmpty);
    expect(result.count, 0);
  });
}
