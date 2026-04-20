import 'package:bms_front_end/src/constants/api_constants.dart';
import 'package:dio/dio.dart';

class BiometricApiService {
  final Dio _dio;

  static final String _baseUrl = '${ApiConstants.baseUrl}/api/v1';

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
      final response = await getRawStatusResponse(token: token);
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Internal helper to get the raw Dio Response (needed for headers)
  Future<Response> getRawStatusResponse({String? token}) async {
    try {
      return await _dio.get(
        '/biometric/status',
        options: token != null ? _authOptions(token) : null,
      );
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

  /// POST /biometric/clockin
  ///
  /// Backend requires all 5 fields. If [latitude]/[longitude] are not yet
  /// available (e.g., location permission pending), the caller should not
  /// invoke this method — the request will 422 "field required".
  Future<Map<String, dynamic>> biometricClockIn(
    String token, {
    required String biometricData,
    required String biometricType,
    required String attendanceType,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.post(
        '/biometric/clockin',
        data: {
          'biometric_data': biometricData,
          'biometric_type': biometricType,
          'attendance_type': attendanceType,
          'latitude': latitude,
          'longitude': longitude,
        },
        options: _authOptions(token),
      );
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ── Workspace Management ─────────────────────────────────────────────

  /// Radius used for every submitted workspace. Admin-controlled at approval
  /// time; the user never sets or sees this.
  static const int defaultWorkspaceRadiusMeters = 100;

  /// POST /biometric/location/whitelisted
  ///
  /// Employee submission. Lands in backend as `status = PENDING` until an
  /// admin approves. Radius is hardcoded (100m) — the user does not set it.
  Future<Map<String, dynamic>> submitWorkspace(
    String token, {
    required String workspaceName,
    required double latitude,
    required double longitude,
    String? notes,
  }) async {
    try {
      final data = <String, dynamic>{
        'name': workspaceName,
        'latitude': latitude,
        'longitude': longitude,
        'allowed_radius_meters': defaultWorkspaceRadiusMeters,
      };
      if (notes != null && notes.isNotEmpty) data['notes'] = notes;

      final response = await _dio.post(
        '/biometric/location/whitelisted',
        data: data,
        options: _authOptions(token),
      );
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// GET /biometric/location/whitelisted
  ///
  /// Returns `WorkLocationListResponse` ({ "locations": [...], "total": N }).
  /// Returns the FULL list of the caller's submissions (any status) so the
  /// page can render them all with their status chips.
  Future<List<Map<String, dynamic>>> getWorkspaces(String token) async {
    try {
      final response = await _dio.get(
        '/biometric/location/whitelisted',
        options: _authOptions(token),
      );
      final data = response.data;
      if (data is Map && data['locations'] is List) {
        return (data['locations'] as List)
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      if (data is List) {
        return data
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      throw _handleError(e);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE /biometric/location/whitelisted/{location_id}
  /// Deletes the caller's own work location (any status).
  Future<void> deleteWorkspace(String token, int locationId) async {
    try {
      await _dio.delete(
        '/biometric/location/whitelisted/$locationId',
        options: _authOptions(token),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// GET /biometric/location/verify?latitude=..&longitude=..
  /// Returns a `LocationStatusResponse` telling whether the given position
  /// is within range of any approved work location.
  Future<Map<String, dynamic>> verifyLocation(
    String token, {
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.get(
        '/biometric/location/verify',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
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
