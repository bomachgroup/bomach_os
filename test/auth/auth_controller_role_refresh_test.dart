import 'package:bomach_os/pages/auth/controller.dart';
import 'package:bomach_os/src/model/role_model.dart';
import 'package:bomach_os/src/services/auth_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
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
      'roles': ['view_own']
    },
    'created_at': '2026-09-01T08:00:00Z',
    'updated_at': '2026-09-02T09:30:00Z',
  };

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({
      'access_token': 'token',
      'user_id': '9',
    });
    Get.testMode = true;
    dio = Dio(BaseOptions(baseUrl: 'https://bomach.test'));
    adapter = DioAdapter(dio: dio);
  });

  tearDown(() => Get.reset());

  test('refreshCurrentRoles updates cached role data from the strict endpoint',
      () async {
    adapter.onGet(
      '/api/v1/roles/employees/9',
      (server) => server.reply(200, roleJson),
    );
    final controller = AuthController(
      authService: AuthService(dioOverride: dio),
    );

    await controller.refreshCurrentRoles();

    expect(controller.currentRoles, hasLength(1));
    expect(controller.currentRoles.single.name, 'Operations Lead');
    expect(controller.currentRolesError.value, isEmpty);
    expect(controller.isCurrentRolesLoading.value, isFalse);
  });

  test('refreshCurrentRoles retains cached roles after a temporary failure',
      () async {
    adapter.onGet(
      '/api/v1/roles/employees/9',
      (server) => server.reply(503, {'detail': 'temporary outage'}),
    );
    final controller = AuthController(
      authService: AuthService(dioOverride: dio),
    );
    controller.currentRoles.assign(
      Role(
        id: 1,
        name: 'Cached role',
        permissions: const {},
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      ),
    );

    await controller.refreshCurrentRoles();

    expect(controller.currentRoles.single.name, 'Cached role');
    expect(controller.currentRolesErrorStatus.value, 503);
    expect(controller.currentRolesError.value, contains('temporary outage'));
  });
}
