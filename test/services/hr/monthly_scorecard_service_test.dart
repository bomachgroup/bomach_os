import 'package:bms_front_end/pages/hr/models/monthly_scorecard_models.dart';
import 'package:bms_front_end/src/constants/api_constants.dart';
import 'package:bms_front_end/pages/hr/models/performance_leaderboard_models.dart';
import 'package:bms_front_end/src/services/hr/monthly_scorecard_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late MonthlyScorecardService service;

  const token = 'test-token-123';
  const baseUrl = '${ApiConstants.baseUrl}/api/v1';

  final sampleScorecardJson = {
    'id': 1,
    'employee_id': 42,
    'employee_name': 'John Doe',
    'employee_level': 'senior',
    'month': 3,
    'year': 2026,
    'attendance_score': 95.0,
    'task_delivery_score': 88.5,
    'report_accuracy_score': 92.0,
    'brand_contribution_score': 80.0,
    'training_progress_score': 75.0,
    'overall_score': 86.1,
    'target_score': 80.0,
    'target_achievement': 107.6,
    'ranking': 3,
    'is_auto_generated': false,
    'notes': 'Good performance',
    'created_at': '2026-03-01T00:00:00Z',
    'updated_at': '2026-03-15T00:00:00Z',
  };

  final sampleLeaderboardJson = {
    'month': 3,
    'year': 2026,
    'entries': [
      {
        'rank': 1,
        'employee_id': '10',
        'employee_name': 'Alice Smith',
        'branch': 'Lagos',
        'score': 95.5,
        'award': 'Employee of the Month',
      },
      {
        'rank': 2,
        'employee_id': '20',
        'employee_name': 'Bob Jones',
        'branch': 'Abuja',
        'score': 90.0,
        'award': null,
      },
    ],
    'avg_score': 85.0,
    'total_participants': 25,
  };

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: baseUrl));
    dioAdapter = DioAdapter(dio: dio);
    service = MonthlyScorecardService(dioOverride: dio);
  });

  group('getEmployeeScorecard', () {
    test('should return MonthlyScorecard on success', () async {
      dioAdapter.onGet(
        '/monthly-scorecards/employee/42',
        (server) => server.reply(200, sampleScorecardJson),
        queryParameters: {'month': 3, 'year': 2026},
      );

      final result = await service.getEmployeeScorecard(
        token,
        employeeId: '42',
        month: 3,
        year: 2026,
      );

      expect(result, isA<MonthlyScorecard>());
      expect(result.id, 1);
      expect(result.employeeId, 42);
      expect(result.employeeName, 'John Doe');
      expect(result.attendanceScore, 95.0);
      expect(result.overallScore, 86.1);
      expect(result.ranking, 3);
    });

    test('should throw on 400 error', () async {
      dioAdapter.onGet(
        '/monthly-scorecards/employee/42',
        (server) => server.reply(400, {'message': 'Invalid employee ID'}),
        queryParameters: {'month': 3, 'year': 2026},
      );

      expect(
        () => service.getEmployeeScorecard(
          token,
          employeeId: '42',
          month: 3,
          year: 2026,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 500 error', () async {
      dioAdapter.onGet(
        '/monthly-scorecards/employee/42',
        (server) => server.reply(500, {'message': 'Internal server error'}),
        queryParameters: {'month': 3, 'year': 2026},
      );

      expect(
        () => service.getEmployeeScorecard(
          token,
          employeeId: '42',
          month: 3,
          year: 2026,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('should handle response with minimal fields', () async {
      dioAdapter.onGet(
        '/monthly-scorecards/employee/42',
        (server) => server.reply(200, {
          'id': 2,
          'employee_id': 42,
          'month': 1,
          'year': 2026,
        }),
        queryParameters: {'month': 1, 'year': 2026},
      );

      final result = await service.getEmployeeScorecard(
        token,
        employeeId: '42',
        month: 1,
        year: 2026,
      );

      expect(result.id, 2);
      expect(result.employeeName, '');
      expect(result.attendanceScore, 0.0);
      expect(result.notes, '');
    });
  });

  group('getLeaderboard', () {
    test('should return LeaderboardResponse on success', () async {
      dioAdapter.onGet(
        '/monthly-scorecards/leaderboard',
        (server) => server.reply(200, sampleLeaderboardJson),
        queryParameters: {'month': 3, 'year': 2026},
      );

      final result = await service.getLeaderboard(
        token,
        month: 3,
        year: 2026,
      );

      expect(result, isA<LeaderboardResponse>());
      expect(result.month, 3);
      expect(result.year, 2026);
      expect(result.entries.length, 2);
      expect(result.entries.first.employeeName, 'Alice Smith');
      expect(result.avgScore, 85.0);
      expect(result.totalParticipants, 25);
    });

    test('should throw on 403 error', () async {
      dioAdapter.onGet(
        '/monthly-scorecards/leaderboard',
        (server) => server.reply(403, {'detail': 'Forbidden'}),
        queryParameters: {'month': 3, 'year': 2026},
      );

      expect(
        () => service.getLeaderboard(token, month: 3, year: 2026),
        throwsA(isA<Exception>()),
      );
    });

    test('should handle empty entries list', () async {
      dioAdapter.onGet(
        '/monthly-scorecards/leaderboard',
        (server) => server.reply(200, {
          'month': 3,
          'year': 2026,
          'entries': [],
          'avg_score': 0,
          'total_participants': 0,
        }),
        queryParameters: {'month': 3, 'year': 2026},
      );

      final result = await service.getLeaderboard(
        token,
        month: 3,
        year: 2026,
      );

      expect(result.entries, isEmpty);
      expect(result.totalParticipants, 0);
    });
  });

  group('updateScorecard', () {
    test('should return updated MonthlyScorecard on success', () async {
      dioAdapter.onPut(
        '/monthly-scorecards/1',
        (server) => server.reply(200, {
          ...sampleScorecardJson,
          'attendance_score': 98.0,
          'notes': 'Updated notes',
        }),
        data: {
          'attendance_score': 98.0,
          'notes': 'Updated notes',
        },
      );

      final result = await service.updateScorecard(
        token,
        scorecardId: 1,
        attendanceScore: 98.0,
        notes: 'Updated notes',
      );

      expect(result, isA<MonthlyScorecard>());
      expect(result.attendanceScore, 98.0);
      expect(result.notes, 'Updated notes');
    });

    test('should send only provided fields', () async {
      dioAdapter.onPut(
        '/monthly-scorecards/5',
        (server) => server.reply(200, sampleScorecardJson),
        data: {'task_delivery_score': 90.0},
      );

      final result = await service.updateScorecard(
        token,
        scorecardId: 5,
        taskDeliveryScore: 90.0,
      );

      expect(result, isA<MonthlyScorecard>());
    });

    test('should throw on 400 error', () async {
      dioAdapter.onPut(
        '/monthly-scorecards/1',
        (server) => server.reply(400, {'message': 'Validation failed'}),
        data: {'attendance_score': -10.0},
      );

      expect(
        () => service.updateScorecard(
          token,
          scorecardId: 1,
          attendanceScore: -10.0,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 500 error', () async {
      dioAdapter.onPut(
        '/monthly-scorecards/99',
        (server) => server.reply(500, {'message': 'Server error'}),
        data: {'notes': 'test'},
      );

      expect(
        () => service.updateScorecard(
          token,
          scorecardId: 99,
          notes: 'test',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
