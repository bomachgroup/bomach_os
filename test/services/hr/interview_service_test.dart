import 'package:bms_front_end/pages/hr/models/interview_model.dart';
import 'package:bms_front_end/src/constants/api_constants.dart';
import 'package:bms_front_end/src/services/hr/interview_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late InterviewService service;

  const token = 'test-token-123';
  final baseUrl = '${ApiConstants.baseUrl}/api/v1';
  const applicantId = 42;

  final sampleInterviewJson = {
    'id': 1,
    'applicant_id': applicantId,
    'interviewer_id': 5,
    'scheduled_at': '2026-04-01T10:00:00Z',
    'meeting_link': 'https://meet.example.com/abc123',
    'feedback': null,
    'status': 'scheduled',
    'created_at': '2026-03-15T08:00:00Z',
    'updated_at': '2026-03-15T08:00:00Z',
  };

  final sampleCreateInterview = Interview(
    applicantId: applicantId,
    interviewerId: 5,
    scheduledAt: '2026-04-01T10:00:00Z',
    meetingLink: 'https://meet.example.com/abc123',
  );

  final sampleCreatePayload = sampleCreateInterview.toCreateJson();

  final sampleUpdateInterview = Interview(
    applicantId: applicantId,
    interviewerId: 5,
    scheduledAt: '2026-04-02T14:00:00Z',
    meetingLink: 'https://meet.example.com/xyz789',
    status: 'rescheduled',
  );

  final sampleUpdatePayload = sampleUpdateInterview.toUpdateJson();

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: baseUrl));
    dioAdapter = DioAdapter(dio: dio);
    service = InterviewService(dioOverride: dio);
  });

  group('getInterviews', () {
    test('should return list of Interview on success (items wrapper)',
        () async {
      dioAdapter.onGet(
        '/applicants/$applicantId/interviews/',
        (server) => server.reply(200, {
          'items': [sampleInterviewJson, sampleInterviewJson],
          'count': 2,
        }),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      final result = await service.getInterviews(token, applicantId);

      expect(result.items, isA<List<Interview>>());
      expect(result.items.length, 2);
      expect(result.count, 2);
      expect(result.items.first.id, 1);
      expect(result.items.first.applicantId, applicantId);
      expect(result.items.first.interviewerId, 5);
      expect(result.items.first.scheduledAt, '2026-04-01T10:00:00Z');
      expect(result.items.first.meetingLink, 'https://meet.example.com/abc123');
      expect(result.items.first.status, 'scheduled');
    });

    test('should return list of Interview on success (plain list)', () async {
      dioAdapter.onGet(
        '/applicants/$applicantId/interviews/',
        (server) => server.reply(200, [sampleInterviewJson]),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      final result = await service.getInterviews(token, applicantId);

      expect(result.items.length, 1);
      expect(result.count, 1);
    });

    test('should handle empty list', () async {
      dioAdapter.onGet(
        '/applicants/$applicantId/interviews/',
        (server) => server.reply(200, {'items': [], 'count': 0}),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      final result = await service.getInterviews(token, applicantId);

      expect(result.items, isEmpty);
      expect(result.count, 0);
    });

    test('should pass pagination parameters', () async {
      dioAdapter.onGet(
        '/applicants/$applicantId/interviews/',
        (server) => server.reply(200, [sampleInterviewJson]),
        queryParameters: {'limit': 50, 'offset': 10},
      );

      final result = await service.getInterviews(
        token,
        applicantId,
        limit: 50,
        offset: 10,
      );

      expect(result.items.length, 1);
    });

    test('should throw on 500 error', () async {
      dioAdapter.onGet(
        '/applicants/$applicantId/interviews/',
        (server) => server.reply(500, {'message': 'Internal server error'}),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      expect(
        () => service.getInterviews(token, applicantId),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 400 error', () async {
      dioAdapter.onGet(
        '/applicants/$applicantId/interviews/',
        (server) => server.reply(400, {'message': 'Invalid applicant'}),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      expect(
        () => service.getInterviews(token, applicantId),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('createInterview', () {
    test('should return Interview on success', () async {
      dioAdapter.onPost(
        '/applicants/$applicantId/interviews/',
        (server) => server.reply(201, sampleInterviewJson),
        data: sampleCreatePayload,
      );

      final result = await service.createInterview(
          token, applicantId, sampleCreateInterview);

      expect(result, isA<Interview>());
      expect(result.id, 1);
      expect(result.interviewerId, 5);
      expect(result.scheduledAt, '2026-04-01T10:00:00Z');
    });

    test('should throw on 400 error', () async {
      dioAdapter.onPost(
        '/applicants/$applicantId/interviews/',
        (server) => server.reply(400, {'message': 'Invalid data'}),
        data: sampleCreatePayload,
      );

      expect(
        () =>
            service.createInterview(token, applicantId, sampleCreateInterview),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 500 error', () async {
      dioAdapter.onPost(
        '/applicants/$applicantId/interviews/',
        (server) => server.reply(500, {'message': 'Server error'}),
        data: sampleCreatePayload,
      );

      expect(
        () =>
            service.createInterview(token, applicantId, sampleCreateInterview),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getInterviewById', () {
    test('should return Interview on success', () async {
      dioAdapter.onGet(
        '/applicants/$applicantId/interviews/1',
        (server) => server.reply(200, sampleInterviewJson),
      );

      final result = await service.getInterviewById(token, applicantId, 1);

      expect(result, isA<Interview>());
      expect(result.id, 1);
      expect(result.applicantId, applicantId);
      expect(result.status, 'scheduled');
    });

    test('should throw on 404 error', () async {
      dioAdapter.onGet(
        '/applicants/$applicantId/interviews/999',
        (server) => server.reply(404, {'message': 'Interview not found'}),
      );

      expect(
        () => service.getInterviewById(token, applicantId, 999),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 500 error', () async {
      dioAdapter.onGet(
        '/applicants/$applicantId/interviews/1',
        (server) => server.reply(500, {'message': 'Server error'}),
      );

      expect(
        () => service.getInterviewById(token, applicantId, 1),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('updateInterview', () {
    test('should return updated Interview on success', () async {
      final updatedJson = {
        ...sampleInterviewJson,
        'scheduled_at': '2026-04-02T14:00:00Z',
        'status': 'rescheduled',
      };

      dioAdapter.onPatch(
        '/applicants/$applicantId/interviews/1',
        (server) => server.reply(200, updatedJson),
        data: sampleUpdatePayload,
      );

      final result = await service.updateInterview(
          token, applicantId, 1, sampleUpdateInterview);

      expect(result, isA<Interview>());
      expect(result.scheduledAt, '2026-04-02T14:00:00Z');
      expect(result.status, 'rescheduled');
    });

    test('should throw on 400 error', () async {
      dioAdapter.onPatch(
        '/applicants/$applicantId/interviews/1',
        (server) => server.reply(400, {'message': 'Invalid data'}),
        data: sampleUpdatePayload,
      );

      expect(
        () => service.updateInterview(
            token, applicantId, 1, sampleUpdateInterview),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 500 error', () async {
      dioAdapter.onPatch(
        '/applicants/$applicantId/interviews/1',
        (server) => server.reply(500, {'message': 'Server error'}),
        data: sampleUpdatePayload,
      );

      expect(
        () => service.updateInterview(
            token, applicantId, 1, sampleUpdateInterview),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('deleteInterview', () {
    test('should complete without error on success', () async {
      dioAdapter.onDelete(
        '/applicants/$applicantId/interviews/1',
        (server) => server.reply(204, null),
      );

      await expectLater(
        service.deleteInterview(token, applicantId, 1),
        completes,
      );
    });

    test('should throw on 404 error', () async {
      dioAdapter.onDelete(
        '/applicants/$applicantId/interviews/999',
        (server) => server.reply(404, {'message': 'Interview not found'}),
      );

      expect(
        () => service.deleteInterview(token, applicantId, 999),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 500 error', () async {
      dioAdapter.onDelete(
        '/applicants/$applicantId/interviews/1',
        (server) => server.reply(500, {'message': 'Server error'}),
      );

      expect(
        () => service.deleteInterview(token, applicantId, 1),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('submitFeedback', () {
    test('should return Interview with feedback on success', () async {
      final feedbackJson = {
        ...sampleInterviewJson,
        'feedback': 'Excellent candidate with strong skills.',
        'status': 'completed',
      };

      final feedbackData = {
        'feedback': 'Excellent candidate with strong skills.',
        'status': 'completed',
      };

      dioAdapter.onPatch(
        '/applicants/$applicantId/interviews/1/feedback',
        (server) => server.reply(200, feedbackJson),
        data: feedbackData,
      );

      final result = await service.submitFeedback(
        token,
        applicantId,
        1,
        feedback: 'Excellent candidate with strong skills.',
        status: 'completed',
      );

      expect(result, isA<Interview>());
      expect(result.feedback, 'Excellent candidate with strong skills.');
      expect(result.status, 'completed');
    });

    test('should submit feedback without status', () async {
      final feedbackJson = {
        ...sampleInterviewJson,
        'feedback': 'Good communication skills.',
      };

      final feedbackData = {
        'feedback': 'Good communication skills.',
      };

      dioAdapter.onPatch(
        '/applicants/$applicantId/interviews/1/feedback',
        (server) => server.reply(200, feedbackJson),
        data: feedbackData,
      );

      final result = await service.submitFeedback(
        token,
        applicantId,
        1,
        feedback: 'Good communication skills.',
      );

      expect(result, isA<Interview>());
      expect(result.feedback, 'Good communication skills.');
    });

    test('should throw on 400 error', () async {
      final feedbackData = {
        'feedback': '',
        'status': 'completed',
      };

      dioAdapter.onPatch(
        '/applicants/$applicantId/interviews/1/feedback',
        (server) => server.reply(400, {'message': 'Feedback cannot be empty'}),
        data: feedbackData,
      );

      expect(
        () => service.submitFeedback(
          token,
          applicantId,
          1,
          feedback: '',
          status: 'completed',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 500 error', () async {
      final feedbackData = {
        'feedback': 'Some feedback',
      };

      dioAdapter.onPatch(
        '/applicants/$applicantId/interviews/1/feedback',
        (server) => server.reply(500, {'message': 'Server error'}),
        data: feedbackData,
      );

      expect(
        () => service.submitFeedback(
          token,
          applicantId,
          1,
          feedback: 'Some feedback',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
