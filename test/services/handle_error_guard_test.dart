import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:bomach_os/src/services/employees_services.dart';
import 'package:bomach_os/src/services/service_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

/// Spec (B8 fix, Batch 9a) — the error-masking bug:
///
/// `_handleError` must not crash on non-Map response bodies. When the
/// backend sits behind a proxy, failures arrive as HTML/plain-text or
/// JSON-array bodies; indexing `['message']` on those threw
/// NoSuchMethodError INSIDE the handler, masking the real HTTP status.
///
/// Contract for BOTH EmployeeService and ServiceService:
/// a DioException whose body is a String/List must rethrow an Exception
/// whose message still contains the status code and never mentions
/// NoSuchMethodError.
void main() {
  for (final (label, build) in [
    ('EmployeeService', (Dio dio) => EmployeeService(dioOverride: dio)),
    ('ServiceService', (Dio dio) => ServiceService(dioOverride: dio)),
  ]) {
    group('$label._handleError with non-Map bodies', () {
      late Dio dio;
      late DioAdapter dioAdapter;
      late dynamic service;

      setUp(() {
        dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
        dioAdapter = DioAdapter(dio: dio);
        service = build(dio);
      });

      Future<Object?> trigger() async {
        try {
          if (service is EmployeeService) {
            await (service as EmployeeService).getEmployees('tok');
          } else {
            await (service as ServiceService).getOrders('tok');
          }
          return null; // should have thrown
        } catch (e) {
          return e;
        }
      }

      test('plain-text 502 body → clean exception with status code',
          () async {
        if (service is EmployeeService) {
          dioAdapter.onGet(
            '/api/v1/employees/employees',
            (server) => server.reply(502, '<html>Bad Gateway</html>'),
          );
        } else {
          dioAdapter.onGet(
            '/orders',
            (server) => server.reply(502, '<html>Bad Gateway</html>'),
          );
        }

        final error = await trigger();
        expect(error, isNotNull);
        final message = error.toString();
        expect(message.contains('NoSuchMethodError'), isFalse,
            reason: 'handler crashed instead of translating: $message');
        expect(message.contains('502'), isTrue);
      });

      test('JSON-array error body → clean exception with status code',
          () async {
        if (service is EmployeeService) {
          dioAdapter.onGet(
            '/api/v1/employees/employees',
            (server) => server.reply(500, ['boom']),
          );
        } else {
          dioAdapter.onGet(
            '/orders',
            (server) => server.reply(500, ['boom']),
          );
        }

        final error = await trigger();
        expect(error, isNotNull);
        final message = error.toString();
        expect(message.contains('NoSuchMethodError'), isFalse,
            reason: 'handler crashed instead of translating: $message');
        expect(message.contains('500'), isTrue);
      });
    });
  }
}
