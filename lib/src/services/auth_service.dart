import 'dart:developer';

import 'package:dio/dio.dart';

import '../model/user_model.dart';

class AuthService {
  final Dio _dio;

  AuthService({
    String baseUrl = 'https://bomachauth.bgbot.app',
    Dio? dioOverride,
  }) : _dio = dioOverride ??
            Dio(BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 20),
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

  // GET CURRENT USER
  Future<User> getCurrentUser(
      {required String accessToken, required int userId}) async {
    try {
      // Use the specific employee endpoint instead of /auth/me
      final response = await _dio.get(
        '/api/v1/employees/employees/$userId',
        options: _authOptions(accessToken),
      );

      if (response.data == null || response.data is! Map<String, dynamic>) {
        throw AuthException(message: 'Server returned invalid user data');
      }

      return User.fromJson(response.data);
    } on DioException catch (e) {
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
}

class LoginResponse {
  final bool success;
  final String accessToken;
  final String refreshToken;
  final int userId;
  final String detail;

  LoginResponse({
    required this.success,
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.detail,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      userId: json['user_id'] ?? 0,
      detail: json['detail'] ?? '',
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
