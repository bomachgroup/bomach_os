import 'dart:developer';

import 'package:bms_front_end/src/constants/api_constants.dart';
import 'package:dio/dio.dart';

import '../../../pages/legal/models/legal_case_model.dart';

class LegalCaseService {
  final Dio _dio;

  static final String _baseUrl = '${ApiConstants.baseUrl}/api/v1';

  LegalCaseService({
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

  /// GET /api/v1/cases/ — List Legal Cases
  Future<({List<LegalCase> items, int total})> getCases(
    String token, {
    String? caseType,
    String? status,
    String? search,
    String? startDate,
    String? endDate,
    bool? hasUpcomingHearing,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/cases/',
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          if (caseType != null && caseType.isNotEmpty) 'case_type': caseType,
          if (status != null && status.isNotEmpty) 'status': status,
          if (startDate != null && startDate.isNotEmpty)
            'start_date': startDate,
          if (endDate != null && endDate.isNotEmpty) 'end_date': endDate,
          if (hasUpcomingHearing != null)
            'has_upcoming_hearing': hasUpcomingHearing,
          'limit': limit,
          'offset': offset,
        },
        options: _authOptions(token),
      );

      final data = response.data;
      if (data is Map && data.containsKey('items')) {
        final items = (data['items'] as List)
            .map((json) => LegalCase.fromJson(json))
            .toList();
        final total = data['count'] ?? data['total'] ?? items.length;
        return (items: items, total: total as int);
      }

      // Fallback: data is a plain list
      final items =
          (data as List).map((json) => LegalCase.fromJson(json)).toList();
      return (items: items, total: items.length);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST /api/v1/cases/ — Create Legal Case
  Future<LegalCase> createCase(String token, Map<String, dynamic> data) async {
    try {
      log("LegalCaseService: Creating case...");
      final response = await _dio.post(
        '/cases/',
        data: data,
        options: _authOptions(token),
      );
      return LegalCase.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// GET /api/v1/cases/statistics/overview/ — Get Statistics
  Future<LegalCaseStatistics> getStatistics(String token) async {
    try {
      final response = await _dio.get(
        '/cases/statistics/overview/',
        options: _authOptions(token),
      );
      return LegalCaseStatistics.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// GET /api/v1/cases/upcoming-hearings/ — Get Upcoming Hearings
  Future<List<LegalCase>> getUpcomingHearings(
    String token, {
    int days = 30,
  }) async {
    try {
      final response = await _dio.get(
        '/cases/upcoming-hearings/',
        queryParameters: {'days': days},
        options: _authOptions(token),
      );

      final data = response.data;
      if (data is List) {
        return data.map((json) => LegalCase.fromJson(json)).toList();
      }
      if (data is Map && data.containsKey('items')) {
        return (data['items'] as List)
            .map((json) => LegalCase.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// GET /api/v1/cases/{id}/ — Get Case by ID
  Future<LegalCase> getCaseById(String token, int caseId) async {
    try {
      final response = await _dio.get(
        '/cases/$caseId/',
        options: _authOptions(token),
      );
      return LegalCase.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT /api/v1/cases/{id}/ — Update Case
  Future<LegalCase> updateCase(
      String token, int caseId, Map<String, dynamic> data) async {
    try {
      log("LegalCaseService: Updating case $caseId...");
      final response = await _dio.put(
        '/cases/$caseId/',
        data: data,
        options: _authOptions(token),
      );
      return LegalCase.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE /api/v1/cases/{id}/ — Delete Case
  Future<void> deleteCase(String token, int caseId) async {
    try {
      log("LegalCaseService: Deleting case $caseId...");
      await _dio.delete(
        '/cases/$caseId/',
        options: _authOptions(token),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH /api/v1/cases/{id}/status/ — Update Case Status
  Future<LegalCase> updateCaseStatus(
      String token, int caseId, String status) async {
    try {
      log("LegalCaseService: Updating case $caseId status to $status...");
      final response = await _dio.patch(
        '/cases/$caseId/status/',
        data: {'status': status},
        options: _authOptions(token),
      );
      return LegalCase.fromJson(response.data);
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
