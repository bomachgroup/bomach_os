import 'dart:developer';

import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:bomach_os/src/helper/error_helper.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../model/company_model.dart';

class CompanyService {
  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static final baseUrl = ApiConstants.baseUrl;
  CompanyService({Dio? dioOverride})
    : _dio =
          dioOverride ??
          Dio(
            BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            ),
          ) {
    _dio.interceptors.add(
      LogInterceptor(
      request: true,
      requestHeader: true,
      responseBody: true,
      responseHeader: false,
      ),
    );
  }

  Options _authOptions(String token) {
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<CompanySettings> getCompanySettings({
    required String accessToken,
  }) async {
    try {
      log(
        "CompanyService: Fetching settings (profile + branding + preferences)...",
      );

      final results = await Future.wait([
        _dio.get(
          '/api/v1/company/company/profile',
          options: _authOptions(accessToken),
        ),
        _dio.get(
          '/api/v1/company/company/branding',
          options: _authOptions(accessToken),
        ),
        _dio.get(
          '/api/v1/company/company/preferences',
          options: _authOptions(accessToken),
        ),
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
      log(
        "CompanyService: Updating settings (profile + branding + preferences)...",
      );

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
    String token,
    String id,
    Compliance compliance,
  ) async {
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

  Future<List<Shareholder>> getShareholders(
    String token, {
    int limit = 100,
    int offset = 0,
  }) async {
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
    String token,
    Map<String, dynamic> data,
  ) async {
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
    String token,
    int id,
    Map<String, dynamic> data,
  ) async {
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
      final shareholders = await getShareholders(token, limit: 200);
      final issuedShares = shareholders.fold<int>(
        0,
        (sum, s) => sum + s.shareCount,
      );
      final saved = await _storage.read(key: 'authorized_shares');
      final authorizedShares = int.tryParse(saved ?? '') ?? 0;
      return EquityInfo(
        authorizedShares: authorizedShares,
        issuedShares: issuedShares,
        unissuedShares: authorizedShares - issuedShares,
      );
    } catch (e) {
      throw Exception('Could not compute equity info: $e');
    }
  }

  Future<EquityInfo> updateEquityInfo(
    String token,
    int authorizedShares,
  ) async {
    await _storage.write(
      key: 'authorized_shares',
      value: authorizedShares.toString(),
    );
    final shareholders = await getShareholders(token, limit: 200);
    final issuedShares = shareholders.fold<int>(
      0,
      (sum, s) => sum + s.shareCount,
    );
    return EquityInfo(
      authorizedShares: authorizedShares,
      issuedShares: issuedShares,
      unissuedShares: authorizedShares - issuedShares,
    );
  }

  Future<DashboardStats> getDashboardStats({
    required String accessToken,
  }) async {
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

  Future<CompanyFieldChoices> getCompanyFieldChoices({
    required String accessToken,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/company/company/choices',
        options: _authOptions(accessToken),
      );
      return CompanyFieldChoices.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // --- AUDIT LOGS ---
  Future<({List<AuditLog> items, int count})> getAuditLogs(
    String token, {
    String? search,
    String? userId,
    String? auditType,
    String? auditStatus,
    String? startDate,
    String? endDate,
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/audit-logs/',
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          if (userId != null && userId.isNotEmpty) 'user_id': userId,
          if (auditType != null && auditType.isNotEmpty)
            'audit_type': auditType,
          if (auditStatus != null && auditStatus.isNotEmpty)
            'audit_status': auditStatus,
          if (startDate != null && startDate.isNotEmpty)
            'start_date': startDate,
          if (endDate != null && endDate.isNotEmpty) 'end_date': endDate,
          'limit': limit,
          'offset': offset,
        },
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
    final msg = ErrorHelper.getReadableErrorMessage(e);
    return Exception(msg);
  }
}
