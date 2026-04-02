import 'package:bms_front_end/pages/hr/models/offer_letter_model.dart';
import 'package:bms_front_end/src/constants/api_constants.dart';
import 'package:bms_front_end/src/services/hr/offer_letter_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late OfferLetterService service;

  const token = 'test-token-123';
  const baseUrl = '${ApiConstants.baseUrl}/api/v1';
  const applicantId = 42;

  final sampleOfferLetterJson = {
    'id': 1,
    'applicant_id': applicantId,
    'template': 'standard_offer',
    'annual_salary': '3500000.00',
    'start_date': '2026-05-01',
    'letter_content': 'Dear Applicant, we are pleased to offer you...',
    'status': 'draft',
    'sent_at': null,
    'created_at': '2026-03-15T08:00:00Z',
    'updated_at': '2026-03-15T08:00:00Z',
  };

  final sampleCreateOfferLetter = OfferLetter(
    applicantId: applicantId,
    template: 'standard_offer',
    annualSalary: '3500000.00',
    startDate: '2026-05-01',
    letterContent: 'Dear Applicant, we are pleased to offer you...',
  );

  final sampleCreatePayload = sampleCreateOfferLetter.toCreateJson();

  final sampleUpdateOfferLetter = OfferLetter(
    applicantId: applicantId,
    template: 'standard_offer',
    annualSalary: '4000000.00',
    startDate: '2026-06-01',
    letterContent: 'Updated offer letter content...',
  );

  final sampleUpdatePayload = sampleUpdateOfferLetter.toUpdateJson();

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: baseUrl));
    dioAdapter = DioAdapter(dio: dio);
    service = OfferLetterService(dioOverride: dio);
  });

  group('getOfferLetters', () {
    test('should return list of OfferLetter on success (items wrapper)',
        () async {
      dioAdapter.onGet(
        '/applicants/$applicantId/offer-letters/',
        (server) => server.reply(200, {
          'items': [sampleOfferLetterJson, sampleOfferLetterJson],
          'count': 2,
        }),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      final result = await service.getOfferLetters(token, applicantId);

      expect(result.items, isA<List<OfferLetter>>());
      expect(result.items.length, 2);
      expect(result.count, 2);
      expect(result.items.first.id, 1);
      expect(result.items.first.applicantId, applicantId);
      expect(result.items.first.template, 'standard_offer');
      expect(result.items.first.annualSalary, '3500000.00');
      expect(result.items.first.startDate, '2026-05-01');
      expect(result.items.first.status, 'draft');
    });

    test('should return list of OfferLetter on success (plain list)', () async {
      dioAdapter.onGet(
        '/applicants/$applicantId/offer-letters/',
        (server) => server.reply(200, [sampleOfferLetterJson]),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      final result = await service.getOfferLetters(token, applicantId);

      expect(result.items.length, 1);
      expect(result.count, 1);
    });

    test('should handle empty list', () async {
      dioAdapter.onGet(
        '/applicants/$applicantId/offer-letters/',
        (server) => server.reply(200, {'items': [], 'count': 0}),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      final result = await service.getOfferLetters(token, applicantId);

      expect(result.items, isEmpty);
      expect(result.count, 0);
    });

    test('should pass pagination parameters', () async {
      dioAdapter.onGet(
        '/applicants/$applicantId/offer-letters/',
        (server) => server.reply(200, [sampleOfferLetterJson]),
        queryParameters: {'limit': 50, 'offset': 10},
      );

      final result = await service.getOfferLetters(
        token,
        applicantId,
        limit: 50,
        offset: 10,
      );

      expect(result.items.length, 1);
    });

    test('should throw on 500 error', () async {
      dioAdapter.onGet(
        '/applicants/$applicantId/offer-letters/',
        (server) => server.reply(500, {'message': 'Internal server error'}),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      expect(
        () => service.getOfferLetters(token, applicantId),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 400 error', () async {
      dioAdapter.onGet(
        '/applicants/$applicantId/offer-letters/',
        (server) => server.reply(400, {'message': 'Invalid applicant'}),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      expect(
        () => service.getOfferLetters(token, applicantId),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('createOfferLetter', () {
    test('should return OfferLetter on success', () async {
      dioAdapter.onPost(
        '/applicants/$applicantId/offer-letters/',
        (server) => server.reply(201, sampleOfferLetterJson),
        data: sampleCreatePayload,
      );

      final result = await service.createOfferLetter(
          token, applicantId, sampleCreateOfferLetter);

      expect(result, isA<OfferLetter>());
      expect(result.id, 1);
      expect(result.template, 'standard_offer');
      expect(result.annualSalary, '3500000.00');
      expect(result.startDate, '2026-05-01');
    });

    test('should throw on 400 error', () async {
      dioAdapter.onPost(
        '/applicants/$applicantId/offer-letters/',
        (server) => server.reply(400, {'message': 'Invalid data'}),
        data: sampleCreatePayload,
      );

      expect(
        () => service.createOfferLetter(
            token, applicantId, sampleCreateOfferLetter),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 500 error', () async {
      dioAdapter.onPost(
        '/applicants/$applicantId/offer-letters/',
        (server) => server.reply(500, {'message': 'Server error'}),
        data: sampleCreatePayload,
      );

      expect(
        () => service.createOfferLetter(
            token, applicantId, sampleCreateOfferLetter),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getOfferLetterById', () {
    test('should return OfferLetter on success', () async {
      dioAdapter.onGet(
        '/applicants/$applicantId/offer-letters/1',
        (server) => server.reply(200, sampleOfferLetterJson),
      );

      final result = await service.getOfferLetterById(token, applicantId, 1);

      expect(result, isA<OfferLetter>());
      expect(result.id, 1);
      expect(result.applicantId, applicantId);
      expect(result.template, 'standard_offer');
      expect(result.status, 'draft');
    });

    test('should throw on 404 error', () async {
      dioAdapter.onGet(
        '/applicants/$applicantId/offer-letters/999',
        (server) => server.reply(404, {'message': 'Offer letter not found'}),
      );

      expect(
        () => service.getOfferLetterById(token, applicantId, 999),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 500 error', () async {
      dioAdapter.onGet(
        '/applicants/$applicantId/offer-letters/1',
        (server) => server.reply(500, {'message': 'Server error'}),
      );

      expect(
        () => service.getOfferLetterById(token, applicantId, 1),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('updateOfferLetter', () {
    test('should return updated OfferLetter on success', () async {
      final updatedJson = {
        ...sampleOfferLetterJson,
        'annual_salary': '4000000.00',
        'start_date': '2026-06-01',
        'letter_content': 'Updated offer letter content...',
      };

      dioAdapter.onPatch(
        '/applicants/$applicantId/offer-letters/1',
        (server) => server.reply(200, updatedJson),
        data: sampleUpdatePayload,
      );

      final result = await service.updateOfferLetter(
          token, applicantId, 1, sampleUpdateOfferLetter);

      expect(result, isA<OfferLetter>());
      expect(result.annualSalary, '4000000.00');
      expect(result.startDate, '2026-06-01');
    });

    test('should throw on 400 error', () async {
      dioAdapter.onPatch(
        '/applicants/$applicantId/offer-letters/1',
        (server) => server.reply(400, {'message': 'Invalid data'}),
        data: sampleUpdatePayload,
      );

      expect(
        () => service.updateOfferLetter(
            token, applicantId, 1, sampleUpdateOfferLetter),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 500 error', () async {
      dioAdapter.onPatch(
        '/applicants/$applicantId/offer-letters/1',
        (server) => server.reply(500, {'message': 'Server error'}),
        data: sampleUpdatePayload,
      );

      expect(
        () => service.updateOfferLetter(
            token, applicantId, 1, sampleUpdateOfferLetter),
        throwsA(isA<Exception>()),
      );
    });
  });
}
