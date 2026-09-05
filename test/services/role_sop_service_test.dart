import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:bomach_os/src/services/role_sop_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late RoleSopService service;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
    adapter = DioAdapter(dio: dio);
    service = RoleSopService(dioOverride: dio);
  });

  test('does not turn SOP selection API failures into an empty success', () {
    adapter.onGet(
      '/api/v1/sop/departments/7/sops',
      (server) => server.reply(403, {'detail': 'Not permitted'}),
    );

    expect(
      () => service.fetchAvailableSops('token', deptId: 7),
      throwsA(isA<Exception>().having(
        (error) => error.toString(),
        'message',
        allOf(contains('403'), contains('Not permitted')),
      )),
    );
  });
}
