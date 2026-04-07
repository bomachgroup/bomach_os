import 'package:dio/dio.dart';
import 'package:bms_front_end/src/constants/api_constants.dart';

class BiometricApiService {
  final Dio _dio;

  static const String _baseUrl = '${ApiConstants.baseUrl}/api/v1';

  BiometricApiService({
    Dio? dioOverride,
  }) : _dio = dioOverride ??
            Dio(BaseOptions(
              baseUrl: _baseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            )) {
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      responseBody: true,
      responseHeader: false,
    ));
  }

  Options _authOptions(String token) {
    return Options(headers: {
      'Authorization': 'Bearer $token',
    });
  }

  Future<Map<String, dynamic>> setupFingerprint(
      String token, String biometricData) async {
    try {
      final response = await _dio.post(
        '/biometric/setup-fingerprint',
        data: {'biometric_data': biometricData},
        options: _authOptions(token),
      );
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> setupFace(
      String token, String biometricData) async {
    try {
      final response = await _dio.post(
        '/biometric/setup-face',
        data: {'biometric_data': biometricData},
        options: _authOptions(token),
      );
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getBiometricStatus(String token) async {
    try {
      final response = await _dio.get(
        '/biometric/status',
        options: _authOptions(token),
      );
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> removeBiometric(
      String token, String biometricType) async {
    try {
      final response = await _dio.post(
        '/biometric/remove',
        data: {'biometric_type': biometricType},
        options: _authOptions(token),
      );
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> biometricLogin(
    String token, {
    required String email,
    required String biometricData,
    required String biometricType,
  }) async {
    try {
      final response = await _dio.post(
        '/biometric/login',
        data: {
          'email': email,
          'biometric_data': biometricData,
          'biometric_type': biometricType,
        },
        options: _authOptions(token),
      );
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> biometricClockIn(
    String token, {
    required String biometricData,
    required String biometricType,
    required String attendanceType,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final data = <String, dynamic>{
        'biometric_data': biometricData,
        'biometric_type': biometricType,
        'attendance_type': attendanceType,
      };
      if (latitude != null) data['latitude'] = latitude;
      if (longitude != null) data['longitude'] = longitude;

      final response = await _dio.post(
        '/biometric/clockin',
        data: data,
        options: _authOptions(token),
      );
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ── Workspace Management ─────────────────────────────────────────────

  Future<Map<String, dynamic>> setupWorkspace(
    String token, {
    required double latitude,
    required double longitude,
    required String workspaceName,
    required int radiusMeters,
  }) async {
    try {
      final response = await _dio.post(
        '/biometric/location/whitelisted',
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'name': workspaceName,
          'radius_meters': radiusMeters,
        },
        options: _authOptions(token),
      );
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>?> getWorkspace(String token) async {
    try {
      final response = await _dio.get(
        '/biometric/location/whitelisted',
        options: _authOptions(token),
      );
      final data = response.data;
      if (data != null && data['items'] != null && (data['items'] as List).isNotEmpty) {
        return Map<String, dynamic>.from(data['items'].first);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw _handleError(e);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateWorkspace(
    String token, {
    required int locationId,
    required double latitude,
    required double longitude,
    required String workspaceName,
    required int radiusMeters,
  }) async {
    try {
      final response = await _dio.patch(
        '/biometric/location/whitelisted/$locationId',
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'name': workspaceName,
          'radius_meters': radiusMeters,
        },
        options: _authOptions(token),
      );
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getMyAttendanceRecords(
    String token, {
    int limit = 50,
  }) async {
    try {
      final response = await _dio.get(
        '/biometric/attendance/my-records',
        queryParameters: {'limit': limit},
        options: _authOptions(token),
      );
      final data = response.data;
      if (data == null) return [];
      if (data is List) {
        return data.whereType<Map<String, dynamic>>().toList();
      }
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      final errorMessage = error.response?.data?['detail'] ??
          error.response?.data?['message'] ??
          error.message;
      return Exception(
          'API Error: ${error.response?.statusCode} - $errorMessage');
    }
    return Exception('Unexpected error: $error');
  }
}
