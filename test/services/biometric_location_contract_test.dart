import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:bomach_os/src/services/biometric_api_service.dart';

void main() {
  test('surfaces a missing workspaces endpoint instead of returning empty data', () async {
    final dio = Dio(BaseOptions(baseUrl: '${ApiConstants.baseUrl}/api/v1'));
    final adapter = DioAdapter(dio: dio);
    adapter.onGet(
      '/biometric/location/whitelisted',
      (server) => server.reply(404, {'detail': 'Not Found'}),
    );

    expect(
      () => BiometricApiService(dioOverride: dio).getWorkspaces('token'),
      throwsA(isA<Exception>()),
    );
  });

  test('surfaces a missing pending-workspaces endpoint instead of returning empty data', () async {
    final dio = Dio(BaseOptions(baseUrl: '${ApiConstants.baseUrl}/api/v1'));
    final adapter = DioAdapter(dio: dio);
    adapter.onGet(
      '/biometric/location/pending',
      (server) => server.reply(404, {'detail': 'Not Found'}),
    );

    expect(
      () => BiometricApiService(dioOverride: dio).getPendingWorkspaces('token'),
      throwsA(isA<Exception>()),
    );
  });

  test('verifyLocation sends latitude and longitude query parameters', () async {
    final dio = Dio(BaseOptions(baseUrl: '${ApiConstants.baseUrl}/api/v1'));
    final adapter = DioAdapter(dio: dio);
    adapter.onGet(
      '/biometric/location/verify',
      (server) => server.reply(200, {
        'is_valid': true,
        'location_name': 'HQ',
        'distance_meters': 12.5,
      }),
      queryParameters: {'latitude': 6.52, 'longitude': 3.37},
    );

    final result = await BiometricApiService(dioOverride: dio).verifyLocation(
      'token',
      latitude: 6.52,
      longitude: 3.37,
    );

    expect(result['is_valid'], isTrue);
    expect(result['distance_meters'], 12.5);
  });
}
