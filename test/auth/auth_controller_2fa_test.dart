import 'package:bomach_os/pages/auth/controller.dart';
import 'package:bomach_os/src/services/auth_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

/// Spec (V1 fix, Batch 1a) — the 2FA total-lockout bug:
///
/// `login()` with `requires_2fa: true` MUST leave the controller's
/// in-memory `currentSessionToken` populated (previously it only wrote to
/// secure storage, so every subsequent `verify2Fa()` bounced with "Session
/// expired" — permanent lockout for all 2FA users).
///
/// `verify2Fa()` MUST additionally fall back to reading the pending token
/// from secure storage (web refresh mid-2FA), and on success MUST clear
/// both the field and the stored pending token.
///
/// These tests drive the REAL AuthController against a DioAdapter-backed
/// AuthService injected via the constructor seam
/// (`AuthController({AuthService? authService})`).
void main() {
  late Dio dio;
  late DioAdapter dioAdapter;

  const employeeJson = {
    'user_id': 7,
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

  const twoFactorResponse = {
    'success': true,
    'requires_2fa': true,
    'session_token': 'STG_SESSION_TOKEN',
    'detail': 'Code sent',
    'access_token': '',
    'refresh_token': '',
    'user_id': 7,
  };

  const verifiedResponse = {
    'success': true,
    'requires_2fa': false,
    'session_token': '',
    'access_token': 'AT_123',
    'refresh_token': 'RT_456',
    'user_id': 7,
  };

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    Get.testMode = true;
    dio = Dio(BaseOptions(baseUrl: 'https://bomachauthtest.bgbot.app'));
    dioAdapter = DioAdapter(dio: dio);
  });

  void stubDownstream() {
    // Called by verify2Fa after a successful code exchange.
    dioAdapter.onGet(
      '/api/v1/roles/employees/7',
      (server) => server.reply(200, {'permissions': {}}),
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
      (server) => server.reply(200, {'is_enabled': true}),
    );
  }

  Future<AuthController> newController() async {
    final c = AuthController(authService: AuthService(dioOverride: dio));
    addTearDown(c.onClose);
    return c;
  }

  group('login() → requires_2fa', () {
    test('populates currentSessionToken (THE LOCKOUT BUG)', () async {
      dioAdapter.onPost(
        '/api/v1/auth/login',
        (server) => server.reply(200, twoFactorResponse),
        data: {'email': 'a@b.com', 'password': 'secret'},
      );

      final controller = await newController();
      await controller.loginForTest(email: 'a@b.com', password: 'secret');

      expect(controller.currentSessionToken, 'STG_SESSION_TOKEN');
      expect(controller.isPending2Fa.value, isTrue);
    });

    test('also persists the pending session token', () async {
      dioAdapter.onPost(
        '/api/v1/auth/login',
        (server) => server.reply(200, twoFactorResponse),
        data: {'email': 'a@b.com', 'password': 'secret'},
      );

      final controller = await newController();
      await controller.loginForTest(email: 'a@b.com', password: 'secret');

      const storage = FlutterSecureStorage();
      expect(await storage.read(key: 'session_token'), 'STG_SESSION_TOKEN');
    });
  });

  group('verify2Fa()', () {
    test('completes login when the field was set by login()', () async {
      dioAdapter.onPost(
        '/api/v1/auth/login',
        (server) => server.reply(200, twoFactorResponse),
        data: {'email': 'a@b.com', 'password': 'secret'},
      );
      stubDownstream();
      dioAdapter.onPost(
        '/api/v1/auth/verify-2fa',
        (server) => server.reply(200, verifiedResponse),
        data: {'session_token': 'STG_SESSION_TOKEN', 'code': '123456'},
      );

      final controller = await newController();
      await controller.loginForTest(email: 'a@b.com', password: 'secret');

      await controller.verify2FaForTest(code: '123456');

      expect(controller.currentSessionToken, isNull,
          reason: 'pending session token cleared after success');
      expect(controller.isPending2Fa.value, isFalse);

      const storage = FlutterSecureStorage();
      expect(await storage.read(key: 'access_token'), 'AT_123');
      expect(await storage.read(key: 'refresh_token'), 'RT_456');
      expect(await storage.read(key: 'session_token'), isNull,
          reason: 'stored pending token must not outlive login');
    });

    test('recovers from a fresh controller (simulated web refresh mid-2FA)',
        () async {
      // Simulate: user logged in (pending token persisted), page refreshed.
      // A NEW controller instance has no in-memory field but storage still
      // holds the pending token.
      const storage = FlutterSecureStorage();
      await storage.write(key: 'session_token', value: 'STG_SESSION_TOKEN');

      stubDownstream();
      dioAdapter.onPost(
        '/api/v1/auth/verify-2fa',
        (server) => server.reply(200, verifiedResponse),
        data: {'session_token': 'STG_SESSION_TOKEN', 'code': '123456'},
      );

      final controller = await newController();
      expect(controller.currentSessionToken, isNull);

      await controller.verify2FaForTest(code: '123456');

      expect(controller.isPending2Fa.value, isFalse,
          reason: 'storage fallback should have supplied the token');
    });

    test('wrong code keeps pending state intact for retry', () async {
      dioAdapter.onPost(
        '/api/v1/auth/login',
        (server) => server.reply(200, twoFactorResponse),
        data: {'email': 'a@b.com', 'password': 'secret'},
      );
      dioAdapter.onPost(
        '/api/v1/auth/verify-2fa',
        (server) => server.reply(400, {'detail': 'Invalid code'}),
        data: {'session_token': 'STG_SESSION_TOKEN', 'code': '000000'},
      );

      final controller = await newController();
      await controller.loginForTest(email: 'a@b.com', password: 'secret');

      await controller.verify2FaForTest(code: '000000');

      expect(controller.currentSessionToken, 'STG_SESSION_TOKEN',
          reason: 'failed attempt must not destroy the pending session');
      expect(controller.isPending2Fa.value, isTrue);
    });
  });
}
