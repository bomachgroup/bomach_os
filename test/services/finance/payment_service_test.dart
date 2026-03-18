import 'package:bms_front_end/pages/finance/models/payment_model.dart';
import 'package:bms_front_end/src/services/finance/payment_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late PaymentService service;

  const token = 'test-token-123';
  const baseUrl = 'https://bomachauth.bgbot.app/api/v1';

  final samplePaymentJson = {
    'id': 1,
    'payment_reference': 'PAY-2026-001',
    'invoice_id': 10,
    'amount': '250000.00',
    'payment_method': 'bank_transfer',
    'payment_date': '2026-03-15',
    'transaction_reference': 'TXN-ABC-123',
    'notes': 'First installment payment',
    'created_at': '2026-03-15T10:00:00Z',
    'updated_at': '2026-03-15T10:00:00Z',
    'created_by_id': 5,
  };

  final sampleCreatePayload = {
    'invoice_id': 10,
    'amount': '250000.00',
    'payment_method': 'bank_transfer',
    'payment_date': '2026-03-15',
    'transaction_reference': 'TXN-ABC-123',
    'notes': 'First installment payment',
    'created_by_id': 5,
  };

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: baseUrl));
    dioAdapter = DioAdapter(dio: dio);
    service = PaymentService(dioOverride: dio);
  });

  group('getPayments', () {
    test('should return list of Payment on success (items wrapper)', () async {
      dioAdapter.onGet(
        '/payments/',
        (server) => server.reply(200, {
          'items': [samplePaymentJson, samplePaymentJson],
          'count': 2,
        }),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      final result = await service.getPayments(token);

      expect(result.items, isA<List<Payment>>());
      expect(result.items.length, 2);
      expect(result.total, 2);
      expect(result.items.first.id, 1);
      expect(result.items.first.paymentReference, 'PAY-2026-001');
      expect(result.items.first.invoiceId, 10);
      expect(result.items.first.amount, '250000.00');
      expect(result.items.first.paymentMethod, 'bank_transfer');
      expect(result.items.first.paymentDate, '2026-03-15');
      expect(result.items.first.transactionReference, 'TXN-ABC-123');
      expect(result.items.first.notes, 'First installment payment');
      expect(result.items.first.createdById, 5);
    });

    test('should return list of Payment on success (plain list)', () async {
      dioAdapter.onGet(
        '/payments/',
        (server) => server.reply(200, [samplePaymentJson]),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      final result = await service.getPayments(token);

      expect(result.items.length, 1);
      expect(result.total, 1);
    });

    test('should handle empty list', () async {
      dioAdapter.onGet(
        '/payments/',
        (server) => server.reply(200, {'items': [], 'count': 0}),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      final result = await service.getPayments(token);

      expect(result.items, isEmpty);
      expect(result.total, 0);
    });

    test('should throw on 500 error', () async {
      dioAdapter.onGet(
        '/payments/',
        (server) => server.reply(500, {'message': 'Internal server error'}),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      expect(
        () => service.getPayments(token),
        throwsA(isA<Exception>()),
      );
    });

    test('should pass query parameters', () async {
      dioAdapter.onGet(
        '/payments/',
        (server) => server.reply(200, [samplePaymentJson]),
        queryParameters: {
          'invoice_id': 10,
          'limit': 50,
          'offset': 10,
        },
      );

      final result = await service.getPayments(
        token,
        invoiceId: 10,
        limit: 50,
        offset: 10,
      );

      expect(result.items.length, 1);
    });
  });

  group('createPayment', () {
    test('should return Payment on success', () async {
      dioAdapter.onPost(
        '/payments/',
        (server) => server.reply(201, samplePaymentJson),
        data: sampleCreatePayload,
      );

      final result = await service.createPayment(token, sampleCreatePayload);

      expect(result, isA<Payment>());
      expect(result.id, 1);
      expect(result.paymentReference, 'PAY-2026-001');
    });

    test('should throw on 400 error', () async {
      dioAdapter.onPost(
        '/payments/',
        (server) => server.reply(400, {'message': 'Invalid data'}),
        data: sampleCreatePayload,
      );

      expect(
        () => service.createPayment(token, sampleCreatePayload),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 500 error', () async {
      dioAdapter.onPost(
        '/payments/',
        (server) => server.reply(500, {'message': 'Server error'}),
        data: sampleCreatePayload,
      );

      expect(
        () => service.createPayment(token, sampleCreatePayload),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getPaymentById', () {
    test('should return Payment on success', () async {
      dioAdapter.onGet(
        '/payments/1',
        (server) => server.reply(200, samplePaymentJson),
      );

      final result = await service.getPaymentById(token, 1);

      expect(result, isA<Payment>());
      expect(result.id, 1);
      expect(result.amount, '250000.00');
    });

    test('should throw on 404 error', () async {
      dioAdapter.onGet(
        '/payments/999',
        (server) => server.reply(404, {'message': 'Payment not found'}),
      );

      expect(
        () => service.getPaymentById(token, 999),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 500 error', () async {
      dioAdapter.onGet(
        '/payments/1',
        (server) => server.reply(500, {'message': 'Server error'}),
      );

      expect(
        () => service.getPaymentById(token, 1),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('deletePayment', () {
    test('should complete without error on success', () async {
      dioAdapter.onDelete(
        '/payments/1',
        (server) => server.reply(204, null),
      );

      await expectLater(
        service.deletePayment(token, 1),
        completes,
      );
    });

    test('should throw on 404 error', () async {
      dioAdapter.onDelete(
        '/payments/999',
        (server) => server.reply(404, {'message': 'Payment not found'}),
      );

      expect(
        () => service.deletePayment(token, 999),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 500 error', () async {
      dioAdapter.onDelete(
        '/payments/1',
        (server) => server.reply(500, {'message': 'Server error'}),
      );

      expect(
        () => service.deletePayment(token, 1),
        throwsA(isA<Exception>()),
      );
    });
  });
}
