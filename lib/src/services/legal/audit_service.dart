import 'dart:developer';
import 'package:dio/dio.dart';

import '../../../pages/legal/models/audit_model.dart';

class AuditService {
  final Dio _dio;

  static const String _baseUrl = 'https://bomachauth.bgbot.app/api/v1';

  AuditService({
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

  /// GET /api/v1/audits/ — List Audits
  Future<({List<Audit> items, int total})> getAudits(
    String token, {
    String? auditType,
    String? status,
    String? auditorName,
    String? department,
    int? minScore,
    int? maxScore,
    String? search,
    String? startDate,
    String? endDate,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/audits/',
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          if (auditType != null && auditType.isNotEmpty)
            'audit_type': auditType,
          if (status != null && status.isNotEmpty) 'status': status,
          if (auditorName != null && auditorName.isNotEmpty)
            'auditor_name': auditorName,
          if (department != null && department.isNotEmpty)
            'department': department,
          if (minScore != null) 'min_score': minScore,
          if (maxScore != null) 'max_score': maxScore,
          if (startDate != null && startDate.isNotEmpty)
            'start_date': startDate,
          if (endDate != null && endDate.isNotEmpty) 'end_date': endDate,
          'limit': limit,
          'offset': offset,
        },
        options: _authOptions(token),
      );

      final data = response.data;
      if (data is Map && data.containsKey('items')) {
        final items = (data['items'] as List)
            .map((json) => Audit.fromJson(json))
            .toList();
        final total = data['count'] ?? data['total'] ?? items.length;
        return (items: items, total: total as int);
      }

      // Fallback: data is a plain list
      final items =
          (data as List).map((json) => Audit.fromJson(json)).toList();
      return (items: items, total: items.length);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST /api/v1/audits/ — Create Audit
  Future<Audit> createAudit(
      String token, Map<String, dynamic> data) async {
    try {
      log("AuditService: Creating audit...");
      final response = await _dio.post(
        '/audits/',
        data: data,
        options: _authOptions(token),
      );
      return Audit.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// GET /api/v1/audits/statistics/overview/ — Get Statistics
  Future<AuditStatistics> getStatistics(String token) async {
    try {
      final response = await _dio.get(
        '/audits/statistics/overview/',
        options: _authOptions(token),
      );
      return AuditStatistics.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// GET /api/v1/audits/{id}/ — Get Audit by ID
  Future<Audit> getAuditById(String token, int auditId) async {
    try {
      final response = await _dio.get(
        '/audits/$auditId/',
        options: _authOptions(token),
      );
      return Audit.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT /api/v1/audits/{id}/ — Update Audit
  Future<Audit> updateAudit(
      String token, int auditId, Map<String, dynamic> data) async {
    try {
      log("AuditService: Updating audit $auditId...");
      final response = await _dio.put(
        '/audits/$auditId/',
        data: data,
        options: _authOptions(token),
      );
      return Audit.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE /api/v1/audits/{id}/ — Delete Audit
  Future<void> deleteAudit(String token, int auditId) async {
    try {
      log("AuditService: Deleting audit $auditId...");
      await _dio.delete(
        '/audits/$auditId/',
        options: _authOptions(token),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH /api/v1/audits/{id}/status/ — Update Audit Status
  Future<Audit> updateAuditStatus(
      String token, int auditId, String status) async {
    try {
      log("AuditService: Updating audit $auditId status to $status...");
      final response = await _dio.patch(
        '/audits/$auditId/status/',
        data: {'status': status},
        options: _authOptions(token),
      );
      return Audit.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH /api/v1/audits/{id}/score/ — Update Audit Score
  Future<Audit> updateAuditScore(
      String token, int auditId, int score) async {
    try {
      log("AuditService: Updating audit $auditId score to $score...");
      final response = await _dio.patch(
        '/audits/$auditId/score/',
        data: {'score': score},
        options: _authOptions(token),
      );
      return Audit.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    String msg = "An unexpected error occurred";

    if (error is DioException) {
      if (error.response != null) {
        final data = error.response?.data;
        log("SERVER ERROR: $data");

        if (data is Map<String, dynamic>) {
          if (data['errors'] != null) {
            return Exception("Validation: ${data['errors']}");
          }
          if (data.containsKey('detail')) {
            msg = data['detail'];
          } else if (data.containsKey('message')) {
            msg = data['message'];
          }
        }
      } else {
        msg = "Connection error. Please check your internet.";
      }
    }
    return Exception(msg);
  }
}
