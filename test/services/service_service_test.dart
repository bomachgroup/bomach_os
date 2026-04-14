import 'package:bms_front_end/pages/services/models/service_model.dart';
import 'package:bms_front_end/src/constants/api_constants.dart';
import 'package:bms_front_end/src/services/service_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late ServiceService service;

  const token = 'test-token-123';
  final baseUrl = '${ApiConstants.baseUrl}/api/v1';

  final sampleCategoryJson = {
    'id': 1,
    'name': 'Real Estate',
    'description': 'Property services',
    'created_at': '2026-01-01T00:00:00Z',
    'updated_at': '2026-03-01T00:00:00Z',
  };

  final sampleServiceJson = {
    'id': 10,
    'name': 'Property Valuation',
    'category': sampleCategoryJson,
    'description': 'Professional property valuation service',
    'base_price': '50000.00',
    'delivery_time': '3 days',
    'status': 'active',
    'created_at': '2026-01-15T00:00:00Z',
    'updated_at': '2026-03-01T00:00:00Z',
    'created_by': 'admin-001',
  };

  final sampleQuoteJson = {
    'id': 20,
    'quote_number': 'QT-2026-001',
    'client_id': '50',
    'service': sampleServiceJson,
    'description': 'Valuation for Plot 5, Lekki',
    'amount': '75000.00',
    'valid_until': '2026-04-15',
    'status': 'sent',
    'created_at': '2026-03-01T00:00:00Z',
    'updated_at': '2026-03-10T00:00:00Z',
    'created_by': 'sales-001',
  };

  final sampleOrderJson = {
    'id': 30,
    'order_number': 'ORD-2026-001',
    'client_id': '50',
    'service': sampleServiceJson,
    'quote': sampleQuoteJson,
    'description': 'Property valuation order',
    'amount': '75000.00',
    'order_status': 'in_progress',
    'payment_status': 'paid',
    'valid_until': '2026-04-30',
    'created_at': '2026-03-10T00:00:00Z',
    'updated_at': '2026-03-15T00:00:00Z',
    'created_by': 'sales-001',
    'assigned_to': 'eng-001',
    'payment_link': null,
  };

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: baseUrl));
    dioAdapter = DioAdapter(dio: dio);
    service = ServiceService(dioOverride: dio);
  });

  group('createCategory', () {
    test('should return ServiceCategory on success', () async {
      dioAdapter.onPost(
        '/categories',
        (server) => server.reply(201, sampleCategoryJson),
        data: {'name': 'Real Estate', 'description': 'Property services'},
      );

      final result = await service.createCategory(
        token,
        {'name': 'Real Estate', 'description': 'Property services'},
      );

      expect(result, isA<ServiceCategory>());
      expect(result.id, 1);
      expect(result.name, 'Real Estate');
    });

    test('should throw on 400 error', () async {
      dioAdapter.onPost(
        '/categories',
        (server) => server.reply(400, {'message': 'Name is required'}),
        data: {'name': '', 'description': ''},
      );

      expect(
        () => service.createCategory(token, {'name': '', 'description': ''}),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('updateCategory', () {
    test('should return updated ServiceCategory on success', () async {
      dioAdapter.onPut(
        '/categories/1',
        (server) => server.reply(200, {
          ...sampleCategoryJson,
          'name': 'Updated Name',
        }),
        data: {'name': 'Updated Name'},
      );

      final result = await service.updateCategory(
        token,
        1,
        {'name': 'Updated Name'},
      );

      expect(result, isA<ServiceCategory>());
      expect(result.name, 'Updated Name');
    });

    test('should throw on 500 error', () async {
      dioAdapter.onPut(
        '/categories/1',
        (server) => server.reply(500, {'message': 'Server error'}),
        data: {'name': 'test'},
      );

      expect(
        () => service.updateCategory(token, 1, {'name': 'test'}),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('deleteCategory', () {
    test('should complete successfully on 204', () async {
      dioAdapter.onDelete(
        '/categories/1',
        (server) => server.reply(204, null),
      );

      await expectLater(
        service.deleteCategory(token, 1),
        completes,
      );
    });

    test('should throw on 403 error', () async {
      dioAdapter.onDelete(
        '/categories/1',
        (server) => server.reply(403, {'message': 'Forbidden'}),
      );

      expect(
        () => service.deleteCategory(token, 1),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 404 error', () async {
      dioAdapter.onDelete(
        '/categories/999',
        (server) => server.reply(404, {'message': 'Not found'}),
      );

      expect(
        () => service.deleteCategory(token, 999),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getQuoteById', () {
    test('should return Quote on success', () async {
      dioAdapter.onGet(
        '/quotes/20',
        (server) => server.reply(200, sampleQuoteJson),
      );

      final result = await service.getQuoteById(token, 20);

      expect(result, isA<Quote>());
      expect(result.id, 20);
      expect(result.quoteNumber, 'QT-2026-001');
      expect(result.amount, '75000.00');
      expect(result.service.name, 'Property Valuation');
    });

    test('should throw on 404 error', () async {
      dioAdapter.onGet(
        '/quotes/999',
        (server) => server.reply(404, {'message': 'Not found'}),
      );

      expect(
        () => service.getQuoteById(token, 999),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('updateQuote', () {
    test('should return updated Quote on success', () async {
      dioAdapter.onPut(
        '/quotes/20',
        (server) => server.reply(200, {
          ...sampleQuoteJson,
          'status': 'accepted',
          'amount': '80000.00',
        }),
        data: {'status': 'accepted', 'amount': '80000.00'},
      );

      final result = await service.updateQuote(
        token,
        20,
        {'status': 'accepted', 'amount': '80000.00'},
      );

      expect(result, isA<Quote>());
      expect(result.status, 'accepted');
      expect(result.amount, '80000.00');
    });

    test('should throw on 400 error', () async {
      dioAdapter.onPut(
        '/quotes/20',
        (server) => server.reply(400, {'message': 'Invalid status'}),
        data: {'status': 'invalid'},
      );

      expect(
        () => service.updateQuote(token, 20, {'status': 'invalid'}),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('deleteQuote', () {
    test('should complete successfully on 204', () async {
      dioAdapter.onDelete(
        '/quotes/20',
        (server) => server.reply(204, null),
      );

      await expectLater(
        service.deleteQuote(token, 20),
        completes,
      );
    });

    test('should throw on 403 error', () async {
      dioAdapter.onDelete(
        '/quotes/20',
        (server) => server.reply(403, {'message': 'Forbidden'}),
      );

      expect(
        () => service.deleteQuote(token, 20),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getOrderById', () {
    test('should return Order on success', () async {
      dioAdapter.onGet(
        '/orders/30',
        (server) => server.reply(200, sampleOrderJson),
      );

      final result = await service.getOrderById(token, 30);

      expect(result, isA<Order>());
      expect(result.id, 30);
      expect(result.orderNumber, 'ORD-2026-001');
      expect(result.orderStatus, 'in_progress');
      expect(result.paymentStatus, 'paid');
      expect(result.quote, isNotNull);
      expect(result.service.name, 'Property Valuation');
    });

    test('should handle order without quote', () async {
      final orderNoQuote = Map<String, dynamic>.from(sampleOrderJson);
      orderNoQuote['quote'] = null;

      dioAdapter.onGet(
        '/orders/31',
        (server) => server.reply(200, orderNoQuote),
      );

      final result = await service.getOrderById(token, 31);

      expect(result.quote, isNull);
    });

    test('should throw on 404 error', () async {
      dioAdapter.onGet(
        '/orders/999',
        (server) => server.reply(404, {'message': 'Not found'}),
      );

      expect(
        () => service.getOrderById(token, 999),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('updateOrder', () {
    test('should return updated Order on success', () async {
      dioAdapter.onPut(
        '/orders/30',
        (server) => server.reply(200, {
          ...sampleOrderJson,
          'order_status': 'completed',
        }),
        data: {'order_status': 'completed'},
      );

      final result = await service.updateOrder(
        token,
        30,
        {'order_status': 'completed'},
      );

      expect(result, isA<Order>());
      expect(result.orderStatus, 'completed');
    });

    test('should throw on 400 error', () async {
      dioAdapter.onPut(
        '/orders/30',
        (server) => server.reply(400, {'message': 'Invalid data'}),
        data: {'order_status': ''},
      );

      expect(
        () => service.updateOrder(token, 30, {'order_status': ''}),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('deleteOrder', () {
    test('should complete successfully on 204', () async {
      dioAdapter.onDelete(
        '/orders/30',
        (server) => server.reply(204, null),
      );

      await expectLater(
        service.deleteOrder(token, 30),
        completes,
      );
    });

    test('should throw on 500 error', () async {
      dioAdapter.onDelete(
        '/orders/30',
        (server) => server.reply(500, {'message': 'Server error'}),
      );

      expect(
        () => service.deleteOrder(token, 30),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('deleteProperty', () {
    test('should complete successfully on 204', () async {
      dioAdapter.onDelete(
        '/properties/40',
        (server) => server.reply(204, null),
      );

      await expectLater(
        service.deleteProperty(token, 40),
        completes,
      );
    });

    test('should throw on 403 error', () async {
      dioAdapter.onDelete(
        '/properties/40',
        (server) => server.reply(403, {'message': 'Forbidden'}),
      );

      expect(
        () => service.deleteProperty(token, 40),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 404 error', () async {
      dioAdapter.onDelete(
        '/properties/999',
        (server) => server.reply(404, {'message': 'Not found'}),
      );

      expect(
        () => service.deleteProperty(token, 999),
        throwsA(isA<Exception>()),
      );
    });
  });
}
