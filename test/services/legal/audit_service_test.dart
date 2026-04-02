import 'package:bms_front_end/pages/legal/models/audit_model.dart';
import 'package:bms_front_end/src/constants/api_constants.dart';
import 'package:bms_front_end/src/services/legal/audit_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late AuditService service;

  const token = 'test-token-123';
  const baseUrl = '${ApiConstants.baseUrl}/api/v1';

  final sampleAuditJson = {
    'id': 1,
    'audit_name': 'ISO 9001:2015 Quality Management System Audit',
    'audit_type': 'external',
    'audit_type_display': 'External',
    'auditor_name': 'Mrs. Funmi Adebayo',
    'auditor_title': 'Lead Auditor',
    'status': 'completed',
    'status_display': 'Completed',
    'score': 87,
    'score_percentage': '87%',
    'is_passed': true,
    'score_category': 'Good',
    'audit_date': '2024-03-15',
    'audit_number': 'QMS-AUD-2024-001',
    'description': 'Comprehensive internal audit of quality management systems',
    'findings': 'Minor non-conformities in document control',
    'recommendations': 'Update document control procedures',
    'start_date': '2024-03-10',
    'end_date': '2024-03-15',
    'auditor_organization': 'Quality Assurance Ltd',
    'department': 'Engineering',
    'created_at': '2024-03-01T10:00:00Z',
    'updated_at': '2024-03-15T14:30:00Z',
  };

  final sampleCreatePayload = {
    'audit_name': 'ISO 9001:2015 Quality Management System Audit',
    'audit_type': 'external',
    'auditor_name': 'Mrs. Funmi Adebayo',
    'audit_date': '2024-03-15',
    'description': 'Comprehensive internal audit of quality management systems',
  };

  final sampleStatisticsJson = {
    'total_audits': 20,
    'completed_audits': 12,
    'in_progress_audits': 4,
    'scheduled_audits': 3,
    'cancelled_audits': 1,
    'passed_audits': 10,
    'failed_audits': 2,
    'average_score': 82.5,
    'audits_by_type': {
      'external': 8,
      'internal': 7,
      'regulatory': 5,
    },
    'audits_by_department': {
      'Engineering': 6,
      'Finance': 4,
      'HR': 3,
    },
  };

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: baseUrl));
    dioAdapter = DioAdapter(dio: dio);
    service = AuditService(dioOverride: dio);
  });

  group('getAudits', () {
    test('should return list of Audit on success (items wrapper)', () async {
      dioAdapter.onGet(
        '/audits/',
        (server) => server.reply(200, {
          'items': [sampleAuditJson, sampleAuditJson],
          'count': 2,
        }),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      final result = await service.getAudits(token);

      expect(result.items, isA<List<Audit>>());
      expect(result.items.length, 2);
      expect(result.total, 2);
      expect(result.items.first.id, 1);
      expect(result.items.first.auditName,
          'ISO 9001:2015 Quality Management System Audit');
      expect(result.items.first.auditType, 'external');
      expect(result.items.first.auditTypeDisplay, 'External');
      expect(result.items.first.auditorName, 'Mrs. Funmi Adebayo');
      expect(result.items.first.status, 'completed');
      expect(result.items.first.score, 87);
      expect(result.items.first.scorePercentage, '87%');
      expect(result.items.first.isPassed, true);
      expect(result.items.first.scoreCategory, 'Good');
    });

    test('should return list of Audit on success (plain list)', () async {
      dioAdapter.onGet(
        '/audits/',
        (server) => server.reply(200, [sampleAuditJson]),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      final result = await service.getAudits(token);

      expect(result.items.length, 1);
      expect(result.total, 1);
    });

    test('should handle empty list', () async {
      dioAdapter.onGet(
        '/audits/',
        (server) => server.reply(200, {'items': [], 'count': 0}),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      final result = await service.getAudits(token);

      expect(result.items, isEmpty);
      expect(result.total, 0);
    });

    test('should throw on 500 error', () async {
      dioAdapter.onGet(
        '/audits/',
        (server) => server.reply(500, {'message': 'Internal server error'}),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      expect(
        () => service.getAudits(token),
        throwsA(isA<Exception>()),
      );
    });

    test('should pass query parameters', () async {
      dioAdapter.onGet(
        '/audits/',
        (server) => server.reply(200, [sampleAuditJson]),
        queryParameters: {
          'search': 'ISO',
          'audit_type': 'external',
          'status': 'completed',
          'auditor_name': 'Mrs. Funmi Adebayo',
          'department': 'Engineering',
          'min_score': 70,
          'max_score': 100,
          'start_date': '2024-01-01',
          'end_date': '2024-12-31',
          'limit': 50,
          'offset': 10,
        },
      );

      final result = await service.getAudits(
        token,
        search: 'ISO',
        auditType: 'external',
        status: 'completed',
        auditorName: 'Mrs. Funmi Adebayo',
        department: 'Engineering',
        minScore: 70,
        maxScore: 100,
        startDate: '2024-01-01',
        endDate: '2024-12-31',
        limit: 50,
        offset: 10,
      );

      expect(result.items.length, 1);
    });
  });

  group('createAudit', () {
    test('should return Audit on success', () async {
      dioAdapter.onPost(
        '/audits/',
        (server) => server.reply(201, sampleAuditJson),
        data: sampleCreatePayload,
      );

      final result = await service.createAudit(token, sampleCreatePayload);

      expect(result, isA<Audit>());
      expect(result.id, 1);
      expect(result.auditName, 'ISO 9001:2015 Quality Management System Audit');
    });

    test('should throw on 400 error', () async {
      dioAdapter.onPost(
        '/audits/',
        (server) => server.reply(400, {'message': 'Invalid data'}),
        data: sampleCreatePayload,
      );

      expect(
        () => service.createAudit(token, sampleCreatePayload),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 500 error', () async {
      dioAdapter.onPost(
        '/audits/',
        (server) => server.reply(500, {'message': 'Server error'}),
        data: sampleCreatePayload,
      );

      expect(
        () => service.createAudit(token, sampleCreatePayload),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getStatistics', () {
    test('should return AuditStatistics on success', () async {
      dioAdapter.onGet(
        '/audits/statistics/overview/',
        (server) => server.reply(200, sampleStatisticsJson),
      );

      final result = await service.getStatistics(token);

      expect(result, isA<AuditStatistics>());
      expect(result.totalAudits, 20);
      expect(result.completedAudits, 12);
      expect(result.inProgressAudits, 4);
      expect(result.scheduledAudits, 3);
      expect(result.cancelledAudits, 1);
      expect(result.passedAudits, 10);
      expect(result.failedAudits, 2);
      expect(result.averageScore, 82.5);
      expect(result.auditsByType['external'], 8);
      expect(result.auditsByType['internal'], 7);
      expect(result.auditsByDepartment['Engineering'], 6);
    });

    test('should throw on 500 error', () async {
      dioAdapter.onGet(
        '/audits/statistics/overview/',
        (server) => server.reply(500, {'message': 'Server error'}),
      );

      expect(
        () => service.getStatistics(token),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getAuditById', () {
    test('should return Audit on success', () async {
      dioAdapter.onGet(
        '/audits/1/',
        (server) => server.reply(200, sampleAuditJson),
      );

      final result = await service.getAuditById(token, 1);

      expect(result, isA<Audit>());
      expect(result.id, 1);
      expect(result.auditName, 'ISO 9001:2015 Quality Management System Audit');
    });

    test('should throw on 404 error', () async {
      dioAdapter.onGet(
        '/audits/999/',
        (server) => server.reply(404, {'message': 'Audit not found'}),
      );

      expect(
        () => service.getAuditById(token, 999),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 500 error', () async {
      dioAdapter.onGet(
        '/audits/1/',
        (server) => server.reply(500, {'message': 'Server error'}),
      );

      expect(
        () => service.getAuditById(token, 1),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('updateAudit', () {
    test('should return updated Audit on success', () async {
      final updatedJson = {
        ...sampleAuditJson,
        'score': 92,
        'score_percentage': '92%',
      };

      dioAdapter.onPut(
        '/audits/1/',
        (server) => server.reply(200, updatedJson),
        data: sampleCreatePayload,
      );

      final result = await service.updateAudit(token, 1, sampleCreatePayload);

      expect(result, isA<Audit>());
      expect(result.score, 92);
      expect(result.scorePercentage, '92%');
    });

    test('should throw on 400 error', () async {
      dioAdapter.onPut(
        '/audits/1/',
        (server) => server.reply(400, {'message': 'Invalid data'}),
        data: sampleCreatePayload,
      );

      expect(
        () => service.updateAudit(token, 1, sampleCreatePayload),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 500 error', () async {
      dioAdapter.onPut(
        '/audits/1/',
        (server) => server.reply(500, {'message': 'Server error'}),
        data: sampleCreatePayload,
      );

      expect(
        () => service.updateAudit(token, 1, sampleCreatePayload),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('deleteAudit', () {
    test('should complete without error on success', () async {
      dioAdapter.onDelete(
        '/audits/1/',
        (server) => server.reply(204, null),
      );

      await expectLater(
        service.deleteAudit(token, 1),
        completes,
      );
    });

    test('should throw on 404 error', () async {
      dioAdapter.onDelete(
        '/audits/999/',
        (server) => server.reply(404, {'message': 'Audit not found'}),
      );

      expect(
        () => service.deleteAudit(token, 999),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 500 error', () async {
      dioAdapter.onDelete(
        '/audits/1/',
        (server) => server.reply(500, {'message': 'Server error'}),
      );

      expect(
        () => service.deleteAudit(token, 1),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('updateAuditStatus', () {
    test('should return updated Audit on success', () async {
      final updatedJson = {
        ...sampleAuditJson,
        'status': 'in_progress',
        'status_display': 'In Progress',
      };

      dioAdapter.onPatch(
        '/audits/1/status/',
        (server) => server.reply(200, updatedJson),
        data: {'status': 'in_progress'},
      );

      final result = await service.updateAuditStatus(token, 1, 'in_progress');

      expect(result, isA<Audit>());
      expect(result.status, 'in_progress');
      expect(result.statusDisplay, 'In Progress');
    });

    test('should throw on 400 error', () async {
      dioAdapter.onPatch(
        '/audits/1/status/',
        (server) => server.reply(400, {'message': 'Invalid status'}),
        data: {'status': 'invalid'},
      );

      expect(
        () => service.updateAuditStatus(token, 1, 'invalid'),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 500 error', () async {
      dioAdapter.onPatch(
        '/audits/1/status/',
        (server) => server.reply(500, {'message': 'Server error'}),
        data: {'status': 'completed'},
      );

      expect(
        () => service.updateAuditStatus(token, 1, 'completed'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('updateAuditScore', () {
    test('should return updated Audit on success', () async {
      final updatedJson = {
        ...sampleAuditJson,
        'score': 95,
        'score_percentage': '95%',
        'score_category': 'Excellent',
      };

      dioAdapter.onPatch(
        '/audits/1/score/',
        (server) => server.reply(200, updatedJson),
        data: {'score': 95},
      );

      final result = await service.updateAuditScore(token, 1, 95);

      expect(result, isA<Audit>());
      expect(result.score, 95);
      expect(result.scorePercentage, '95%');
      expect(result.scoreCategory, 'Excellent');
    });

    test('should throw on 400 error', () async {
      dioAdapter.onPatch(
        '/audits/1/score/',
        (server) => server.reply(400, {'message': 'Invalid score'}),
        data: {'score': -1},
      );

      expect(
        () => service.updateAuditScore(token, 1, -1),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 500 error', () async {
      dioAdapter.onPatch(
        '/audits/1/score/',
        (server) => server.reply(500, {'message': 'Server error'}),
        data: {'score': 90},
      );

      expect(
        () => service.updateAuditScore(token, 1, 90),
        throwsA(isA<Exception>()),
      );
    });
  });
}
