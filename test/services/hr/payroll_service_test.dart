import 'package:bms_front_end/pages/hr/models/payroll_model.dart';
import 'package:bms_front_end/src/services/hr/payroll_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late PayrollService service;

  const token = 'test-token-123';
  const baseUrl = 'https://bomachauth.bgbot.app/api/v1';

  final samplePayrollJson = {
    'id': '101',
    'employee_id': '42',
    'payroll_period': '2026-03',
    'status': 'pending',
    'gross_salary': 500000.0,
    'net_salary': 420000.0,
    'total_deductions': 50000.0,
    'total_allowances': 30000.0,
    'disbursement_date': '2026-03-28',
    'deductions': {'tax': 30000, 'pension': 20000},
    'additions': {'bonus': 15000, 'transport': 15000},
    'created_at': '2026-03-01T00:00:00Z',
    'updated_at': '2026-03-15T00:00:00Z',
  };

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: baseUrl));
    dioAdapter = DioAdapter(dio: dio);
    service = PayrollService(dioOverride: dio);
  });

  group('getPayrolls', () {
    test('should return list of Payroll on success (items wrapper)', () async {
      dioAdapter.onGet(
        '/payroll/',
        (server) => server.reply(200, {
          'items': [samplePayrollJson, samplePayrollJson],
        }),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      final result = await service.getPayrolls(token);

      expect(result, isA<List<Payroll>>());
      expect(result.length, 2);
      expect(result.first.id, '101');
      expect(result.first.grossSalary, 500000.0);
      expect(result.first.status, 'pending');
    });

    test('should return list of Payroll on success (plain list)', () async {
      dioAdapter.onGet(
        '/payroll/',
        (server) => server.reply(200, [samplePayrollJson]),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      final result = await service.getPayrolls(token);

      expect(result.length, 1);
    });

    test('should handle empty list', () async {
      dioAdapter.onGet(
        '/payroll/',
        (server) => server.reply(200, {'items': []}),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      final result = await service.getPayrolls(token);

      expect(result, isEmpty);
    });

    test('should throw on 500 error', () async {
      dioAdapter.onGet(
        '/payroll/',
        (server) => server.reply(500, {'message': 'Internal server error'}),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      expect(
        () => service.getPayrolls(token),
        throwsA(isA<Exception>()),
      );
    });

    test('should pass query parameters', () async {
      dioAdapter.onGet(
        '/payroll/',
        (server) => server.reply(200, [samplePayrollJson]),
        queryParameters: {
          'search': 'John',
          'status': 'paid',
          'limit': 50,
          'offset': 10,
        },
      );

      final result = await service.getPayrolls(
        token,
        search: 'John',
        status: 'paid',
        limit: 50,
        offset: 10,
      );

      expect(result.length, 1);
    });
  });

  group('processBatch', () {
    test('should return result map on success', () async {
      dioAdapter.onPost(
        '/payroll/process-batch',
        (server) => server.reply(200, {
          'processed': 15,
          'failed': 0,
          'period': '2026-03',
          'status': 'completed',
        }),
        data: {'period_date': '2026-03-01'},
      );

      final result = await service.processBatch(
        token,
        periodDate: '2026-03-01',
      );

      expect(result, isA<Map<String, dynamic>>());
      expect(result['processed'], 15);
      expect(result['status'], 'completed');
    });

    test('should throw on 400 error', () async {
      dioAdapter.onPost(
        '/payroll/process-batch',
        (server) => server.reply(400, {'message': 'Invalid period date'}),
        data: {'period_date': 'bad-date'},
      );

      expect(
        () => service.processBatch(token, periodDate: 'bad-date'),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 500 error', () async {
      dioAdapter.onPost(
        '/payroll/process-batch',
        (server) => server.reply(500, {'message': 'Server error'}),
        data: {'period_date': '2026-03-01'},
      );

      expect(
        () => service.processBatch(token, periodDate: '2026-03-01'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('makePayment', () {
    test('should return payment data on success', () async {
      dioAdapter.onGet(
        '/payroll/make-payment/2026/3',
        (server) => server.reply(200, {
          'total_amount': 5000000.0,
          'employee_count': 15,
          'period': '2026-03',
          'status': 'ready',
        }),
      );

      final result = await service.makePayment(
        token,
        year: 2026,
        month: 3,
      );

      expect(result, isA<Map<String, dynamic>>());
      expect(result['total_amount'], 5000000.0);
      expect(result['employee_count'], 15);
    });

    test('should throw on 400 error', () async {
      dioAdapter.onGet(
        '/payroll/make-payment/2026/13',
        (server) => server.reply(400, {'message': 'Invalid month'}),
      );

      expect(
        () => service.makePayment(token, year: 2026, month: 13),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 403 error', () async {
      dioAdapter.onGet(
        '/payroll/make-payment/2026/3',
        (server) => server.reply(403, {'message': 'Not authorized'}),
      );

      expect(
        () => service.makePayment(token, year: 2026, month: 3),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('authorizePayroll', () {
    test('should return authorization result on success', () async {
      dioAdapter.onPost(
        '/payroll/make-payment/2026/3/authorize',
        (server) => server.reply(200, {
          'authorized': true,
          'authorized_by': 'admin-001',
          'period': '2026-03',
          'timestamp': '2026-03-28T12:00:00Z',
        }),
      );

      final result = await service.authorizePayroll(
        token,
        year: 2026,
        month: 3,
      );

      expect(result, isA<Map<String, dynamic>>());
      expect(result['authorized'], true);
      expect(result['authorized_by'], 'admin-001');
    });

    test('should throw on 403 error', () async {
      dioAdapter.onPost(
        '/payroll/make-payment/2026/3/authorize',
        (server) => server.reply(403, {'message': 'Insufficient permissions'}),
      );

      expect(
        () => service.authorizePayroll(token, year: 2026, month: 3),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 500 error', () async {
      dioAdapter.onPost(
        '/payroll/make-payment/2026/3/authorize',
        (server) => server.reply(500, {'message': 'Server error'}),
      );

      expect(
        () => service.authorizePayroll(token, year: 2026, month: 3),
        throwsA(isA<Exception>()),
      );
    });
  });
}
