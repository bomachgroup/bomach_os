import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:bomach_os/src/services/hr/employee_evaluation_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late EmployeeEvaluationService service;

  const token = 'test-token-123';
  final baseUrl = '${ApiConstants.baseUrl}/api/v1';

  final sampleEvaluation = {
    'id': 1,
    'employee_id': 42,
    'evaluator_id': 'eval-001',
    'month': 3,
    'year': 2026,
    'manager_comments': 'Excellent work this quarter',
    'promotion_required': true,
    'training_required': false,
    'salary_increase': true,
    'created_at': '2026-03-15T10:00:00Z',
    'updated_at': '2026-03-15T10:00:00Z',
  };

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: baseUrl));
    dioAdapter = DioAdapter(dio: dio);
    service = EmployeeEvaluationService(dioOverride: dio);
  });

  group('createEvaluation', () {
    test('should return evaluation data on success', () async {
      dioAdapter.onPost(
        '/employee-evaluations/',
        (server) => server.reply(201, sampleEvaluation),
        data: {
          'employee_id': 42,
          'evaluator_id': 'eval-001',
          'month': 3,
          'year': 2026,
          'manager_comments': 'Excellent work this quarter',
          'promotion_required': true,
          'training_required': false,
          'salary_increase': true,
        },
      );

      final result = await service.createEvaluation(
        token,
        employeeId: 42,
        evaluatorId: 'eval-001',
        month: 3,
        year: 2026,
        managerComments: 'Excellent work this quarter',
        promotionRequired: true,
        trainingRequired: false,
        salaryIncrease: true,
      );

      expect(result, isA<Map<String, dynamic>>());
      expect(result['id'], 1);
      expect(result['employee_id'], 42);
      expect(result['promotion_required'], true);
    });

    test('should throw on 400 error', () async {
      dioAdapter.onPost(
        '/employee-evaluations/',
        (server) => server.reply(400, {'message': 'Missing required fields'}),
        data: {
          'employee_id': 42,
          'evaluator_id': 'eval-001',
          'month': 3,
          'year': 2026,
          'manager_comments': '',
          'promotion_required': false,
          'training_required': false,
          'salary_increase': false,
        },
      );

      expect(
        () => service.createEvaluation(
          token,
          employeeId: 42,
          evaluatorId: 'eval-001',
          month: 3,
          year: 2026,
          managerComments: '',
          promotionRequired: false,
          trainingRequired: false,
          salaryIncrease: false,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 500 error', () async {
      dioAdapter.onPost(
        '/employee-evaluations/',
        (server) => server.reply(500, {'message': 'Internal server error'}),
        data: {
          'employee_id': 1,
          'evaluator_id': 'e1',
          'month': 1,
          'year': 2026,
          'manager_comments': 'test',
          'promotion_required': false,
          'training_required': false,
          'salary_increase': false,
        },
      );

      expect(
        () => service.createEvaluation(
          token,
          employeeId: 1,
          evaluatorId: 'e1',
          month: 1,
          year: 2026,
          managerComments: 'test',
          promotionRequired: false,
          trainingRequired: false,
          salaryIncrease: false,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('listEvaluations', () {
    test('should return list of evaluations on success', () async {
      dioAdapter.onGet(
        '/employee-evaluations/employee/42',
        (server) => server.reply(200, [sampleEvaluation, sampleEvaluation]),
        queryParameters: {'month': 3, 'year': 2026},
      );

      final result = await service.listEvaluations(
        token,
        employeeId: 42,
        month: 3,
        year: 2026,
      );

      expect(result, isA<List<Map<String, dynamic>>>());
      expect(result.length, 2);
      expect(result.first['id'], 1);
    });

    test('should handle empty list', () async {
      dioAdapter.onGet(
        '/employee-evaluations/employee/99',
        (server) => server.reply(200, []),
        queryParameters: <String, dynamic>{},
      );

      final result = await service.listEvaluations(
        token,
        employeeId: 99,
      );

      expect(result, isA<List<Map<String, dynamic>>>());
      expect(result, isEmpty);
    });

    test('should throw on 403 error', () async {
      dioAdapter.onGet(
        '/employee-evaluations/employee/42',
        (server) => server.reply(403, {'detail': 'Forbidden'}),
        queryParameters: <String, dynamic>{},
      );

      expect(
        () => service.listEvaluations(token, employeeId: 42),
        throwsA(isA<Exception>()),
      );
    });

    test('should work without optional month and year', () async {
      dioAdapter.onGet(
        '/employee-evaluations/employee/42',
        (server) => server.reply(200, [sampleEvaluation]),
        queryParameters: <String, dynamic>{},
      );

      final result = await service.listEvaluations(
        token,
        employeeId: 42,
      );

      expect(result.length, 1);
    });
  });

  group('getEvaluation', () {
    test('should return single evaluation on success', () async {
      dioAdapter.onGet(
        '/employee-evaluations/1',
        (server) => server.reply(200, sampleEvaluation),
      );

      final result = await service.getEvaluation(
        token,
        evaluationId: 1,
      );

      expect(result, isA<Map<String, dynamic>>());
      expect(result['id'], 1);
      expect(result['manager_comments'], 'Excellent work this quarter');
    });

    test('should throw on 404 error', () async {
      dioAdapter.onGet(
        '/employee-evaluations/999',
        (server) => server.reply(404, {'message': 'Not found'}),
      );

      expect(
        () => service.getEvaluation(token, evaluationId: 999),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 500 error', () async {
      dioAdapter.onGet(
        '/employee-evaluations/1',
        (server) => server.reply(500, {'message': 'Server error'}),
      );

      expect(
        () => service.getEvaluation(token, evaluationId: 1),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('updateEvaluation', () {
    test('should return updated evaluation on success', () async {
      dioAdapter.onPut(
        '/employee-evaluations/1',
        (server) => server.reply(200, {
          ...sampleEvaluation,
          'manager_comments': 'Updated comments',
          'promotion_required': false,
        }),
        data: {
          'manager_comments': 'Updated comments',
          'promotion_required': false,
        },
      );

      final result = await service.updateEvaluation(
        token,
        evaluationId: 1,
        managerComments: 'Updated comments',
        promotionRequired: false,
      );

      expect(result, isA<Map<String, dynamic>>());
      expect(result['manager_comments'], 'Updated comments');
      expect(result['promotion_required'], false);
    });

    test('should send only provided fields', () async {
      dioAdapter.onPut(
        '/employee-evaluations/1',
        (server) => server.reply(200, sampleEvaluation),
        data: {'salary_increase': true},
      );

      final result = await service.updateEvaluation(
        token,
        evaluationId: 1,
        salaryIncrease: true,
      );

      expect(result, isA<Map<String, dynamic>>());
    });

    test('should throw on 400 error', () async {
      dioAdapter.onPut(
        '/employee-evaluations/1',
        (server) => server.reply(400, {'message': 'Validation failed'}),
        data: {'manager_comments': ''},
      );

      expect(
        () => service.updateEvaluation(
          token,
          evaluationId: 1,
          managerComments: '',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
