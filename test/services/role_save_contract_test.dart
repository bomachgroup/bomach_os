import 'dart:io';

import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:bomach_os/src/services/role_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late RoleService service;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
    adapter = DioAdapter(dio: dio);
    service = RoleService(dioOverride: dio);
  });

  test('role description reads from its dedicated endpoint', () async {
    adapter.onGet(
      '/api/v1/roles/12/description',
      (server) => server.reply(200, {
        'purpose': 'Lead the team',
        'job_description': 'Coordinate delivery',
        'responsibilities': 'Plan\nReview',
      }),
    );

    final result = await service.getRoleDescription('token', 12);

    expect(result['purpose'], 'Lead the team');
    expect(result['responsibilities'], 'Plan\nReview');
  });

  test('role description create and update send contract fields only', () async {
    final requests = <Map<String, dynamic>>[];
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (options.path.endsWith('/description')) {
          requests.add(Map<String, dynamic>.from(options.data as Map));
        }
        handler.next(options);
      },
    ));
    adapter.onPost(
      '/api/v1/roles/12/description',
      (server) => server.reply(200, {'purpose': 'New purpose'}),
      data: {
        'purpose': 'New purpose',
        'job_description': 'Do work',
        'responsibilities': 'Plan',
      },
    );
    adapter.onPatch(
      '/api/v1/roles/12/description',
      (server) => server.reply(200, {'purpose': 'Updated purpose'}),
      data: {
        'purpose': 'Updated purpose',
        'job_description': 'Do better work',
        'responsibilities': 'Review',
      },
    );

    await service.createRoleDescription(
      'token',
      12,
      purpose: 'New purpose',
      jobDescription: 'Do work',
      responsibilities: 'Plan',
    );
    await service.updateRoleDescription(
      'token',
      12,
      purpose: 'Updated purpose',
      jobDescription: 'Do better work',
      responsibilities: 'Review',
    );

    expect(requests, [
      {
        'purpose': 'New purpose',
        'job_description': 'Do work',
        'responsibilities': 'Plan',
      },
      {
        'purpose': 'Updated purpose',
        'job_description': 'Do better work',
        'responsibilities': 'Review',
      },
    ]);
  });

  test('saving a missing role description falls back from GET to POST', () async {
    adapter.onGet(
      '/api/v1/roles/12/description',
      (server) => server.reply(404, {'detail': 'Not found'}),
    );
    adapter.onPost(
      '/api/v1/roles/12/description',
      (server) => server.reply(200, {
        'purpose': 'Purpose',
        'job_description': 'Description',
        'responsibilities': 'Responsibility',
      }),
      data: {
        'purpose': 'Purpose',
        'job_description': 'Description',
        'responsibilities': 'Responsibility',
      },
    );

    final result = await service.saveRoleDescription(
      'token',
      12,
      purpose: 'Purpose',
      jobDescription: 'Description',
      responsibilities: 'Responsibility',
    );

    expect(result['purpose'], 'Purpose');
  });

  test('role controller does not send description or parent fields to base role API', () {
    final source = File('lib/pages/company/controllers/roles_controller.dart').readAsStringSync();
    expect(source, contains("'branch_ids'"));
    expect(source, contains("'permissions'"));
    expect(source, isNot(contains("'mission': mission")));
    expect(source, isNot(contains("'reports_to_role_id': reportsToRoleId")));
    expect(source, contains('createRoleDescription'));
    expect(source, contains('saveRoleDescription'));
  });

  test('role details can load and react to a durable role id', () {
    final controller = File('lib/pages/company/controllers/roles_controller.dart').readAsStringSync();
    final detail = File('lib/pages/company/role_detail.dart').readAsStringSync();
    expect(controller, contains('fetchRoleById'));
    expect(controller, contains('selectedRole'));
    expect(detail, contains('Obx'));
    expect(detail, contains('selectedRole'));
  });

  test('role edit dialog loads description and leaves reporting to the reporting interface', () {
    final dialog = File('lib/pages/company/widget/roles_dialogs.dart').readAsStringSync();
    expect(dialog, contains('fetchRoleDescription'));
    expect(dialog, isNot(contains('_reportsToRoleId')));
    expect(dialog, isNot(contains('Reports To')));
    expect(dialog, contains('_displayResponsibilities'));
  });

  test('partial role saves expose a description-only retry without resaving the role', () {
    final controller = File('lib/pages/company/controllers/roles_controller.dart').readAsStringSync();
    final dialog = File('lib/pages/company/widget/roles_dialogs.dart').readAsStringSync();
    expect(controller, contains('hasPendingDescriptionSave'));
    expect(controller, contains('retryPendingRoleDescription'));
    expect(controller, contains('_pendingDescriptionSave'));
    expect(dialog, contains('retryPendingRoleDescription'));
    expect(dialog, contains('Retry description save'));
  });
}
