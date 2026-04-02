import 'package:bms_front_end/src/services/biometric_api_service.dart';
import 'package:bms_front_end/src/constants/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late BiometricApiService service;

  const token = 'test-token-123';
  const baseUrl = '${ApiConstants.baseUrl}/api/v1';

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: baseUrl));
    dioAdapter = DioAdapter(dio: dio);
    service = BiometricApiService(dioOverride: dio);
  });

  group('setupFingerprint', () {
    test('should return result on success', () async {
      dioAdapter.onPost(
        '/biometric/setup-fingerprint',
        (server) => server.reply(200, {
          'status': 'success',
          'message': 'Fingerprint enrolled successfully',
          'biometric_id': 'bio-fp-001',
        }),
        data: {'biometric_data': 'encoded-fingerprint-data'},
      );

      final result = await service.setupFingerprint(
        token,
        'encoded-fingerprint-data',
      );

      expect(result, isA<Map<String, dynamic>>());
      expect(result['status'], 'success');
      expect(result['biometric_id'], 'bio-fp-001');
    });

    test('should throw on 400 error', () async {
      dioAdapter.onPost(
        '/biometric/setup-fingerprint',
        (server) => server.reply(400, {'detail': 'Invalid biometric data'}),
        data: {'biometric_data': ''},
      );

      expect(
        () => service.setupFingerprint(token, ''),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 500 error', () async {
      dioAdapter.onPost(
        '/biometric/setup-fingerprint',
        (server) => server.reply(500, {'detail': 'Server error'}),
        data: {'biometric_data': 'data'},
      );

      expect(
        () => service.setupFingerprint(token, 'data'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('setupFace', () {
    test('should return result on success', () async {
      dioAdapter.onPost(
        '/biometric/setup-face',
        (server) => server.reply(200, {
          'status': 'success',
          'message': 'Face enrolled successfully',
          'biometric_id': 'bio-face-001',
        }),
        data: {'biometric_data': 'encoded-face-data'},
      );

      final result = await service.setupFace(token, 'encoded-face-data');

      expect(result, isA<Map<String, dynamic>>());
      expect(result['status'], 'success');
      expect(result['biometric_id'], 'bio-face-001');
    });

    test('should throw on 400 error', () async {
      dioAdapter.onPost(
        '/biometric/setup-face',
        (server) => server.reply(400, {'detail': 'Invalid face data'}),
        data: {'biometric_data': 'bad'},
      );

      expect(
        () => service.setupFace(token, 'bad'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getBiometricStatus', () {
    test('should return status on success', () async {
      dioAdapter.onGet(
        '/biometric/status',
        (server) => server.reply(200, {
          'fingerprint_enrolled': true,
          'face_enrolled': false,
          'last_updated': '2026-03-15T10:00:00Z',
        }),
      );

      final result = await service.getBiometricStatus(token);

      expect(result, isA<Map<String, dynamic>>());
      expect(result['fingerprint_enrolled'], true);
      expect(result['face_enrolled'], false);
    });

    test('should throw on 403 error', () async {
      dioAdapter.onGet(
        '/biometric/status',
        (server) => server.reply(403, {'detail': 'Forbidden'}),
      );

      expect(
        () => service.getBiometricStatus(token),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 500 error', () async {
      dioAdapter.onGet(
        '/biometric/status',
        (server) => server.reply(500, {'detail': 'Server error'}),
      );

      expect(
        () => service.getBiometricStatus(token),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('removeBiometric', () {
    test('should return result on success', () async {
      dioAdapter.onPost(
        '/biometric/remove',
        (server) => server.reply(200, {
          'status': 'success',
          'message': 'Fingerprint removed',
        }),
        data: {'biometric_type': 'fingerprint'},
      );

      final result = await service.removeBiometric(token, 'fingerprint');

      expect(result, isA<Map<String, dynamic>>());
      expect(result['status'], 'success');
    });

    test('should throw on 400 error', () async {
      dioAdapter.onPost(
        '/biometric/remove',
        (server) => server.reply(400, {'detail': 'Invalid biometric type'}),
        data: {'biometric_type': 'unknown'},
      );

      expect(
        () => service.removeBiometric(token, 'unknown'),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 404 error', () async {
      dioAdapter.onPost(
        '/biometric/remove',
        (server) => server.reply(404, {'detail': 'No biometric data found'}),
        data: {'biometric_type': 'face'},
      );

      expect(
        () => service.removeBiometric(token, 'face'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('biometricLogin', () {
    test('should return login result on success', () async {
      dioAdapter.onPost(
        '/biometric/login',
        (server) => server.reply(200, {
          'access_token': 'new-jwt-token',
          'token_type': 'bearer',
          'user_id': '42',
          'email': 'user@example.com',
        }),
        data: {
          'email': 'user@example.com',
          'biometric_data': 'encoded-fp-data',
          'biometric_type': 'fingerprint',
        },
      );

      final result = await service.biometricLogin(
        token,
        email: 'user@example.com',
        biometricData: 'encoded-fp-data',
        biometricType: 'fingerprint',
      );

      expect(result, isA<Map<String, dynamic>>());
      expect(result['access_token'], 'new-jwt-token');
      expect(result['email'], 'user@example.com');
    });

    test('should throw on 401 error (bad biometric)', () async {
      dioAdapter.onPost(
        '/biometric/login',
        (server) => server.reply(401, {'detail': 'Biometric mismatch'}),
        data: {
          'email': 'user@example.com',
          'biometric_data': 'wrong-data',
          'biometric_type': 'fingerprint',
        },
      );

      expect(
        () => service.biometricLogin(
          token,
          email: 'user@example.com',
          biometricData: 'wrong-data',
          biometricType: 'fingerprint',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 500 error', () async {
      dioAdapter.onPost(
        '/biometric/login',
        (server) => server.reply(500, {'detail': 'Server error'}),
        data: {
          'email': 'user@example.com',
          'biometric_data': 'data',
          'biometric_type': 'face',
        },
      );

      expect(
        () => service.biometricLogin(
          token,
          email: 'user@example.com',
          biometricData: 'data',
          biometricType: 'face',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('biometricClockIn', () {
    test('should return clock-in result on success', () async {
      dioAdapter.onPost(
        '/biometric/clockin',
        (server) => server.reply(200, {
          'status': 'success',
          'attendance_type': 'clock_in',
          'timestamp': '2026-03-18T08:30:00Z',
          'employee_id': '42',
        }),
        data: {
          'biometric_data': 'encoded-fp-data',
          'biometric_type': 'fingerprint',
          'attendance_type': 'clock_in',
        },
      );

      final result = await service.biometricClockIn(
        token,
        biometricData: 'encoded-fp-data',
        biometricType: 'fingerprint',
        attendanceType: 'clock_in',
      );

      expect(result, isA<Map<String, dynamic>>());
      expect(result['status'], 'success');
      expect(result['attendance_type'], 'clock_in');
    });

    test('should handle clock_out attendance type', () async {
      dioAdapter.onPost(
        '/biometric/clockin',
        (server) => server.reply(200, {
          'status': 'success',
          'attendance_type': 'clock_out',
          'timestamp': '2026-03-18T17:00:00Z',
          'employee_id': '42',
        }),
        data: {
          'biometric_data': 'encoded-fp-data',
          'biometric_type': 'fingerprint',
          'attendance_type': 'clock_out',
        },
      );

      final result = await service.biometricClockIn(
        token,
        biometricData: 'encoded-fp-data',
        biometricType: 'fingerprint',
        attendanceType: 'clock_out',
      );

      expect(result['attendance_type'], 'clock_out');
    });

    test('should throw on 400 error', () async {
      dioAdapter.onPost(
        '/biometric/clockin',
        (server) => server.reply(400, {'detail': 'Invalid attendance type'}),
        data: {
          'biometric_data': 'data',
          'biometric_type': 'fingerprint',
          'attendance_type': 'invalid',
        },
      );

      expect(
        () => service.biometricClockIn(
          token,
          biometricData: 'data',
          biometricType: 'fingerprint',
          attendanceType: 'invalid',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 403 error', () async {
      dioAdapter.onPost(
        '/biometric/clockin',
        (server) => server.reply(403, {'detail': 'Not authorized'}),
        data: {
          'biometric_data': 'data',
          'biometric_type': 'face',
          'attendance_type': 'clock_in',
        },
      );

      expect(
        () => service.biometricClockIn(
          token,
          biometricData: 'data',
          biometricType: 'face',
          attendanceType: 'clock_in',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getMyAttendanceRecords', () {
    test('should return list of records on success', () async {
      dioAdapter.onGet(
        '/biometric/attendance/my-records',
        (server) => server.reply(200, [
          {
            'id': 1,
            'employee_id': '42',
            'attendance_type': 'clock_in',
            'timestamp': '2026-03-18T08:30:00Z',
            'biometric_type': 'fingerprint',
          },
          {
            'id': 2,
            'employee_id': '42',
            'attendance_type': 'clock_out',
            'timestamp': '2026-03-18T17:00:00Z',
            'biometric_type': 'fingerprint',
          },
        ]),
        queryParameters: {'limit': 50},
      );

      final result = await service.getMyAttendanceRecords(token);

      expect(result, isA<List<Map<String, dynamic>>>());
      expect(result.length, 2);
      expect(result.first['attendance_type'], 'clock_in');
      expect(result.last['attendance_type'], 'clock_out');
    });

    test('should handle empty records list', () async {
      dioAdapter.onGet(
        '/biometric/attendance/my-records',
        (server) => server.reply(200, []),
        queryParameters: {'limit': 50},
      );

      final result = await service.getMyAttendanceRecords(token);

      expect(result, isA<List<Map<String, dynamic>>>());
      expect(result, isEmpty);
    });

    test('should pass custom limit', () async {
      dioAdapter.onGet(
        '/biometric/attendance/my-records',
        (server) => server.reply(200, [
          {
            'id': 1,
            'employee_id': '42',
            'attendance_type': 'clock_in',
            'timestamp': '2026-03-18T08:30:00Z',
          },
        ]),
        queryParameters: {'limit': 10},
      );

      final result = await service.getMyAttendanceRecords(
        token,
        limit: 10,
      );

      expect(result.length, 1);
    });

    test('should throw on 403 error', () async {
      dioAdapter.onGet(
        '/biometric/attendance/my-records',
        (server) => server.reply(403, {'detail': 'Forbidden'}),
        queryParameters: {'limit': 50},
      );

      expect(
        () => service.getMyAttendanceRecords(token),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw on 500 error', () async {
      dioAdapter.onGet(
        '/biometric/attendance/my-records',
        (server) => server.reply(500, {'detail': 'Server error'}),
        queryParameters: {'limit': 50},
      );

      expect(
        () => service.getMyAttendanceRecords(token),
        throwsA(isA<Exception>()),
      );
    });
  });
}
