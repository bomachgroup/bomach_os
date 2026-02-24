import 'dart:developer';
import 'package:dio/dio.dart';

import '../model/company_model.dart';

class CompanyService {
  final Dio _dio;
  static const baseUrl = "https://bomachauth.bgbot.app";
  CompanyService({
    Dio? dioOverride,
  }) : _dio = dioOverride ??
            Dio(BaseOptions(
              baseUrl: baseUrl,
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

  Future<CompanySettings> getCompanySettings(
      {required String accessToken}) async {
    try {
      log("CompanyService: Fetching settings...");

      final response = await _dio.get(
        '/api/v1/company/company-settings',
        options: _authOptions(accessToken),
      );

      if (response.data == null || response.data is! Map<String, dynamic>) {
        throw Exception("Server returned invalid data format");
      }

      return CompanySettings.fromJson(response.data);
    } on DioException catch (e) {
      log("CompanyService: Fetch Error - ${e.message}");
      throw _handleError(e);
    } catch (e) {
      log("CompanyService: Unexpected Error - $e");
      rethrow;
    }
  }

  Future<CompanySettings> updateCompanySettings({
    required String accessToken,
    required CompanySettings settings,
  }) async {
    try {
      log("CompanyService: Updating settings...");

      final response = await _dio.put(
        '/api/v1/company/company-settings',
        data: settings.toUpdateJson(),
        options: _authOptions(accessToken),
      );

      if (response.data == null || response.data is! Map<String, dynamic>) {
        throw Exception("Server returned invalid data format after update");
      }

      return CompanySettings.fromJson(response.data);
    } on DioException catch (e) {
      log("CompanyService: Update Error - ${e.message}");
      throw _handleError(e);
    } catch (e) {
      log("CompanyService: Unexpected Error - $e");
      rethrow;
    }
  }

  Future<List<Compliance>> getComplianceRecords(String token) async {
    try {
      final response = await _dio.get(
        '/api/v1/compliance/compliance-records',
        options: _authOptions(token),
      );
      final List data = response.data['items'] ?? [];
      return data.map((e) => Compliance.fromJson(e)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> createCompliance(String token, Compliance compliance) async {
    try {
      await _dio.post(
        '/api/v1/compliance/compliance-records',
        data: compliance.toJson(),
        options: _authOptions(token),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<DashboardStats> getDashboardStats(
      {required String accessToken}) async {
    try {
      final response = await _dio.get(
        '/api/v1/stats/dashboard',
        options: _authOptions(accessToken),
      );
      return DashboardStats.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // --- AUDIT LOGS ---
  Future<List<AuditLog>> getAuditLogs(String token,
      {int limit = 20, int offset = 0}) async {
    try {
      final response = await _dio.get(
        '/api/v1/audit-logs/',
        queryParameters: {'limit': limit, 'offset': offset},
        options: _authOptions(token),
      );
      final List data = response.data['items'] ?? [];
      return data.map((e) => AuditLog.fromJson(e)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    String msg = "An unexpected error occurred";

    if (e.response != null) {
      final data = e.response?.data;

      if (data is Map<String, dynamic>) {
        if (data.containsKey('detail')) {
          msg = data['detail'];
        } else if (data.containsKey('message')) {
          msg = data['message'];
        }
      }
    } else {
      msg = "Connection error. Please check your internet.";
    }

    return Exception(msg);
  }
}
