import 'package:bms_front_end/src/services/audit_log_service.dart';
import 'package:bms_front_end/src/constants/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late AuditLogService service;
  const token = 'test-token';

  setUp(() {
    dio = Dio(BaseOptions(
      baseUrl: '${ApiConstants.baseUrl}/api/v1',
    ));
    dioAdapter = DioAdapter(dio: dio);
    service = AuditLogService(dioOverride: dio);
  });

  final sampleAuditLog = {
    'id': 1,
    'activity': 'User logged in',
    'audit_type': 'auth',
    'audit_type_display': 'Authentication',
    'audit_status': 'success',
    'audit_status_display': 'Success',
    'ip_address': '192.168.1.1',
    'metadata': {'browser': 'Chrome', 'os': 'Windows'},
    'user': {
      'id': 10,
      'email': 'john@example.com',
      'full_name': 'John Doe',
    },
    'created_at': '2026-03-01T10:00:00Z',
    'updated_at': '2026-03-01T10:00:00Z',
  };

  group('getAuditLogs', () {
    test('returns audit logs from paginated response', () async {
      dioAdapter.onGet(
        '/audit-logs/',
        (server) => server.reply(200, {
          'items': [sampleAuditLog],
          'count': 1,
        }),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      final result = await service.getAuditLogs(token);
      expect(result.items.length, 1);
      expect(result.items.first.activity, 'User logged in');
      expect(result.items.first.auditTypeDisplay, 'Authentication');
      expect(result.items.first.ipAddress, '192.168.1.1');
      expect(result.items.first.user?.fullName, 'John Doe');
      expect(result.items.first.user?.email, 'john@example.com');
      expect(result.items.first.metadata?['browser'], 'Chrome');
      expect(result.total, 1);
    });

    test('returns empty list when no audit logs', () async {
      dioAdapter.onGet(
        '/audit-logs/',
        (server) => server.reply(200, {'items': [], 'count': 0}),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      final result = await service.getAuditLogs(token);
      expect(result.items, isEmpty);
      expect(result.total, 0);
    });

    test('passes query parameters correctly', () async {
      dioAdapter.onGet(
        '/audit-logs/',
        (server) => server.reply(200, {'items': [], 'count': 0}),
        queryParameters: {
          'search': 'login',
          'user_id': '10',
          'audit_type': 'auth',
          'audit_status': 'success',
          'start_date': '2026-03-01',
          'end_date': '2026-03-18',
          'limit': 50,
          'offset': 10,
        },
      );

      final result = await service.getAuditLogs(
        token,
        search: 'login',
        userId: '10',
        auditType: 'auth',
        auditStatus: 'success',
        startDate: '2026-03-01',
        endDate: '2026-03-18',
        limit: 50,
        offset: 10,
      );
      expect(result.items, isEmpty);
    });

    test('throws on error', () async {
      dioAdapter.onGet(
        '/audit-logs/',
        (server) => server.reply(500, {'detail': 'Server error'}),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      expect(
        () => service.getAuditLogs(token),
        throwsA(isA<Exception>()),
      );
    });
  });
}
