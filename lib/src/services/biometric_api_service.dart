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

  /// POST /biometric/location/whitelisted
  ///
  /// Maps to backend's `CreateWorkLocationRequest`. Required fields:
  /// `name`, `location_type`, `latitude`, `longitude`. Optional:
  /// `allowed_radius_meters` (default 100), `branch_id`, `expires_at`, `notes`.
  Future<Map<String, dynamic>> setupWorkspace(
    String token, {
    required String workspaceName,
    required String locationType,
    required double latitude,
    required double longitude,
    int allowedRadiusMeters = 100,
    int? branchId,
    String? expiresAt,
    String? notes,
  }) async {
    try {
      final data = <String, dynamic>{
        'name': workspaceName,
        'location_type': locationType,
        'latitude': latitude,
        'longitude': longitude,
        'allowed_radius_meters': allowedRadiusMeters,
      };
      if (branchId != null) data['branch_id'] = branchId;
      if (expiresAt != null) data['expires_at'] = expiresAt;
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
  /// This helper flattens it and returns the first usable location, or null.
  Future<Map<String, dynamic>?> getWorkspace(String token) async {
    try {
      final response = await _dio.get(
        '/biometric/location/whitelisted',
        options: _authOptions(token),
      );
      final data = response.data;
      if (data is Map && data['locations'] is List) {
        final locations = data['locations'] as List;
        if (locations.isNotEmpty) {
          // Prefer a verified + active location if one exists.
          final preferred = locations.firstWhere(
            (l) =>
                (l is Map) &&
                (l['is_verified'] == true) &&
                (l['is_active'] == true),
            orElse: () => locations.first,
          );
          return Map<String, dynamic>.from(preferred);
        }
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw _handleError(e);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH /biometric/location/whitelisted/{location_id}
  ///
  /// Maps to backend's `UpdateWorkLocationRequest`. All fields optional —
  /// only non-null values are sent so we only mutate what the caller changes.
  Future<Map<String, dynamic>> updateWorkspace(
    String token, {
    required int locationId,
    String? workspaceName,
    double? latitude,
    double? longitude,
    int? allowedRadiusMeters,
    bool? isActive,
    bool? isVerified,
    String? expiresAt,
    String? notes,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (workspaceName != null) data['name'] = workspaceName;
      if (latitude != null) data['latitude'] = latitude;
      if (longitude != null) data['longitude'] = longitude;
      if (allowedRadiusMeters != null) {
        data['allowed_radius_meters'] = allowedRadiusMeters;
      }
      if (isActive != null) data['is_active'] = isActive;
      if (isVerified != null) data['is_verified'] = isVerified;
      if (expiresAt != null) data['expires_at'] = expiresAt;
      if (notes != null) data['notes'] = notes;

      final response = await _dio.patch(
        '/biometric/location/whitelisted/$locationId',
        data: data,
        options: _authOptions(token),
      );
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE /biometric/location/whitelisted/{location_id}
  /// Deletes the caller's own unverified work location.
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
