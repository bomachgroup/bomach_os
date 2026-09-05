import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:bomach_os/src/services/role_service.dart';
import 'package:bomach_os/pages/company/controllers/role_reporting_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late RoleReportingController controller;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
    adapter = DioAdapter(dio: dio);
    controller = RoleReportingController(
      service: RoleService(dioOverride: dio),
      tokenReader: () async => 'token',
    );
  });

  test('loads reporting data from the dedicated role endpoint', () async {
    adapter.onGet(
      '/api/v1/roles/12/reporting-tree',
      (server) => server.reply(200, {
        'role_id': 12,
        'reports_to': {'id': 3, 'name': 'Chief Operating Officer'},
        'direct_reports': [
          {'id': 21, 'name': 'Site Manager'},
        ],
      }),
    );

    await controller.fetch(12);

    expect(controller.isLoading.value, isFalse);
    expect(controller.errorMessage.value, isEmpty);
    expect(controller.tree.value?.reportsTo?.id, 3);
    expect(controller.tree.value?.directReports.single.name, 'Site Manager');
  });

  test('keeps API failures visible to the role page', () async {
    adapter.onGet(
      '/api/v1/roles/12/reporting-tree',
      (server) => server.reply(403, {'detail': 'Forbidden'}),
    );

    await controller.fetch(12);

    expect(controller.tree.value, isNull);
    expect(controller.errorMessage.value, contains('403'));
  });
}
