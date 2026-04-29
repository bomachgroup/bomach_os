import 'package:bomach_os/pages/legal/models/legal_case_model.dart';
import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:bomach_os/src/services/legal/legal_case_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late LegalCaseService service;

  const token = 'test-token-123';
  final baseUrl = '${ApiConstants.baseUrl}/api/v1';

  final sampleCaseJson = {
    'id': 1,
    'case_name': 'Bomach vs. Delta Construction',
    'case_type': 'contract_dispute',
    'case_type_display': 'Contract Dispute',
    'status': 'in_progress',
    'status_display': 'In Progress',
    'exposure': '8500000.00',
    'next_hearing': '2024-04-10',
    'case_number': 'CASE-2024-001',
    'description': 'Boundary dispute arising from survey inaccuracies',
    'date_filed': '2024-01-15',
    'date_closed': null,
    'created_at': '2024-01-15T10:00:00Z',
    'updated_at': '2024-03-01T14:30:00Z',
  };

  final sampleCreatePayload = {
    'case_name': 'Bomach vs. Delta Construction',
    'case_type': 'contract_dispute',
    'description': 'Boundary dispute arising from survey inaccuracies',
  };

  final sampleStatisticsJson = {
    'total_cases': 25,
    'open_cases': 5,
    'in_progress_cases': 8,
    'settled_cases': 4,
    'closed_cases': 3,
    'won_cases': 2,
    'lost_cases': 1,
    'dismissed_cases': 1,
    'pending_cases': 1,
    'total_exposure': '50000000.00',
    'upcoming_hearings': 3,
    'cases_by_type': {
      'contract_dispute': 10,
      'employment': 5,
      'regulatory': 3,
    },
  };

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: baseUrl));
    dioAdapter = DioAdapter(dio: dio);
    service = LegalCaseService(dioOverride: dio);
  });

  group('getCases', () {
    test('should return list of LegalCase on success (items wrapper)',
        () async {
      dioAdapter.onGet(
        '/cases/',
        (server) => server.reply(200, {
          'items': [sampleCaseJson, sampleCaseJson],
          'count': 2,
        }),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      final result = await service.getCases(token);

      expect(result.items, isA<List<LegalCase>>());
      expect(result.items.length, 2);
      expect(result.total, 2);
      expect(result.items.first.id, 1);
      expect(result.items.first.caseName, 'Bomach vs. Delta Construction');
      expect(result.items.first.caseType, 'contract_dispute');
      expect(result.items.first.caseTypeDisplay, 'Contract Dispute');
      expect(result.items.first.status, 'in_progress');
      expect(result.items.first.statusDisplay, 'In Progress');
      expect(result.items.first.exposure, '8500000.00');
      expect(result.items.first.nextHearing, '2024-04-10');
      expect(result.items.first.caseNumber, 'CASE-2024-001');
    });

    test('should return list of LegalCase on success (plain list)', () async {
      dioAdapter.onGet(
        '/cases/',
        (server) => server.reply(200, [sampleCaseJson]),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      final result = await service.getCases(token);

      expect(result.items.length, 1);
      expect(result.total, 1);
    });

    test('should handle empty list', () async {
      dioAdapter.onGet(
        '/cases/',
        (server) => server.reply(200, {'items': [], 'count': 0}),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      final result = await service.getCases(token);

      expect(result.items, isEmpty);
      expect(result.total, 0);
    });

    test('should throw on 500 error', () async {
      dioAdapter.onGet(
        '/cases/',
        (server) => server.reply(500, {'message': 'Internal server error'}),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      expect(
        () => service.getCases(token),
        throwsA(isA<Exception>()),
      );
    });

    test('should pass query parameters', () async {
      dioAdapter.onGet(
        '/cases/',
        (server) => server.reply(200, [sampleCaseJson]),
        queryParameters: {
          'search': 'boundary',
          'case_type': 'contract_dispute',
          'status': 'in_progress',
          'start_date': '2024-01-01',
          'end_date': '2024-12-31',
          'has_upcoming_hearing': true,
          'limit': 50,
          'offset': 10,
        },
      );

      final result = await service.getCases(
        token,
        search: 'boundary',
        caseType: 'contract_dispute',
        status: 'in_progress',
        startDate: '2024-01-01',
        endDate: '2024-12-31',
        hasUpcomingHearing: true,
        limit: 50,
        offset: 10,
      );

      expect(result.items.length, 1);
    });
  });

  group('createCase', () {
    test('should return LegalCase on success', () async {
      dioAdapter.onPost(
        '/cases/',
        (server) => server.reply(201, sampleCaseJson),
        data: sampleCreatePayload,
      );

      final result = await service.createCase(token, sampleCreatePayload);

      expect(result, isA<LegalCase>());
      expect(result.id, 1);
      expect(result.caseName, 'Bomach vs. Delta Construction');
    });

    test('should throw on 400 error', () async {
      dioAdapter.onPost(
        '/cases/',
        (server) => server.reply(400, {'message': 'Invalid data'}),
        data: sampleCreatePayload,
      );

      expect(
        () => service.createCase(token, sampleCreatePayload),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 500 error', () async {
      dioAdapter.onPost(
        '/cases/',
        (server) => server.reply(500, {'message': 'Server error'}),
        data: sampleCreatePayload,
      );

      expect(
        () => service.createCase(token, sampleCreatePayload),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getStatistics', () {
    test('should return LegalCaseStatistics on success', () async {
      dioAdapter.onGet(
        '/cases/statistics/overview/',
        (server) => server.reply(200, sampleStatisticsJson),
      );

      final result = await service.getStatistics(token);

      expect(result, isA<LegalCaseStatistics>());
      expect(result.totalCases, 25);
      expect(result.openCases, 5);
      expect(result.inProgressCases, 8);
      expect(result.settledCases, 4);
      expect(result.closedCases, 3);
      expect(result.wonCases, 2);
      expect(result.lostCases, 1);
      expect(result.dismissedCases, 1);
      expect(result.pendingCases, 1);
      expect(result.totalExposure, '50000000.00');
      expect(result.upcomingHearings, 3);
      expect(result.casesByType['contract_dispute'], 10);
      expect(result.casesByType['employment'], 5);
    });

    test('should throw on 500 error', () async {
      dioAdapter.onGet(
        '/cases/statistics/overview/',
        (server) => server.reply(500, {'message': 'Server error'}),
      );

      expect(
        () => service.getStatistics(token),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getUpcomingHearings', () {
    test('should return list of LegalCase on success', () async {
      dioAdapter.onGet(
        '/cases/upcoming-hearings/',
        (server) => server.reply(200, [sampleCaseJson, sampleCaseJson]),
        queryParameters: {'days': 30},
      );

      final result = await service.getUpcomingHearings(token);

      expect(result, isA<List<LegalCase>>());
      expect(result.length, 2);
      expect(result.first.nextHearing, '2024-04-10');
    });

    test('should handle empty list', () async {
      dioAdapter.onGet(
        '/cases/upcoming-hearings/',
        (server) => server.reply(200, []),
        queryParameters: {'days': 30},
      );

      final result = await service.getUpcomingHearings(token);

      expect(result, isEmpty);
    });

    test('should throw on 500 error', () async {
      dioAdapter.onGet(
        '/cases/upcoming-hearings/',
        (server) => server.reply(500, {'message': 'Server error'}),
        queryParameters: {'days': 30},
      );

      expect(
        () => service.getUpcomingHearings(token),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getCaseById', () {
    test('should return LegalCase on success', () async {
      dioAdapter.onGet(
        '/cases/1/',
        (server) => server.reply(200, sampleCaseJson),
      );

      final result = await service.getCaseById(token, 1);

      expect(result, isA<LegalCase>());
      expect(result.id, 1);
      expect(result.caseName, 'Bomach vs. Delta Construction');
    });

    test('should throw on 404 error', () async {
      dioAdapter.onGet(
        '/cases/999/',
        (server) => server.reply(404, {'message': 'Case not found'}),
      );

      expect(
        () => service.getCaseById(token, 999),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 500 error', () async {
      dioAdapter.onGet(
        '/cases/1/',
        (server) => server.reply(500, {'message': 'Server error'}),
      );

      expect(
        () => service.getCaseById(token, 1),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('updateCase', () {
    test('should return updated LegalCase on success', () async {
      final updatedJson = {
        ...sampleCaseJson,
        'status': 'settled',
        'status_display': 'Settled',
      };

      dioAdapter.onPut(
        '/cases/1/',
        (server) => server.reply(200, updatedJson),
        data: sampleCreatePayload,
      );

      final result = await service.updateCase(token, 1, sampleCreatePayload);

      expect(result, isA<LegalCase>());
      expect(result.status, 'settled');
      expect(result.statusDisplay, 'Settled');
    });

    test('should throw on 400 error', () async {
      dioAdapter.onPut(
        '/cases/1/',
        (server) => server.reply(400, {'message': 'Invalid data'}),
        data: sampleCreatePayload,
      );

      expect(
        () => service.updateCase(token, 1, sampleCreatePayload),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 500 error', () async {
      dioAdapter.onPut(
        '/cases/1/',
        (server) => server.reply(500, {'message': 'Server error'}),
        data: sampleCreatePayload,
      );

      expect(
        () => service.updateCase(token, 1, sampleCreatePayload),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('deleteCase', () {
    test('should complete without error on success', () async {
      dioAdapter.onDelete(
        '/cases/1/',
        (server) => server.reply(204, null),
      );

      await expectLater(
        service.deleteCase(token, 1),
        completes,
      );
    });

    test('should throw on 404 error', () async {
      dioAdapter.onDelete(
        '/cases/999/',
        (server) => server.reply(404, {'message': 'Case not found'}),
      );

      expect(
        () => service.deleteCase(token, 999),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 500 error', () async {
      dioAdapter.onDelete(
        '/cases/1/',
        (server) => server.reply(500, {'message': 'Server error'}),
      );

      expect(
        () => service.deleteCase(token, 1),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('updateCaseStatus', () {
    test('should return updated LegalCase on success', () async {
      final updatedJson = {
        ...sampleCaseJson,
        'status': 'closed',
        'status_display': 'Closed',
      };

      dioAdapter.onPatch(
        '/cases/1/status/',
        (server) => server.reply(200, updatedJson),
        data: {'status': 'closed'},
      );

      final result = await service.updateCaseStatus(token, 1, 'closed');

      expect(result, isA<LegalCase>());
      expect(result.status, 'closed');
      expect(result.statusDisplay, 'Closed');
    });

    test('should throw on 400 error', () async {
      dioAdapter.onPatch(
        '/cases/1/status/',
        (server) => server.reply(400, {'message': 'Invalid status'}),
        data: {'status': 'invalid'},
      );

      expect(
        () => service.updateCaseStatus(token, 1, 'invalid'),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 500 error', () async {
      dioAdapter.onPatch(
        '/cases/1/status/',
        (server) => server.reply(500, {'message': 'Server error'}),
        data: {'status': 'closed'},
      );

      expect(
        () => service.updateCaseStatus(token, 1, 'closed'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
