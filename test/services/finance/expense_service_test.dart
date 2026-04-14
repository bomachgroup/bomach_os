import 'package:bms_front_end/pages/finance/models/expense_model.dart';
import 'package:bms_front_end/src/constants/api_constants.dart';
import 'package:bms_front_end/src/services/finance/expense_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late ExpenseService service;

  const token = 'test-token-123';
  final baseUrl = '${ApiConstants.baseUrl}/api/v1';

  final sampleExpenseJson = {
    'id': 1,
    'user_id': 42,
    'department': {'id': 3, 'name': 'Engineering'},
    'date': '2026-03-15',
    'description': 'Office supplies purchase',
    'amount': '15000.00',
    'category': 'office_supplies',
    'status': 'pending',
    'attachment': 'https://example.com/receipt.pdf',
    'created_at': '2026-03-15T10:00:00Z',
    'updated_at': '2026-03-15T10:00:00Z',
  };

  final sampleCreatePayload = {
    'user_id': 42,
    'department_id': 3,
    'date': '2026-03-15',
    'description': 'Office supplies purchase',
    'amount': '15000.00',
    'category': 'office_supplies',
    'status': 'pending',
    'attachment': 'https://example.com/receipt.pdf',
  };

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: baseUrl));
    dioAdapter = DioAdapter(dio: dio);
    service = ExpenseService(dioOverride: dio);
  });

  group('getExpenses', () {
    test('should return list of Expense on success (items wrapper)', () async {
      dioAdapter.onGet(
        '/expenses/',
        (server) => server.reply(200, {
          'items': [sampleExpenseJson, sampleExpenseJson],
          'count': 2,
        }),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      final result = await service.getExpenses(token);

      expect(result.items, isA<List<Expense>>());
      expect(result.items.length, 2);
      expect(result.total, 2);
      expect(result.items.first.id, 1);
      expect(result.items.first.userId, 42);
      expect(result.items.first.department.id, 3);
      expect(result.items.first.department.name, 'Engineering');
      expect(result.items.first.amount, '15000.00');
      expect(result.items.first.category, 'office_supplies');
      expect(result.items.first.status, 'pending');
    });

    test('should return list of Expense on success (plain list)', () async {
      dioAdapter.onGet(
        '/expenses/',
        (server) => server.reply(200, [sampleExpenseJson]),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      final result = await service.getExpenses(token);

      expect(result.items.length, 1);
      expect(result.total, 1);
    });

    test('should handle empty list', () async {
      dioAdapter.onGet(
        '/expenses/',
        (server) => server.reply(200, {'items': [], 'count': 0}),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      final result = await service.getExpenses(token);

      expect(result.items, isEmpty);
      expect(result.total, 0);
    });

    test('should throw on 500 error', () async {
      dioAdapter.onGet(
        '/expenses/',
        (server) => server.reply(500, {'message': 'Internal server error'}),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      expect(
        () => service.getExpenses(token),
        throwsA(isA<Exception>()),
      );
    });

    test('should pass query parameters', () async {
      dioAdapter.onGet(
        '/expenses/',
        (server) => server.reply(200, [sampleExpenseJson]),
        queryParameters: {
          'search': 'supplies',
          'status': 'pending',
          'category': 'office_supplies',
          'user_id': 42,
          'department_id': 3,
          'limit': 50,
          'offset': 10,
        },
      );

      final result = await service.getExpenses(
        token,
        search: 'supplies',
        status: 'pending',
        category: 'office_supplies',
        userId: 42,
        departmentId: 3,
        limit: 50,
        offset: 10,
      );

      expect(result.items.length, 1);
    });
  });

  group('createExpense', () {
    test('should return Expense on success', () async {
      dioAdapter.onPost(
        '/expenses/',
        (server) => server.reply(201, sampleExpenseJson),
        data: sampleCreatePayload,
      );

      final result = await service.createExpense(token, sampleCreatePayload);

      expect(result, isA<Expense>());
      expect(result.id, 1);
      expect(result.description, 'Office supplies purchase');
    });

    test('should throw on 400 error', () async {
      dioAdapter.onPost(
        '/expenses/',
        (server) => server.reply(400, {'message': 'Invalid data'}),
        data: sampleCreatePayload,
      );

      expect(
        () => service.createExpense(token, sampleCreatePayload),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 500 error', () async {
      dioAdapter.onPost(
        '/expenses/',
        (server) => server.reply(500, {'message': 'Server error'}),
        data: sampleCreatePayload,
      );

      expect(
        () => service.createExpense(token, sampleCreatePayload),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getExpenseById', () {
    test('should return Expense on success', () async {
      dioAdapter.onGet(
        '/expenses/1',
        (server) => server.reply(200, sampleExpenseJson),
      );

      final result = await service.getExpenseById(token, 1);

      expect(result, isA<Expense>());
      expect(result.id, 1);
      expect(result.amount, '15000.00');
    });

    test('should throw on 404 error', () async {
      dioAdapter.onGet(
        '/expenses/999',
        (server) => server.reply(404, {'message': 'Expense not found'}),
      );

      expect(
        () => service.getExpenseById(token, 999),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 500 error', () async {
      dioAdapter.onGet(
        '/expenses/1',
        (server) => server.reply(500, {'message': 'Server error'}),
      );

      expect(
        () => service.getExpenseById(token, 1),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('updateExpense', () {
    test('should return updated Expense on success', () async {
      final updatedJson = {
        ...sampleExpenseJson,
        'amount': '25000.00',
      };

      dioAdapter.onPut(
        '/expenses/1',
        (server) => server.reply(200, updatedJson),
        data: sampleCreatePayload,
      );

      final result = await service.updateExpense(token, 1, sampleCreatePayload);

      expect(result, isA<Expense>());
      expect(result.amount, '25000.00');
    });

    test('should throw on 400 error', () async {
      dioAdapter.onPut(
        '/expenses/1',
        (server) => server.reply(400, {'message': 'Invalid data'}),
        data: sampleCreatePayload,
      );

      expect(
        () => service.updateExpense(token, 1, sampleCreatePayload),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 500 error', () async {
      dioAdapter.onPut(
        '/expenses/1',
        (server) => server.reply(500, {'message': 'Server error'}),
        data: sampleCreatePayload,
      );

      expect(
        () => service.updateExpense(token, 1, sampleCreatePayload),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('deleteExpense', () {
    test('should complete without error on success', () async {
      dioAdapter.onDelete(
        '/expenses/1',
        (server) => server.reply(204, null),
      );

      await expectLater(
        service.deleteExpense(token, 1),
        completes,
      );
    });

    test('should throw on 404 error', () async {
      dioAdapter.onDelete(
        '/expenses/999',
        (server) => server.reply(404, {'message': 'Expense not found'}),
      );

      expect(
        () => service.deleteExpense(token, 999),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 500 error', () async {
      dioAdapter.onDelete(
        '/expenses/1',
        (server) => server.reply(500, {'message': 'Server error'}),
      );

      expect(
        () => service.deleteExpense(token, 1),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('approveExpense', () {
    test('should return approved Expense on success', () async {
      final approvedJson = {
        ...sampleExpenseJson,
        'status': 'approved',
      };

      dioAdapter.onPost(
        '/expenses/1/approve',
        (server) => server.reply(200, approvedJson),
      );

      final result = await service.approveExpense(token, 1);

      expect(result, isA<Expense>());
      expect(result.status, 'approved');
    });

    test('should throw on 400 error', () async {
      dioAdapter.onPost(
        '/expenses/1/approve',
        (server) => server.reply(400, {'message': 'Cannot approve'}),
      );

      expect(
        () => service.approveExpense(token, 1),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 403 error', () async {
      dioAdapter.onPost(
        '/expenses/1/approve',
        (server) => server.reply(403, {'message': 'Not authorized'}),
      );

      expect(
        () => service.approveExpense(token, 1),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 500 error', () async {
      dioAdapter.onPost(
        '/expenses/1/approve',
        (server) => server.reply(500, {'message': 'Server error'}),
      );

      expect(
        () => service.approveExpense(token, 1),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('rejectExpense', () {
    test('should return rejected Expense on success', () async {
      final rejectedJson = {
        ...sampleExpenseJson,
        'status': 'rejected',
      };

      dioAdapter.onPost(
        '/expenses/1/reject',
        (server) => server.reply(200, rejectedJson),
      );

      final result = await service.rejectExpense(token, 1);

      expect(result, isA<Expense>());
      expect(result.status, 'rejected');
    });

    test('should throw on 400 error', () async {
      dioAdapter.onPost(
        '/expenses/1/reject',
        (server) => server.reply(400, {'message': 'Cannot reject'}),
      );

      expect(
        () => service.rejectExpense(token, 1),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 403 error', () async {
      dioAdapter.onPost(
        '/expenses/1/reject',
        (server) => server.reply(403, {'message': 'Not authorized'}),
      );

      expect(
        () => service.rejectExpense(token, 1),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 500 error', () async {
      dioAdapter.onPost(
        '/expenses/1/reject',
        (server) => server.reply(500, {'message': 'Server error'}),
      );

      expect(
        () => service.rejectExpense(token, 1),
        throwsA(isA<Exception>()),
      );
    });
  });
}
