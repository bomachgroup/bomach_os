import 'package:bomach_os/pages/finance/models/budget_model.dart';
import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:bomach_os/src/services/finance/budget_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late BudgetService service;

  const token = 'test-token-123';
  final baseUrl = '${ApiConstants.baseUrl}/api/v1';

  final sampleBudgetJson = {
    'id': 1,
    'branch_name': 'Lagos HQ',
    'department_name': 'Engineering',
    'fiscal_period': '2026-Q1',
    'amount': '500000.00',
    'current_spend': '120000.00',
    'remaining_budget': '380000.00',
  };

  final sampleCreatePayload = {
    'branch_id': 1,
    'department_id': 2,
    'fiscal_period': '2026-Q1',
    'amount': '500000.00',
  };

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: baseUrl));
    dioAdapter = DioAdapter(dio: dio);
    service = BudgetService(dioOverride: dio);
  });

  group('getBudgets', () {
    test('should return list of Budget on success (items wrapper)', () async {
      dioAdapter.onGet(
        '/budgets/',
        (server) => server.reply(200, {
          'items': [sampleBudgetJson, sampleBudgetJson],
          'count': 2,
        }),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      final result = await service.getBudgets(token);

      expect(result.items, isA<List<Budget>>());
      expect(result.items.length, 2);
      expect(result.total, 2);
      expect(result.items.first.id, 1);
      expect(result.items.first.branchName, 'Lagos HQ');
      expect(result.items.first.departmentName, 'Engineering');
      expect(result.items.first.fiscalPeriod, '2026-Q1');
      expect(result.items.first.amount, '500000.00');
      expect(result.items.first.currentSpend, '120000.00');
      expect(result.items.first.remainingBudget, '380000.00');
    });

    test('should return list of Budget on success (plain list)', () async {
      dioAdapter.onGet(
        '/budgets/',
        (server) => server.reply(200, [sampleBudgetJson]),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      final result = await service.getBudgets(token);

      expect(result.items.length, 1);
      expect(result.total, 1);
    });

    test('should handle empty list', () async {
      dioAdapter.onGet(
        '/budgets/',
        (server) => server.reply(200, {'items': [], 'count': 0}),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      final result = await service.getBudgets(token);

      expect(result.items, isEmpty);
      expect(result.total, 0);
    });

    test('should throw on 500 error', () async {
      dioAdapter.onGet(
        '/budgets/',
        (server) => server.reply(500, {'message': 'Internal server error'}),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      expect(
        () => service.getBudgets(token),
        throwsA(isA<Exception>()),
      );
    });

    test('should pass query parameters', () async {
      dioAdapter.onGet(
        '/budgets/',
        (server) => server.reply(200, [sampleBudgetJson]),
        queryParameters: {
          'search': 'Engineering',
          'fiscal_period': '2026-Q1',
          'department': 'Engineering',
          'branch': 'Lagos HQ',
          'limit': 50,
          'offset': 10,
        },
      );

      final result = await service.getBudgets(
        token,
        search: 'Engineering',
        fiscalPeriod: '2026-Q1',
        department: 'Engineering',
        branch: 'Lagos HQ',
        limit: 50,
        offset: 10,
      );

      expect(result.items.length, 1);
    });
  });

  group('createBudget', () {
    test('should return Budget on success', () async {
      dioAdapter.onPost(
        '/budgets/',
        (server) => server.reply(201, sampleBudgetJson),
        data: sampleCreatePayload,
      );

      final result = await service.createBudget(token, sampleCreatePayload);

      expect(result, isA<Budget>());
      expect(result.id, 1);
      expect(result.branchName, 'Lagos HQ');
    });

    test('should throw on 400 error', () async {
      dioAdapter.onPost(
        '/budgets/',
        (server) => server.reply(400, {'message': 'Invalid data'}),
        data: sampleCreatePayload,
      );

      expect(
        () => service.createBudget(token, sampleCreatePayload),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 500 error', () async {
      dioAdapter.onPost(
        '/budgets/',
        (server) => server.reply(500, {'message': 'Server error'}),
        data: sampleCreatePayload,
      );

      expect(
        () => service.createBudget(token, sampleCreatePayload),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getBudgetById', () {
    test('should return Budget on success', () async {
      dioAdapter.onGet(
        '/budgets/1',
        (server) => server.reply(200, sampleBudgetJson),
      );

      final result = await service.getBudgetById(token, 1);

      expect(result, isA<Budget>());
      expect(result.id, 1);
      expect(result.fiscalPeriod, '2026-Q1');
    });

    test('should throw on 404 error', () async {
      dioAdapter.onGet(
        '/budgets/999',
        (server) => server.reply(404, {'message': 'Budget not found'}),
      );

      expect(
        () => service.getBudgetById(token, 999),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 500 error', () async {
      dioAdapter.onGet(
        '/budgets/1',
        (server) => server.reply(500, {'message': 'Server error'}),
      );

      expect(
        () => service.getBudgetById(token, 1),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('updateBudget', () {
    test('should return updated Budget on success', () async {
      final updatedJson = {
        ...sampleBudgetJson,
        'amount': '750000.00',
      };

      dioAdapter.onPut(
        '/budgets/1',
        (server) => server.reply(200, updatedJson),
        data: sampleCreatePayload,
      );

      final result = await service.updateBudget(token, 1, sampleCreatePayload);

      expect(result, isA<Budget>());
      expect(result.amount, '750000.00');
    });

    test('should throw on 400 error', () async {
      dioAdapter.onPut(
        '/budgets/1',
        (server) => server.reply(400, {'message': 'Invalid data'}),
        data: sampleCreatePayload,
      );

      expect(
        () => service.updateBudget(token, 1, sampleCreatePayload),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 500 error', () async {
      dioAdapter.onPut(
        '/budgets/1',
        (server) => server.reply(500, {'message': 'Server error'}),
        data: sampleCreatePayload,
      );

      expect(
        () => service.updateBudget(token, 1, sampleCreatePayload),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('deleteBudget', () {
    test('should complete without error on success', () async {
      dioAdapter.onDelete(
        '/budgets/1',
        (server) => server.reply(204, null),
      );

      await expectLater(
        service.deleteBudget(token, 1),
        completes,
      );
    });

    test('should throw on 404 error', () async {
      dioAdapter.onDelete(
        '/budgets/999',
        (server) => server.reply(404, {'message': 'Budget not found'}),
      );

      expect(
        () => service.deleteBudget(token, 999),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 500 error', () async {
      dioAdapter.onDelete(
        '/budgets/1',
        (server) => server.reply(500, {'message': 'Server error'}),
      );

      expect(
        () => service.deleteBudget(token, 1),
        throwsA(isA<Exception>()),
      );
    });
  });
}
