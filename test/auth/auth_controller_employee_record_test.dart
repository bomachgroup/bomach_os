import 'package:bomach_os/pages/auth/controller.dart';
import 'package:bomach_os/src/services/auth_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

/// Spec — scorecard employee-ID mismatch fix:
///
/// The app stores the AUTH user id (`user_id`) but HR endpoints such as
/// `/api/v1/monthly-scorecards/employee/{id}` key on the EMPLOYEE-record
/// primary key (`user_employee.id`). Sending the auth id causes a raw
/// ForeignKeyViolation 500 on the backend.
///
/// On every successful login (and session restore), AuthController MUST
/// persist the employee-record PK from the fetched profile as
/// `employee_record_id` alongside the existing `user_id`.
void main() {
  late Dio dio;
  late DioAdapter dioAdapter;

  const employeeJson = {
    // Auth account id — what the app previously conflated with the
    // employee record.
    'user_id': 7,
    // Employee-record PK — the value the scorecard endpoints expect.
    'id': 3,
    'username': 'tester',
    'email': 'a@b.com',
    'first_name': 'Test',
    'last_name': 'User',
    'is_verified': true,
    'is_active': true,
    'branch_id': 1,
    'department_id': 1,
    'level_id': 1,
    'created_at': '2026-01-01T00:00:00Z',
  };

  const loginResponse = {
    'success': true,
    'requires_2fa': false,
    'session_token': '',
    'access_token': 'AT_123',
    'refresh_token': 'RT_456',
    'user_id': 7,
    'detail': 'Login successful',
  };

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    Get.testMode = true;
    dio = Dio(BaseOptions(baseUrl: 'https://bomachauthtest.bgbot.app'));
    dioAdapter = DioAdapter(dio: dio);
  });

  tearDown(() {
    Get.reset();
  });

  void stubDownstream() {
    dioAdapter.onPost(
      '/api/v1/auth/login',
      (server) => server.reply(200, loginResponse),
      data: {'email': 'a@b.com', 'password': 'secret'},
    );
    dioAdapter.onGet(
      '/api/v1/roles/employees/7',
      (server) => server.reply(200, {
        'id': 2,
        'name': 'Staff',
        'permissions': {
          'monthly_scorecards': ['list_own'],
        },
        'created_at': '2026-01-01T00:00:00Z',
        'updated_at': '2026-01-01T00:00:00Z',
      }),
    );
    dioAdapter.onGet(
      '/api/v1/employees/employees/7',
      (server) => server.reply(200, employeeJson),
    );
    // Fire-and-forget drift validation.
    dioAdapter.onGet(
      '/api/v1/roles/permissions-map',
      (server) => server.reply(200, {'permissions_map': {}}),
    );
    dioAdapter.onGet(
      '/api/v1/auth/2fa/status',
      (server) => server.reply(200, {'is_enabled': false}),
    );
  }

  test(
      'successful login persists employee_record_id from the profile '
      '(not the auth user_id)', () async {
    stubDownstream();

    final controller =
        AuthController(authService: AuthService(dioOverride: dio));
    addTearDown(controller.onClose);

    await controller.loginForTest(email: 'a@b.com', password: 'secret');

    const storage = FlutterSecureStorage();
    expect(await storage.read(key: 'employee_record_id'), '3');
    // The auth id must remain untouched for endpoints that key on it.
    expect(await storage.read(key: 'user_id'), '7');
  });

  test('profile reload restores Employee ID without replacing auth user ID',
      () async {
    FlutterSecureStorage.setMockInitialValues({
      'access_token': 'AT_123',
      'user_id': '7',
    });
    dioAdapter.onGet(
      '/api/v1/employees/employees/7',
      (server) => server.reply(200, employeeJson),
    );
    dioAdapter.onGet(
      '/api/v1/auth/2fa/status',
      (server) => server.reply(200, {'is_enabled': false}),
    );

    final controller =
        AuthController(authService: AuthService(dioOverride: dio));
    addTearDown(controller.onClose);

    expect(await controller.reloadEmployeeRecordId(), 3);
    const storage = FlutterSecureStorage();
    expect(await storage.read(key: 'employee_record_id'), '3');
    expect(await storage.read(key: 'user_id'), '7');
  });
}
