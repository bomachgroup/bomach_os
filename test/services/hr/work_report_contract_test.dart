import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:bomach_os/src/services/hr/work_report_service.dart';

void main() {
  test('work report listing never sends unsupported mood filter', () async {
    final dio = Dio(BaseOptions(baseUrl: '${ApiConstants.baseUrl}/api/v1'));
    RequestOptions? capturedRequest;
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        capturedRequest = options;
        handler.next(options);
      },
    ));
    final adapter = DioAdapter(dio: dio);
    adapter.onGet(
      '/work-reports/',
      (server) => server.reply(200, []),
      queryParameters: {
        'limit': 100,
        'offset': 0,
        'status': 'pending',
      },
    );

    final reports = await WorkReportService(dioOverride: dio).getWorkReports(
      'token',
      status: 'pending',
      mood: 'Happy',
    );

    expect(reports, isEmpty);
    expect(capturedRequest!.queryParameters.containsKey('mood'), isFalse);
  });
}
