import 'package:bms_front_end/pages/hr/models/loans_model.dart';
import 'package:bms_front_end/src/constants/api_constants.dart';
import 'package:bms_front_end/src/services/hr/loan_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late LoanService service;

  const token = 'test-token-123';
  const baseUrl = '${ApiConstants.baseUrl}/api/v1';

  final sampleLoanJson = {
    'id': 1,
    'loan_amount': '50000.00',
    'repayment_date': '2026-12-31',
    'reason': 'Home renovation',
    'employee_name': 'John Doe',
    'job_title': 'Software Engineer',
    'status': 'pending',
    'emergency_contact_name': 'Jane Doe',
    'emergency_contact_phone': '+2341234567890',
    'attachment': '',
    'created_at': '2026-01-15T10:00:00Z',
  };

  final sampleCreateLoan = LoanRequest(
    loanAmount: '50000.00',
    repaymentDate: '2026-12-31',
    reason: 'Home renovation',
    emergencyContactName: 'Jane Doe',
    emergencyContactPhone: '+2341234567890',
  );

  final sampleCreatePayload = sampleCreateLoan.toCreateJson();

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: baseUrl));
    dioAdapter = DioAdapter(dio: dio);
    service = LoanService(dioOverride: dio);
  });

  group('getLoans', () {
    test('should return list of LoanRequest on success (items wrapper)',
        () async {
      dioAdapter.onGet(
        '/loans',
        (server) => server.reply(200, {
          'items': [sampleLoanJson, sampleLoanJson],
          'count': 2,
        }),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      final result = await service.getLoans(token);

      expect(result.items, isA<List<LoanRequest>>());
      expect(result.items.length, 2);
      expect(result.count, 2);
      expect(result.items.first.id, 1);
      expect(result.items.first.loanAmount, '50000.00');
      expect(result.items.first.repaymentDate, '2026-12-31');
      expect(result.items.first.reason, 'Home renovation');
      expect(result.items.first.employeeName, 'John Doe');
      expect(result.items.first.jobTitle, 'Software Engineer');
      expect(result.items.first.status, 'pending');
      expect(result.items.first.emergencyContactName, 'Jane Doe');
      expect(result.items.first.emergencyContactPhone, '+2341234567890');
    });

    test('should return list of LoanRequest on success (plain list)', () async {
      dioAdapter.onGet(
        '/loans',
        (server) => server.reply(200, [sampleLoanJson]),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      final result = await service.getLoans(token);

      expect(result.items.length, 1);
      expect(result.count, 1);
    });

    test('should handle empty list', () async {
      dioAdapter.onGet(
        '/loans',
        (server) => server.reply(200, {'items': [], 'count': 0}),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      final result = await service.getLoans(token);

      expect(result.items, isEmpty);
      expect(result.count, 0);
    });

    test('should pass query parameters', () async {
      dioAdapter.onGet(
        '/loans',
        (server) => server.reply(200, [sampleLoanJson]),
        queryParameters: {
          'status': 'approved',
          'search': 'John',
          'limit': 50,
          'offset': 10,
        },
      );

      final result = await service.getLoans(
        token,
        status: 'approved',
        search: 'John',
        limit: 50,
        offset: 10,
      );

      expect(result.items.length, 1);
    });

    test('should throw on 500 error', () async {
      dioAdapter.onGet(
        '/loans',
        (server) => server.reply(500, {'message': 'Internal server error'}),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      expect(
        () => service.getLoans(token),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 403 error', () async {
      dioAdapter.onGet(
        '/loans',
        (server) => server.reply(403, {'message': 'Forbidden'}),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      expect(
        () => service.getLoans(token),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('createLoan', () {
    test('should return LoanRequest on success', () async {
      dioAdapter.onPost(
        '/loans',
        (server) => server.reply(201, sampleLoanJson),
        data: sampleCreatePayload,
      );

      final result = await service.createLoan(token, sampleCreateLoan);

      expect(result, isA<LoanRequest>());
      expect(result.id, 1);
      expect(result.loanAmount, '50000.00');
      expect(result.reason, 'Home renovation');
    });

    test('should throw on 400 error', () async {
      dioAdapter.onPost(
        '/loans',
        (server) => server.reply(400, {'message': 'Invalid data'}),
        data: sampleCreatePayload,
      );

      expect(
        () => service.createLoan(token, sampleCreateLoan),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 500 error', () async {
      dioAdapter.onPost(
        '/loans',
        (server) => server.reply(500, {'message': 'Server error'}),
        data: sampleCreatePayload,
      );

      expect(
        () => service.createLoan(token, sampleCreateLoan),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getLoanById', () {
    test('should return LoanRequest on success', () async {
      dioAdapter.onGet(
        '/loans/1',
        (server) => server.reply(200, sampleLoanJson),
      );

      final result = await service.getLoanById(token, 1);

      expect(result, isA<LoanRequest>());
      expect(result.id, 1);
      expect(result.loanAmount, '50000.00');
      expect(result.employeeName, 'John Doe');
    });

    test('should throw on 404 error', () async {
      dioAdapter.onGet(
        '/loans/999',
        (server) => server.reply(404, {'message': 'Loan not found'}),
      );

      expect(
        () => service.getLoanById(token, 999),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 500 error', () async {
      dioAdapter.onGet(
        '/loans/1',
        (server) => server.reply(500, {'message': 'Server error'}),
      );

      expect(
        () => service.getLoanById(token, 1),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('approveLoan', () {
    test('should return approved LoanRequest on success', () async {
      final approvedJson = {...sampleLoanJson, 'status': 'approved'};

      dioAdapter.onPost(
        '/loans/1/approve',
        (server) => server.reply(200, approvedJson),
      );

      final result = await service.approveLoan(token, 1);

      expect(result, isA<LoanRequest>());
      expect(result.id, 1);
      expect(result.status, 'approved');
    });

    test('should throw on 400 error', () async {
      dioAdapter.onPost(
        '/loans/1/approve',
        (server) => server.reply(400, {'message': 'Loan already approved'}),
      );

      expect(
        () => service.approveLoan(token, 1),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 403 error', () async {
      dioAdapter.onPost(
        '/loans/1/approve',
        (server) =>
            server.reply(403, {'message': 'Not authorized to approve loans'}),
      );

      expect(
        () => service.approveLoan(token, 1),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 500 error', () async {
      dioAdapter.onPost(
        '/loans/1/approve',
        (server) => server.reply(500, {'message': 'Server error'}),
      );

      expect(
        () => service.approveLoan(token, 1),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('rejectLoan', () {
    test('should return rejected LoanRequest on success', () async {
      final rejectedJson = {...sampleLoanJson, 'status': 'rejected'};

      dioAdapter.onPost(
        '/loans/1/reject',
        (server) => server.reply(200, rejectedJson),
      );

      final result = await service.rejectLoan(token, 1);

      expect(result, isA<LoanRequest>());
      expect(result.id, 1);
      expect(result.status, 'rejected');
    });

    test('should throw on 400 error', () async {
      dioAdapter.onPost(
        '/loans/1/reject',
        (server) => server.reply(400, {'message': 'Loan already rejected'}),
      );

      expect(
        () => service.rejectLoan(token, 1),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 403 error', () async {
      dioAdapter.onPost(
        '/loans/1/reject',
        (server) =>
            server.reply(403, {'message': 'Not authorized to reject loans'}),
      );

      expect(
        () => service.rejectLoan(token, 1),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 500 error', () async {
      dioAdapter.onPost(
        '/loans/1/reject',
        (server) => server.reply(500, {'message': 'Server error'}),
      );

      expect(
        () => service.rejectLoan(token, 1),
        throwsA(isA<Exception>()),
      );
    });
  });
}
