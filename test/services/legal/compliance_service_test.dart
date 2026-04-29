import 'package:bomach_os/src/services/legal/compliance_service.dart';
import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late ComplianceService service;
  const token = 'test-token';

  setUp(() {
    dio = Dio(BaseOptions(
      baseUrl: '${ApiConstants.baseUrl}/api/v1',
    ));
    dioAdapter = DioAdapter(dio: dio);
    service = ComplianceService(dioOverride: dio);
  });

  final sampleRecord = {
    'id': 1,
    'full_name': 'John Doe',
    'email_address': 'john@example.com',
    'phone_number': '+2349012345678',
    'department_id': 1,
    'compliance_type': 'Legal',
    'reference_number': 'REF-001',
    'date_of_issue': '2026-01-01',
    'expiry_date': '2027-01-01',
    'issuing_authority': 'COREN',
    'status': 'active',
    'description': 'Test compliance',
    'contact_person': 'Jane',
    'contact_email': 'jane@example.com',
    'cost': '50000.00',
    'priority_level': 'High',
    'is_expired': false,
    'days_until_expiry': 289,
    'created_at': '2026-01-01T00:00:00Z',
    'updated_at': '2026-01-01T00:00:00Z',
    'documents': ['doc1.pdf'],
  };

  group('getRecords', () {
    test('returns records from paginated response', () async {
      dioAdapter.onGet(
        '/compliance/compliance-records',
        (server) => server.reply(200, {
          'items': [sampleRecord],
          'count': 1,
        }),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      final result = await service.getRecords(token);
      expect(result.items.length, 1);
      expect(result.items.first.fullName, 'John Doe');
      expect(result.total, 1);
    });

    test('returns empty list when no records', () async {
      dioAdapter.onGet(
        '/compliance/compliance-records',
        (server) => server.reply(200, {'items': [], 'count': 0}),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      final result = await service.getRecords(token);
      expect(result.items, isEmpty);
      expect(result.total, 0);
    });

    test('passes query parameters correctly', () async {
      dioAdapter.onGet(
        '/compliance/compliance-records',
        (server) => server.reply(200, {'items': [], 'count': 0}),
        queryParameters: {
          'search': 'COREN',
          'compliance_type': 'Legal',
          'limit': 10,
          'offset': 0,
        },
      );

      final result = await service.getRecords(
        token,
        search: 'COREN',
        complianceType: 'Legal',
        limit: 10,
      );
      expect(result.items, isEmpty);
    });

    test('throws on error', () async {
      dioAdapter.onGet(
        '/compliance/compliance-records',
        (server) => server.reply(500, {'detail': 'Server error'}),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      expect(
        () => service.getRecords(token),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('createRecord', () {
    test('creates record successfully', () async {
      dioAdapter.onPost(
        '/compliance/compliance-records',
        (server) => server.reply(201, sampleRecord),
        data: Matchers.any,
      );

      final result = await service.createRecord(token, sampleRecord);
      expect(result.fullName, 'John Doe');
      expect(result.complianceType, 'Legal');
    });

    test('throws on 400 error', () async {
      dioAdapter.onPost(
        '/compliance/compliance-records',
        (server) => server.reply(400, {'detail': 'Bad request'}),
        data: Matchers.any,
      );

      expect(
        () => service.createRecord(token, {}),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getRecordById', () {
    test('returns record by ID', () async {
      dioAdapter.onGet(
        '/compliance/compliance-records/1',
        (server) => server.reply(200, sampleRecord),
      );

      final result = await service.getRecordById(token, 1);
      expect(result.id, 1);
      expect(result.issuingAuthority, 'COREN');
    });

    test('throws on 404', () async {
      dioAdapter.onGet(
        '/compliance/compliance-records/999',
        (server) => server.reply(404, {'detail': 'Not found'}),
      );

      expect(
        () => service.getRecordById(token, 999),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('updateRecord', () {
    test('updates record successfully', () async {
      dioAdapter.onPut(
        '/compliance/compliance-records/1',
        (server) => server.reply(200, sampleRecord),
        data: Matchers.any,
      );

      final result = await service.updateRecord(token, 1, sampleRecord);
      expect(result.fullName, 'John Doe');
    });

    test('throws on 400 error', () async {
      dioAdapter.onPut(
        '/compliance/compliance-records/1',
        (server) => server.reply(400, {'detail': 'Bad request'}),
        data: Matchers.any,
      );

      expect(
        () => service.updateRecord(token, 1, {}),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('deleteRecord', () {
    test('deletes record successfully', () async {
      dioAdapter.onDelete(
        '/compliance/compliance-records/1',
        (server) => server.reply(200, {'detail': 'Deleted'}),
      );

      await expectLater(
        service.deleteRecord(token, 1),
        completes,
      );
    });

    test('throws on 404 error', () async {
      dioAdapter.onDelete(
        '/compliance/compliance-records/999',
        (server) => server.reply(404, {'detail': 'Not found'}),
      );

      expect(
        () => service.deleteRecord(token, 999),
        throwsA(isA<Exception>()),
      );
    });
  });
}
