import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

const _openApiUrl =
    'https://bomachauthtest.bgbot.app/api/v1/openapi.json';

Future<Map<String, dynamic>> _loadContract() async {
  final response = await Dio().get<String>(_openApiUrl);
  expect(response.statusCode, 200);
  return jsonDecode(response.data!) as Map<String, dynamic>;
}

Map<String, dynamic> _paths(Map<String, dynamic> contract) =>
    contract['paths'] as Map<String, dynamic>;

void main() {
  test('published contract exposes the CEO correction endpoints and payloads',
      () async {
    final contract = await _loadContract();
    final paths = _paths(contract);

    for (final path in [
      '/api/v1/employees/employees',
      '/api/v1/biometric/clockin',
      '/api/v1/biometric/location/verify',
      '/api/v1/roles/me/authority-limits',
      '/api/v1/roles/{role_id}/reporting-tree',
      '/api/v1/roles/{role_id}/daily-routine',
      '/api/v1/roles/{role_id}/training-requirements',
      '/api/v1/work-reports/',
      '/api/v1/target-reports/',
      '/api/v1/training-programs/',
      '/api/v1/assets/',
      '/api/v1/audit-logs/',
    ]) {
      expect(paths.containsKey(path), isTrue, reason: 'Missing $path');
    }

    final schemas = (contract['components'] as Map<String, dynamic>)['schemas']
        as Map<String, dynamic>;
    final clockIn = schemas['BiometricClockInRequest'] as Map<String, dynamic>;
    expect(clockIn['required'], containsAll([
      'biometric_data',
      'biometric_type',
      'attendance_type',
      'latitude',
      'longitude',
    ]));

    final workReportGet = paths['/api/v1/work-reports/']['get']
        as Map<String, dynamic>;
    final workReportParameters = (workReportGet['parameters'] as List)
        .map((parameter) => (parameter as Map<String, dynamic>)['name'])
        .toSet();
    expect(workReportParameters, isNot(contains('mood')));
  });

  test('published contract does not silently claim unsupported capabilities',
      () async {
    final paths = _paths(await _loadContract());

    for (final path in [
      '/api/v1/role-okrs/',
      '/api/v1/role-reports/',
      '/api/v1/knowledge-base/',
    ]) {
      expect(paths.containsKey(path), isFalse, reason: 'Unexpected $path');
    }

    final pathText = paths.keys.join('\n').toLowerCase();
    expect(pathText, isNot(contains('device')));
    expect(pathText, isNot(contains('platform-verification')));
    expect(pathText, isNot(contains('personal-verification')));
  });
}
