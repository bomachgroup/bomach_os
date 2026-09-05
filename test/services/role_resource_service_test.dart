import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:bomach_os/src/services/role_resource_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late RoleResourceService service;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
    adapter = DioAdapter(dio: dio);
    service = RoleResourceService(dioOverride: dio);
  });

  test('updates a role resource with the contract PATCH method', () async {
    const payload = {
      'name': 'Laptop',
      'description': 'Assigned work laptop',
      'quantity': 2,
    };

    adapter.onPatch(
      '/api/v1/roles/12/resources/4',
      (server) => server.reply(200, {
        'id': 4,
        'role_id': 12,
        'name': 'Laptop',
        'description': 'Assigned work laptop',
        'quantity': 2,
        'is_assigned': true,
      }),
      data: payload,
    );

    final result =
        await service.updatePhysicalResource('token', 12, 4, payload);

    expect(result.id, 4);
    expect(result.name, 'Laptop');
    expect(result.isAssigned, isTrue);
  });
}
