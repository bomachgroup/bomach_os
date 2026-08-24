import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:bomach_os/src/services/finance/service_invoice_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

/// Spec (B1 fix, Batch 8) — the hardwired "Outstanding Invoices" KPI:
///
/// `FinanceDashboardController.fetchStats()` must fetch UNPAID invoices
/// via `ServiceInvoiceService.getInvoices(token, status: 'unpaid')` and
/// assign the server count to `outstandingInvoices`. On failure the card
/// keeps its previous value rather than faking 0.
///
/// This suite pins the service contract the wiring relies on (request
/// shape + total parsing). The controller-level assignment is covered by
/// manual E2E per the plan.
void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late ServiceInvoiceService service;

  const token = 'tok';

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: '${ApiConstants.baseUrl}/api/v1'));
    dioAdapter = DioAdapter(dio: dio);
    service = ServiceInvoiceService(dioOverride: dio);
  });

  group('outstanding invoices source query', () {
    test("getInvoices(status: 'unpaid') sends the status filter and "
        'returns the server total', () async {
      dioAdapter.onGet(
        '/invoices/',
        (server) => server.reply(200, {
          'items': [
            {'id': 1, 'status': 'unpaid'},
            {'id': 2, 'status': 'unpaid'},
            {'id': 3, 'status': 'unpaid'},
          ],
          'count': 3,
        }),
        queryParameters: {'status': 'unpaid', 'limit': 100, 'offset': 0},
      );

      final result = await service.getInvoices(token, status: 'unpaid');

      expect(result.total, 3);
      expect(result.items.length, 3);
      expect(result.items.every((i) => i.status == 'unpaid'), isTrue);
    });

    test('zero unpaid invoices → total 0 (card shows a real zero)', () async {
      dioAdapter.onGet(
        '/invoices/',
        (server) => server.reply(200, {'items': [], 'count': 0}),
        queryParameters: {'status': 'unpaid', 'limit': 100, 'offset': 0},
      );

      final result = await service.getInvoices(token, status: 'unpaid');
      expect(result.total, 0);
    });

    test('server failure propagates so the controller can keep stale value',
        () async {
      dioAdapter.onGet(
        '/invoices/',
        (server) => server.reply(500, {'message': 'boom'}),
        queryParameters: {'status': 'unpaid', 'limit': 100, 'offset': 0},
      );

      await expectLater(
        service.getInvoices(token, status: 'unpaid'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
