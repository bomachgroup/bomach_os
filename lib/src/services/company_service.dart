import 'dart:developer';

import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:dio/dio.dart';

import '../model/company_model.dart';

class CompanyService {
  final Dio _dio;
  static final baseUrl = ApiConstants.baseUrl;
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
      log("CompanyService: Fetching settings (profile + branding + preferences)...");

      final results = await Future.wait([
        _dio.get('/api/v1/company/company/profile',
            options: _authOptions(accessToken)),
        _dio.get('/api/v1/company/company/branding',
            options: _authOptions(accessToken)),
        _dio.get('/api/v1/company/company/preferences',
            options: _authOptions(accessToken)),
      ]);

      final profile = _asMap(results[0].data);
      final branding = _asMap(results[1].data);
      final preferences = _asMap(results[2].data);

      return CompanySettings.merge(
        profile: profile,
        branding: branding,
        preferences: preferences,
      );
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
      log("CompanyService: Updating settings (profile + branding + preferences)...");

      final results = await Future.wait([
        _dio.put(
          '/api/v1/company/company/profile',
          data: settings.toProfileUpdateJson(),
          options: _authOptions(accessToken),
        ),
        _dio.put(
          '/api/v1/company/company/branding',
          data: settings.toBrandingUpdateJson(),
          options: _authOptions(accessToken),
        ),
        _dio.put(
          '/api/v1/company/company/preferences',
          data: settings.toPreferencesUpdateJson(),
          options: _authOptions(accessToken),
        ),
      ]);

      return CompanySettings.merge(
        profile: _asMap(results[0].data),
        branding: _asMap(results[1].data),
        preferences: _asMap(results[2].data),
      );
    } on DioException catch (e) {
      log("CompanyService: Update Error - ${e.message}");
      throw _handleError(e);
    } catch (e) {
      log("CompanyService: Unexpected Error - $e");
      rethrow;
    }
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
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

  Future<void> updateCompliance(
      String token, String id, Compliance compliance) async {
    try {
      await _dio.put(
        '/api/v1/compliance/compliance-records/$id',
        data: compliance.toJson(),
        options: _authOptions(token),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteCompliance(String token, String id) async {
    try {
      await _dio.delete(
        '/api/v1/compliance/compliance-records/$id',
        options: _authOptions(token),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Shareholder>> getShareholders(String token,
      {int limit = 100, int offset = 0}) async {
    try {
      final response = await _dio.get(
        '/api/v1/shareholders/',
        queryParameters: {'limit': limit, 'offset': offset},
        options: _authOptions(token),
      );
      final List items = response.data['items'] ?? [];
      return items.map((e) => Shareholder.fromJson(e)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Shareholder> createShareholder(
      String token, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        '/api/v1/shareholders/',
        data: data,
        options: _authOptions(token),
      );
      return Shareholder.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Shareholder> updateShareholder(
      String token, int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        '/api/v1/shareholders/$id',
        data: data,
        options: _authOptions(token),
      );
      return Shareholder.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteShareholder(String token, int id) async {
    try {
      await _dio.delete(
        '/api/v1/shareholders/$id',
        options: _authOptions(token),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<EquityInfo> getEquityInfo(String token) async {
    try {
      final response = await _dio.get(
        '/api/v1/shareholders/equity',
        options: _authOptions(token),
      );
      return EquityInfo.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<EquityInfo> updateEquityInfo(
      String token, int authorizedShares) async {
    try {
      final response = await _dio.put(
        '/api/v1/shareholders/equity',
        data: {'authorized_shares': authorizedShares},
        options: _authOptions(token),
      );
      return EquityInfo.fromJson(response.data);
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
  Future<({List<AuditLog> items, int count})> getAuditLogs(String token,
      {int limit = 10, int offset = 0}) async {
    try {
      final response = await _dio.get(
        '/api/v1/audit-logs/',
        queryParameters: {'limit': limit, 'offset': offset},
        options: _authOptions(token),
      );
      final List data = response.data['items'] ?? [];
      final int count = response.data['count'] ?? 0;
      return (
        items: data.map((e) => AuditLog.fromJson(e)).toList(),
        count: count,
      );
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
