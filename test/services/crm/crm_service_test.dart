import 'package:bms_front_end/src/services/crm/crm_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late CrmService service;
  const token = 'test-token';

  setUp(() {
    dio = Dio(BaseOptions(
        baseUrl: 'https://bomachauth.bgbot.app/api/v1'));
    dioAdapter = DioAdapter(dio: dio);
    service = CrmService(dioOverride: dio);
  });

  final sampleClient = {
    'id': 1,
    'user_id': 10,
    'first_name': 'John',
    'last_name': 'Doe',
    'email': 'john@example.com',
    'phone_number': '+2349012345678',
    'balance': 50000.0,
    'created_at': '2026-01-01T00:00:00Z',
    'updated_at': '2026-01-01T00:00:00Z',
  };

  final sampleLead = {
    'id': 1,
    'email': 'lead@example.com',
    'first_name': 'Jane',
    'last_name': 'Lead',
    'gender': 'female',
    'marital_status': 'single',
    'address': '123 Street',
    'phone_number': '+2349087654321',
    'source': 'website',
    'status': 'new',
    'company_name': 'Test Corp',
    'interested_services': 'Land Survey',
    'assigned_to_name': null,
    'notes': 'Interested in surveying',
    'created_at': '2026-01-01T00:00:00Z',
    'updated_at': '2026-01-01T00:00:00Z',
  };

  group('getClients', () {
    test('returns clients from paginated response', () async {
      dioAdapter.onGet(
        '/clients/clients/',
        (server) => server.reply(200, {
          'items': [sampleClient],
          'count': 1,
        }),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      final result = await service.getClients(token);
      expect(result.items.length, 1);
      expect(result.items.first.fullName, 'John Doe');
      expect(result.total, 1);
    });

    test('returns empty when no clients', () async {
      dioAdapter.onGet(
        '/clients/clients/',
        (server) => server.reply(200, {'items': [], 'count': 0}),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      final result = await service.getClients(token);
      expect(result.items, isEmpty);
    });

    test('throws on error', () async {
      dioAdapter.onGet(
        '/clients/clients/',
        (server) => server.reply(403, {'detail': 'Forbidden'}),
        queryParameters: {'limit': 100, 'offset': 0},
      );
      expect(() => service.getClients(token), throwsA(isA<Exception>()));
    });
  });

  group('createClient', () {
    test('creates client successfully', () async {
      dioAdapter.onPost(
        '/clients/clients/',
        (server) => server.reply(201, sampleClient),
        data: Matchers.any,
      );

      final result = await service.createClient(token, sampleClient);
      expect(result.fullName, 'John Doe');
    });

    test('throws on 400', () async {
      dioAdapter.onPost(
        '/clients/clients/',
        (server) => server.reply(400, {'detail': 'Bad request'}),
        data: Matchers.any,
      );
      expect(() => service.createClient(token, {}), throwsA(isA<Exception>()));
    });
  });

  group('getLeads', () {
    test('returns leads from paginated response', () async {
      dioAdapter.onGet(
        '/clients/leads/',
        (server) => server.reply(200, {
          'items': [sampleLead],
          'count': 1,
        }),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      final result = await service.getLeads(token);
      expect(result.items.length, 1);
      expect(result.items.first.fullName, 'Jane Lead');
      expect(result.items.first.source, 'website');
    });

    test('passes filters correctly', () async {
      dioAdapter.onGet(
        '/clients/leads/',
        (server) => server.reply(200, {'items': [], 'count': 0}),
        queryParameters: {
          'search': 'Jane',
          'status': 'new',
          'limit': 10,
          'offset': 0,
        },
      );

      final result = await service.getLeads(token,
          search: 'Jane', status: 'new', limit: 10);
      expect(result.items, isEmpty);
    });
  });

  group('createLead', () {
    test('creates lead successfully', () async {
      dioAdapter.onPost(
        '/clients/leads/',
        (server) => server.reply(201, sampleLead),
        data: Matchers.any,
      );

      final result = await service.createLead(token, sampleLead);
      expect(result.fullName, 'Jane Lead');
      expect(result.interestedServices, 'Land Survey');
    });
  });

  group('deleteLead', () {
    test('deletes lead successfully', () async {
      dioAdapter.onDelete(
        '/clients/leads/1/',
        (server) => server.reply(200, {'detail': 'Deleted'}),
      );

      await expectLater(service.deleteLead(token, 1), completes);
    });
  });

  group('convertLeadToClient', () {
    test('converts lead successfully', () async {
      dioAdapter.onPost(
        '/clients/leads/1/convert-to-client/',
        (server) => server.reply(201, sampleLead),
        data: Matchers.any,
      );

      final result = await service.convertLeadToClient(token, 1);
      expect(result.fullName, 'Jane Lead');
    });
  });
}
