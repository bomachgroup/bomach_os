import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:bomach_os/src/services/role_knowledge_base_service.dart';
import 'package:bomach_os/src/services/role_okr_service.dart';
import 'package:bomach_os/src/services/role_report_service.dart';

void main() {
  DioAdapter adapterFor(Dio dio, String path) {
    final adapter = DioAdapter(dio: dio);
    adapter.onGet(path, (server) => server.reply(404, {'detail': 'Not Found'}));
    return adapter;
  }

  test('knowledge base 404 is surfaced as unsupported capability', () async {
    final dio = Dio();
    adapterFor(dio, '/api/v1/knowledge-base/');
    final service = RoleKnowledgeBaseService(dioOverride: dio);

    expect(() => service.getEntries('token'), throwsA(isA<Exception>()));
  });

  test('role reports 404 is surfaced as unsupported capability', () async {
    final dio = Dio();
    adapterFor(dio, '/api/v1/role-reports/');
    final service = RoleReportService(dioOverride: dio);

    expect(() => service.listReports('token'), throwsA(isA<Exception>()));
  });

  test('role OKRs 404 is surfaced as unsupported capability', () async {
    final dio = Dio();
    adapterFor(dio, '/api/v1/role-okrs/');
    final service = RoleOkrService(dioOverride: dio);

    expect(() => service.listRoleOkrs('token'), throwsA(isA<Exception>()));
  });
}
