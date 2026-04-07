import 'dart:developer';
import 'package:bms_front_end/src/constants/api_constants.dart';

import 'package:dio/dio.dart';

import '../../pages/services/models/client_model.dart';
import '../../pages/services/models/lead_model.dart';
import '../model/role_model.dart';
import '../model/user_model.dart';

class AuthService {
  final Dio _dio;

  AuthService({
    String baseUrl = ApiConstants.baseUrl,
    Dio? dioOverride,
  }) : _dio = dioOverride ??
            Dio(BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
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

  /// Generate Options with Bearer Token
  Options _authOptions(String token) {
    return Options(headers: {
      'Authorization': 'Bearer $token',
    });
  }

  /// Handle Dio Errors consistently
  Exception _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;

      if (data is! Map<String, dynamic>) {
        return AuthException(
            message: 'Server error: ${e.response?.statusCode}',
            statusCode: e.response?.statusCode);
      }
      final message =
          data['message'] ?? data['detail'] ?? 'An unknown error occurred';
      final errors = data['errors'];

      return AuthException(
        message: message,
        errors: errors is Map<String, dynamic> ? errors : null,
        statusCode: e.response?.statusCode,
      );
    } else {
      return AuthException(message: '${e.message}');
    }
  }

  // LOGIN
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      log("AuthService: Attempting login for $email");

      final response = await _dio.post(
        '/api/v1/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      log("AuthService: Response received. Status: ${response.statusCode}");
      log("AuthService: Data: ${response.data}");

      if (response.data == null) {
        throw AuthException(message: 'Server returned an empty response');
      }

      if (response.data is! Map<String, dynamic>) {
        throw AuthException(
            message: 'Server format error: Expected JSON object');
      }

      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      log("AuthService: Unknown error: $e");
      throw AuthException(message: 'Unexpected error: $e');
    }
  }

  // VERIFY 2FA
  Future<LoginResponse> verify2Fa({
    required String sessionToken,
    required String code,
  }) async {
    try {
      log("AuthService: Attempting 2FA verification");

      final response = await _dio.post(
        '/api/v1/auth/verify-2fa',
        data: {
          'session_token': sessionToken,
          'code': code,
        },
      );

      log("AuthService: 2FA Response received. Status: ${response.statusCode}");
      log("AuthService: Data: ${response.data}");

      if (response.data == null) {
        throw AuthException(message: 'Server returned an empty response');
      }

      if (response.data is! Map<String, dynamic>) {
        throw AuthException(
            message: 'Server format error: Expected JSON object');
      }

      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      log("AuthService: Unknown error during 2FA: $e");
      throw AuthException(message: 'Unexpected error: $e');
    }
  }

  // GET CURRENT USER
  Future<User> getCurrentUser(
      {required String accessToken, required int userId}) async {
    try {
      // Strictly use the employee-specific endpoint.
      // This ensures that only users with an active employee record can access the system.
      final response = await _dio.get(
        '/api/v1/employees/employees/$userId',
        options: _authOptions(accessToken),
      );

      if (response.data == null || response.data is! Map<String, dynamic>) {
        throw AuthException(message: 'Server returned invalid employee profile');
      }

      return User.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 || e.response?.statusCode == 403) {
        throw AuthException(
            message: 'No active employee profile found. Access Denied.',
            statusCode: e.response?.statusCode ?? 403);
      }
      throw _handleError(e);
    }
  }

  // GET EMPLOYEE ROLES
  Future<List<Role>> getEmployeeRoles(
      {required String accessToken, required int userId}) async {
    try {
      final response = await _dio.get(
        '/api/v1/roles/employees/$userId',
        options: _authOptions(accessToken),
      );

      if (response.data == null) return [];

      if (response.data is Map<String, dynamic>) {
        return [Role.fromJson(response.data as Map<String, dynamic>)];
      }

      if (response.data is List) {
        return (response.data as List)
            .map((json) => Role.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      // If employee record is not found (403/404), return empty roles list
      // instead of throwing an exception that blocks login.
      if (e.response?.statusCode == 403 || e.response?.statusCode == 404) {
        log("AuthService: No employee profile found for user $userId. Returning empty roles.");
        return [];
      }
      throw _handleError(e);
    }
  }


  // REFRESH TOKEN
  Future<String> refreshToken({required String refreshToken}) async {
    try {
      final response = await _dio.post(
        '/api/v1/auth/refresh',
        data: {
          'refresh_token': refreshToken,
        },
      );
      return response.data['access_token'];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // VERIFY TOKEN
  Future<bool> verifyToken({required String accessToken}) async {
    try {
      final response = await _dio.get(
        '/api/v1/auth/verify-token',
        options: _authOptions(accessToken),
      );

      final data = response.data;
      // Accepts bool, int, or string for 'valid'
      final valid = data['valid'];
      if (valid is bool) return valid;
      if (valid is int) return valid == 1;
      if (valid is String) {
        return valid.toLowerCase() == 'true' || valid == '1';
      }
      return false;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return false;
      }
      throw _handleError(e);
    }
  }

  // FORGOT PASSWORD
  Future<String> forgotPassword({required String email}) async {
    try {
      final response = await _dio.post(
        '/api/v1/auth/forgot-password',
        data: {
          'email': email,
        },
      );
      return response.data['detail'] ?? 'Code sent';
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // RESET PASSWORD
  Future<String> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/auth/reset-password',
        data: {
          'email': email,
          'code': code,
          'new_password': newPassword,
        },
      );
      return response.data['detail'] ?? 'Password reset successfully';
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // UPDATE PROFILE (/auth/me)
  Future<User> updateMe({
    required String accessToken,
    required int employeeId,
    String? phoneNumber,
    String? gender,
    String? maritalStatus,
    String? dateOfBirth,
    String? address,
    String? username,
  }) async {
    try {
      final payload = <String, dynamic>{};
      if (phoneNumber != null) payload['phone_number'] = phoneNumber;
      if (gender != null) payload['gender'] = gender;
      if (maritalStatus != null) payload['marital_status'] = maritalStatus;
      if (dateOfBirth != null && dateOfBirth.isNotEmpty) {
        payload['date_of_birth'] = dateOfBirth;
      }
      if (address != null) payload['address'] = address;
      if (username != null) payload['username'] = username;

      final response = await _dio.patch(
        '/api/v1/employees/employees/$employeeId',
        data: payload,
        options: _authOptions(accessToken),
      );

      if (response.data == null || response.data is! Map<String, dynamic>) {
        throw AuthException(message: 'Invalid response from server');
      }

      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ──────────────────── 2FA SETTINGS ────────────────────
  Future<bool> get2FaStatus(String accessToken) async {
    try {
      final response = await _dio.get(
        '/api/v1/auth/2fa/status',
        options: _authOptions(accessToken),
      );
      if (response.data is Map<String, dynamic>) {
        return response.data['is_enabled'] ?? response.data['enabled'] ?? response.data['status'] ?? false;
      }
      return false;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> enable2Fa(String accessToken) async {
    try {
      final response = await _dio.post(
        '/api/v1/auth/2fa/enable',
        data: {}, // Handled by backend schema possibly requiring password someday, but trying empty
        options: _authOptions(accessToken),
      );
      if (response.data is Map<String, dynamic>) {
        return response.data['is_enabled'] ?? response.data['enabled'] ?? response.data['status'] ?? true;
      }
      return true;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> disable2Fa(String accessToken) async {
    try {
      final response = await _dio.post(
        '/api/v1/auth/2fa/disable',
        data: {}, // Handled by backend
        options: _authOptions(accessToken),
      );
      if (response.data is Map<String, dynamic>) {
        return response.data['is_enabled'] ?? response.data['enabled'] ?? response.data['status'] ?? false;
      }
      return false;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // LOGOUT
  Future<void> logout({required String accessToken}) async {
    try {
      await _dio.post(
        '/api/v1/auth/logout',
        options: _authOptions(accessToken),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // LEADS
  Future<List<Lead>> getLeads(
    String token, {
    String? status,
    String? search,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/clients/leads/',
        queryParameters: {
          if (status != null) 'status': status,
          if (search != null && search.isNotEmpty) 'search': search,
          'limit': limit,
          'offset': offset,
        },
        options: _authOptions(token),
      );

      final data = response.data;
      final List<dynamic> list =
          (data is Map && data.containsKey('items')) ? data['items'] : data;

      return list.map((json) => Lead.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Lead> createLead(
    String token,
    Map<String, dynamic> leadData,
  ) async {
    try {
      final response = await _dio.post(
        '/api/v1/clients/leads/',
        data: leadData,
        options: _authOptions(token),
      );
      return Lead.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Lead> updateLead(
    String token,
    int leadId,
    Map<String, dynamic> leadData,
  ) async {
    try {
      final response = await _dio.put(
        '/api/v1/clients/leads/$leadId/',
        data: leadData,
        options: _authOptions(token),
      );
      return Lead.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteLead(String token, int leadId) async {
    try {
      await _dio.delete(
        '/api/v1/clients/leads/$leadId/',
        options: _authOptions(token),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> convertLeadToClient(String token, int leadId) async {
    try {
      await _dio.post(
        '/api/v1/clients/leads/$leadId/convert-to-client/',
        options: _authOptions(token),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // CLIENTS
  Future<List<Client>> getClients(
    String token, {
    String? search,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/clients/clients/',
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          'limit': limit,
          'offset': offset,
        },
        options: _authOptions(token),
      );

      final data = response.data;
      final List<dynamic> list =
          (data is Map && data.containsKey('items')) ? data['items'] : data;

      return list.map((json) => Client.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Client> createClient(
    String token,
    Map<String, dynamic> clientData,
  ) async {
    try {
      final response = await _dio.post(
        '/api/v1/clients/clients/',
        data: clientData,
        options: _authOptions(token),
      );
      return Client.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Client> updateClient(
    String token,
    int clientId,
    Map<String, dynamic> clientData,
  ) async {
    try {
      final response = await _dio.put(
        '/api/v1/clients/clients/$clientId/',
        data: clientData,
        options: _authOptions(token),
      );
      return Client.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteClient(String token, int clientId) async {
    try {
      await _dio.delete(
        '/api/v1/clients/clients/$clientId/',
        options: _authOptions(token),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // FILE UPLOAD
  Future<String> uploadFile(
      String token, List<int> fileBytes, String fileName) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(fileBytes, filename: fileName),
      });

      final response = await _dio.post(
        '/api/v1/others/upload-file',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return response.data['url'] as String;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}

class LoginResponse {
  final bool success;
  final String accessToken;
  final String refreshToken;
  final int userId;
  final String detail;
  final bool requires2Fa;
  final String sessionToken;

  LoginResponse({
    required this.success,
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.detail,
    this.requires2Fa = false,
    this.sessionToken = '',
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      userId: json['user_id'] ?? 0,
      detail: json['detail'] ?? '',
      requires2Fa: json['requires_2fa'] ?? false,
      sessionToken: json['session_token'] ?? '',
    );
  }
}

class AuthException implements Exception {
  final String message;
  final Map<String, dynamic>? errors;
  final int? statusCode;

  AuthException({required this.message, this.errors, this.statusCode});

  @override
  String toString() => message;
}
