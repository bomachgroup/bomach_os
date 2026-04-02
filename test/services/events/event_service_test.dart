import 'package:bms_front_end/src/services/events/event_service.dart';
import 'package:bms_front_end/src/constants/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late EventService service;
  const token = 'test-token';

  setUp(() {
    dio = Dio(BaseOptions(
      baseUrl: '${ApiConstants.baseUrl}/api/v1',
    ));
    dioAdapter = DioAdapter(dio: dio);
    service = EventService(dioOverride: dio);
  });

  final sampleEvent = {
    'id': 1,
    'event_id': 'EVT-001',
    'title': 'Quarterly Review',
    'event_type': 'GENERAL_MEETING',
    'event_time_from': '2026-04-01T09:00:00Z',
    'event_time_to': '2026-04-01T11:00:00Z',
    'meeting_location': 'Conference Room A',
    'target_audience': ['Engineering', 'Product'],
    'status': 'scheduled',
    'reminder_offset': 15,
    'is_recurring': false,
    'recurrence': null,
    'organizer_name': 'Jane Doe',
    'created_at': '2026-03-01T00:00:00Z',
    'updated_at': '2026-03-01T00:00:00Z',
  };

  group('getEvents', () {
    test('returns events from paginated response', () async {
      dioAdapter.onGet(
        '/events/',
        (server) => server.reply(200, {
          'items': [sampleEvent],
          'count': 1,
        }),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      final result = await service.getEvents(token);
      expect(result.items.length, 1);
      expect(result.items.first.title, 'Quarterly Review');
      expect(result.items.first.eventId, 'EVT-001');
      expect(result.total, 1);
    });

    test('returns empty list when no events', () async {
      dioAdapter.onGet(
        '/events/',
        (server) => server.reply(200, {'items': [], 'count': 0}),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      final result = await service.getEvents(token);
      expect(result.items, isEmpty);
      expect(result.total, 0);
    });

    test('passes search and pagination parameters', () async {
      dioAdapter.onGet(
        '/events/',
        (server) => server.reply(200, {'items': [], 'count': 0}),
        queryParameters: {
          'search': 'Review',
          'limit': 10,
          'offset': 5,
        },
      );

      final result = await service.getEvents(
        token,
        search: 'Review',
        limit: 10,
        offset: 5,
      );
      expect(result.items, isEmpty);
    });

    test('throws on error', () async {
      dioAdapter.onGet(
        '/events/',
        (server) => server.reply(500, {'detail': 'Server error'}),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      expect(
        () => service.getEvents(token),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('createEvent', () {
    test('creates event successfully', () async {
      dioAdapter.onPost(
        '/events/',
        (server) => server.reply(201, sampleEvent),
        data: Matchers.any,
      );

      final result = await service.createEvent(token, {
        'title': 'Quarterly Review',
        'event_type': 'GENERAL_MEETING',
        'event_time_from': '2026-04-01T09:00:00Z',
        'event_time_to': '2026-04-01T11:00:00Z',
      });
      expect(result.title, 'Quarterly Review');
      expect(result.eventType, 'GENERAL_MEETING');
    });

    test('throws on 400 error', () async {
      dioAdapter.onPost(
        '/events/',
        (server) => server.reply(400, {'detail': 'Bad request'}),
        data: Matchers.any,
      );

      expect(
        () => service.createEvent(token, {}),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getEventById', () {
    test('returns event by ID', () async {
      dioAdapter.onGet(
        '/events/1/',
        (server) => server.reply(200, sampleEvent),
      );

      final result = await service.getEventById(token, 1);
      expect(result.id, 1);
      expect(result.organizerName, 'Jane Doe');
    });

    test('throws on 404', () async {
      dioAdapter.onGet(
        '/events/999/',
        (server) => server.reply(404, {'detail': 'Not found'}),
      );

      expect(
        () => service.getEventById(token, 999),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('deleteEvent', () {
    test('deletes event successfully', () async {
      dioAdapter.onDelete(
        '/events/1/',
        (server) => server.reply(200, {'detail': 'Deleted'}),
      );

      await expectLater(
        service.deleteEvent(token, 1),
        completes,
      );
    });

    test('throws on 404 error', () async {
      dioAdapter.onDelete(
        '/events/999/',
        (server) => server.reply(404, {'detail': 'Not found'}),
      );

      expect(
        () => service.deleteEvent(token, 999),
        throwsA(isA<Exception>()),
      );
    });
  });
}
