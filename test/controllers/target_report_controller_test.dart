import 'package:bomach_os/pages/hr/controller/target_report_controller.dart';
import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:bomach_os/src/services/target_report_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late TargetReportController controller;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
    adapter = DioAdapter(dio: dio);
    controller = TargetReportController(
      service: TargetReportService(dioOverride: dio),
      tokenReader: () async => 'token',
    );
  });

  test('loads my reports and preserves backend errors', () async {
    adapter.onGet(
      '/api/v1/target-reports/me',
      (server) => server.reply(403, {'detail': 'Forbidden'}),
    );

    await controller.fetchMine();

    expect(controller.reports, isEmpty);
    expect(controller.errorMessage.value, contains('403'));
    expect(controller.isLoading.value, isFalse);
  });
}
