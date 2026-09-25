import 'package:bomach_os/src/services/auth_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;

  const roleJson = {
    'id': 42,
    'name': 'Operations Lead',
    'branches': [
      {'id': 7, 'branch_name': 'Lagos'},
    ],
    'permissions': {
      'roles': ['view_own'],
      'work_reports': ['list_own', 'create'],
    },
    'created_at': '2026-09-01T08:00:00Z',
    'updated_at': '2026-09-02T09:30:00Z',
  };

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://bomach.test'));
    adapter = DioAdapter(dio: dio);
  });

  test('strict role request parses the canonical object response', () async {
    adapter.onGet(
      '/api/v1/roles/employees/9',
      (server) => server.reply(200, roleJson),
    );

    final roles = await AuthService(dioOverride: dio).getEmployeeRolesStrict(
      accessToken: 'token',
      userId: 9,
    );

    expect(roles, hasLength(1));
    expect(roles.single.id, 42);
    expect(roles.single.branches.single.branchName, 'Lagos');
    expect(roles.single.permissions['work_reports'], ['list_own', 'create']);
    expect(roles.single.createdAt, DateTime.utc(2026, 9, 1, 8));
    expect(roles.single.updatedAt, DateTime.utc(2026, 9, 2, 9, 30));
  });

  test('strict role request keeps accepting the legacy list response',
      () async {
    adapter.onGet(
      '/api/v1/roles/employees/9',
      (server) => server.reply(200, [roleJson]),
    );

    final roles = await AuthService(dioOverride: dio).getEmployeeRolesStrict(
      accessToken: 'token',
      userId: 9,
    );

    expect(roles, hasLength(1));
    expect(roles.single.name, 'Operations Lead');
  });

  test('strict role request rejects malformed response shapes', () async {
    adapter.onGet(
      '/api/v1/roles/employees/9',
      (server) => server.reply(200, {'roles': []}),
    );

    expect(
      () => AuthService(dioOverride: dio).getEmployeeRolesStrict(
        accessToken: 'token',
        userId: 9,
      ),
      throwsA(isA<AuthException>()),
    );
  });

  test('strict role request preserves authorization and server failures',
      () async {
    for (final status in [401, 403, 404, 500]) {
      adapter.onGet(
        '/api/v1/roles/employees/9',
        (server) => server.reply(status, {'detail': 'role request failed'}),
      );

      try {
        await AuthService(dioOverride: dio).getEmployeeRolesStrict(
          accessToken: 'token',
          userId: 9,
        );
        fail('expected status $status to throw');
      } on AuthException catch (error) {
        expect(error.statusCode, status);
      }
    }
  });
}
