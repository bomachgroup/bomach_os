import 'package:bms_front_end/pages/finance/models/service_invoice_model_api.dart';
import 'package:bms_front_end/src/constants/api_constants.dart';
import 'package:bms_front_end/src/services/finance/service_invoice_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late ServiceInvoiceService service;

  const token = 'test-token-123';
  const baseUrl = '${ApiConstants.baseUrl}/api/v1';

  final sampleInvoiceItemJson = {
    'id': 1,
    'description': 'Land survey consultation',
    'quantity': 2,
    'unit_price': '50000.00',
    'total': '100000.00',
    'created_at': '2026-03-15T10:00:00Z',
    'updated_at': '2026-03-15T10:00:00Z',
  };

  final sampleInvoiceJson = {
    'id': 1,
    'invoice_number': 'INV-2026-001',
    'client_id': 5,
    'service': {'id': 2, 'name': 'Land Survey'},
    'order': {'id': 10, 'order_number': 'ORD-2026-010'},
    'lead': {'id': 3, 'name': 'John Doe'},
    'issue_date': '2026-03-01',
    'due_date': '2026-03-31',
    'subtotal': '100000.00',
    'tax_rate': '7.5',
    'tax_amount': '7500.00',
    'total_amount': '107500.00',
    'amount_paid': '50000.00',
    'balance': '57500.00',
    'payment_progress': 46.51,
    'status': 'partially_paid',
    'notes': 'Payment due end of month',
    'items': [sampleInvoiceItemJson],
    'created_at': '2026-03-01T10:00:00Z',
    'updated_at': '2026-03-15T10:00:00Z',
    'created_by_id': 7,
  };

  final sampleCreatePayload = {
    'client_id': 5,
    'service_id': 2,
    'order_id': 10,
    'lead_id': 3,
    'issue_date': '2026-03-01',
    'due_date': '2026-03-31',
    'subtotal': '100000.00',
    'tax_rate': '7.5',
    'status': 'partially_paid',
    'notes': 'Payment due end of month',
    'created_by_id': 7,
    'items': [
      {
        'description': 'Land survey consultation',
        'quantity': 2,
        'unit_price': '50000.00',
      }
    ],
  };

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: baseUrl));
    dioAdapter = DioAdapter(dio: dio);
    service = ServiceInvoiceService(dioOverride: dio);
  });

  group('getInvoices', () {
    test('should return list of ServiceInvoice on success (items wrapper)',
        () async {
      dioAdapter.onGet(
        '/invoices/',
        (server) => server.reply(200, {
          'items': [sampleInvoiceJson, sampleInvoiceJson],
          'count': 2,
        }),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      final result = await service.getInvoices(token);

      expect(result.items, isA<List<ServiceInvoice>>());
      expect(result.items.length, 2);
      expect(result.total, 2);

      final invoice = result.items.first;
      expect(invoice.id, 1);
      expect(invoice.invoiceNumber, 'INV-2026-001');
      expect(invoice.clientId, 5);
      expect(invoice.service.id, 2);
      expect(invoice.service.name, 'Land Survey');
      expect(invoice.order?.id, 10);
      expect(invoice.order?.orderNumber, 'ORD-2026-010');
      expect(invoice.lead?.id, 3);
      expect(invoice.lead?.name, 'John Doe');
      expect(invoice.issueDate, '2026-03-01');
      expect(invoice.dueDate, '2026-03-31');
      expect(invoice.subtotal, '100000.00');
      expect(invoice.taxRate, '7.5');
      expect(invoice.taxAmount, '7500.00');
      expect(invoice.totalAmount, '107500.00');
      expect(invoice.amountPaid, '50000.00');
      expect(invoice.balance, '57500.00');
      expect(invoice.paymentProgress, 46.51);
      expect(invoice.status, 'partially_paid');
      expect(invoice.notes, 'Payment due end of month');
      expect(invoice.items.length, 1);
      expect(invoice.items.first.description, 'Land survey consultation');
      expect(invoice.items.first.quantity, 2);
      expect(invoice.items.first.unitPrice, '50000.00');
      expect(invoice.items.first.total, '100000.00');
      expect(invoice.createdById, 7);
    });

    test('should return list of ServiceInvoice on success (plain list)',
        () async {
      dioAdapter.onGet(
        '/invoices/',
        (server) => server.reply(200, [sampleInvoiceJson]),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      final result = await service.getInvoices(token);

      expect(result.items.length, 1);
      expect(result.total, 1);
    });

    test('should handle empty list', () async {
      dioAdapter.onGet(
        '/invoices/',
        (server) => server.reply(200, {'items': [], 'count': 0}),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      final result = await service.getInvoices(token);

      expect(result.items, isEmpty);
      expect(result.total, 0);
    });

    test('should handle invoice with null order and lead', () async {
      final invoiceNoOptionals = {
        ...sampleInvoiceJson,
        'order': null,
        'lead': null,
      };

      dioAdapter.onGet(
        '/invoices/',
        (server) => server.reply(200, {
          'items': [invoiceNoOptionals],
          'count': 1,
        }),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      final result = await service.getInvoices(token);

      expect(result.items.first.order, isNull);
      expect(result.items.first.lead, isNull);
    });

    test('should throw on 500 error', () async {
      dioAdapter.onGet(
        '/invoices/',
        (server) => server.reply(500, {'message': 'Internal server error'}),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      expect(
        () => service.getInvoices(token),
        throwsA(isA<Exception>()),
      );
    });

    test('should pass query parameters', () async {
      dioAdapter.onGet(
        '/invoices/',
        (server) => server.reply(200, [sampleInvoiceJson]),
        queryParameters: {
          'search': 'INV-2026',
          'status': 'partially_paid',
          'client_id': 5,
          'limit': 50,
          'offset': 10,
        },
      );

      final result = await service.getInvoices(
        token,
        search: 'INV-2026',
        status: 'partially_paid',
        clientId: 5,
        limit: 50,
        offset: 10,
      );

      expect(result.items.length, 1);
    });
  });

  group('createInvoice', () {
    test('should return ServiceInvoice on success', () async {
      dioAdapter.onPost(
        '/invoices/',
        (server) => server.reply(201, sampleInvoiceJson),
        data: sampleCreatePayload,
      );

      final result = await service.createInvoice(token, sampleCreatePayload);

      expect(result, isA<ServiceInvoice>());
      expect(result.id, 1);
      expect(result.invoiceNumber, 'INV-2026-001');
      expect(result.items.length, 1);
    });

    test('should throw on 400 error', () async {
      dioAdapter.onPost(
        '/invoices/',
        (server) => server.reply(400, {'message': 'Invalid data'}),
        data: sampleCreatePayload,
      );

      expect(
        () => service.createInvoice(token, sampleCreatePayload),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 500 error', () async {
      dioAdapter.onPost(
        '/invoices/',
        (server) => server.reply(500, {'message': 'Server error'}),
        data: sampleCreatePayload,
      );

      expect(
        () => service.createInvoice(token, sampleCreatePayload),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getInvoiceById', () {
    test('should return ServiceInvoice on success', () async {
      dioAdapter.onGet(
        '/invoices/1',
        (server) => server.reply(200, sampleInvoiceJson),
      );

      final result = await service.getInvoiceById(token, 1);

      expect(result, isA<ServiceInvoice>());
      expect(result.id, 1);
      expect(result.totalAmount, '107500.00');
      expect(result.items.first.description, 'Land survey consultation');
    });

    test('should throw on 404 error', () async {
      dioAdapter.onGet(
        '/invoices/999',
        (server) => server.reply(404, {'message': 'Invoice not found'}),
      );

      expect(
        () => service.getInvoiceById(token, 999),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 500 error', () async {
      dioAdapter.onGet(
        '/invoices/1',
        (server) => server.reply(500, {'message': 'Server error'}),
      );

      expect(
        () => service.getInvoiceById(token, 1),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('updateInvoice', () {
    test('should return updated ServiceInvoice on success', () async {
      final updatedJson = {
        ...sampleInvoiceJson,
        'status': 'paid',
        'amount_paid': '107500.00',
        'balance': '0.00',
        'payment_progress': 100.0,
      };

      dioAdapter.onPut(
        '/invoices/1',
        (server) => server.reply(200, updatedJson),
        data: sampleCreatePayload,
      );

      final result = await service.updateInvoice(token, 1, sampleCreatePayload);

      expect(result, isA<ServiceInvoice>());
      expect(result.status, 'paid');
      expect(result.amountPaid, '107500.00');
      expect(result.balance, '0.00');
      expect(result.paymentProgress, 100.0);
    });

    test('should throw on 400 error', () async {
      dioAdapter.onPut(
        '/invoices/1',
        (server) => server.reply(400, {'message': 'Invalid data'}),
        data: sampleCreatePayload,
      );

      expect(
        () => service.updateInvoice(token, 1, sampleCreatePayload),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 500 error', () async {
      dioAdapter.onPut(
        '/invoices/1',
        (server) => server.reply(500, {'message': 'Server error'}),
        data: sampleCreatePayload,
      );

      expect(
        () => service.updateInvoice(token, 1, sampleCreatePayload),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('deleteInvoice', () {
    test('should complete without error on success', () async {
      dioAdapter.onDelete(
        '/invoices/1',
        (server) => server.reply(204, null),
      );

      await expectLater(
        service.deleteInvoice(token, 1),
        completes,
      );
    });

    test('should throw on 404 error', () async {
      dioAdapter.onDelete(
        '/invoices/999',
        (server) => server.reply(404, {'message': 'Invoice not found'}),
      );

      expect(
        () => service.deleteInvoice(token, 999),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 500 error', () async {
      dioAdapter.onDelete(
        '/invoices/1',
        (server) => server.reply(500, {'message': 'Server error'}),
      );

      expect(
        () => service.deleteInvoice(token, 1),
        throwsA(isA<Exception>()),
      );
    });
  });
}
