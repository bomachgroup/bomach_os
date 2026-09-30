import 'dart:developer';

import 'package:bomach_os/pages/operations/models/engineering_site_report_model.dart';
import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:dio/dio.dart';

class EngineeringSiteReportService {
  EngineeringSiteReportService({Dio? dioOverride})
      : _dio = dioOverride ??
            Dio(BaseOptions(
              baseUrl: ApiConstants.operationsBaseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              headers: const {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            ));

  final Dio _dio;
  static const _path = '/api/v1/engineering-site-reports';

  Options _auth(String token) =>
      Options(headers: {'Authorization': 'Bearer $token'});

  Future<({List<EngineeringSiteReport> items, int count})> listReports({
    required String accessToken,
    String? status,
    int? employeeId,
    int? worksiteId,
    int? projectId,
    String? dateFrom,
    String? dateTo,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '$_path/',
        queryParameters: {
          if (status != null && status != 'all') 'status': status,
          if (employeeId != null) 'employee_id': employeeId,
          if (worksiteId != null) 'worksite_id': worksiteId,
          if (projectId != null) 'project_id': projectId,
          if (dateFrom != null && dateFrom.isNotEmpty) 'date_from': dateFrom,
          if (dateTo != null && dateTo.isNotEmpty) 'date_to': dateTo,
          'limit': limit,
          'offset': offset,
        },
        options: _auth(accessToken),
      );
      return _parsePage(response.data, EngineeringSiteReport.fromJson);
    } on DioException catch (error) {
      throw _handleError(error);
    }
  }

  Future<EngineeringSiteReport> getReport({
    required String accessToken,
    required int reportId,
  }) async {
    try {
      final response = await _dio.get(
        '$_path/$reportId',
        options: _auth(accessToken),
      );
      return EngineeringSiteReport.fromJson(_map(response.data));
    } on DioException catch (error) {
      throw _handleError(error);
    }
  }

  Future<EngineeringSiteReport> createReport({
    required String accessToken,
    required EngineeringSiteReport report,
  }) async {
    try {
      final response = await _dio.post(
        '$_path/',
        data: report.toJson(),
        options: _auth(accessToken),
      );
      return EngineeringSiteReport.fromJson(_map(response.data));
    } on DioException catch (error) {
      throw _handleError(error);
    }
  }

  Future<EngineeringSiteReport> updateReport({
    required String accessToken,
    required int reportId,
    required EngineeringSiteReport report,
  }) async {
    try {
      final response = await _dio.put(
        '$_path/$reportId',
        data: report.toJson(),
        options: _auth(accessToken),
      );
      return EngineeringSiteReport.fromJson(_map(response.data));
    } on DioException catch (error) {
      throw _handleError(error);
    }
  }

  Future<void> deleteReport({
    required String accessToken,
    required int reportId,
  }) async {
    try {
      await _dio.delete('$_path/$reportId', options: _auth(accessToken));
    } on DioException catch (error) {
      throw _handleError(error);
    }
  }

  Future<EngineeringSiteReport> submitReport({
    required String accessToken,
    required int reportId,
  }) async {
    try {
      final response = await _dio.post(
        '$_path/$reportId/submit',
        data: const <String, dynamic>{},
        options: _auth(accessToken),
      );
      return EngineeringSiteReport.fromJson(_map(response.data));
    } on DioException catch (error) {
      throw _handleError(error);
    }
  }

  Future<EngineeringSiteReport> approveReport({
    required String accessToken,
    required int reportId,
    int? rating,
  }) async {
    try {
      final response = await _dio.post(
        '$_path/$reportId/approve',
        data: {if (rating != null) 'rating': rating},
        options: _auth(accessToken),
      );
      return EngineeringSiteReport.fromJson(_map(response.data));
    } on DioException catch (error) {
      throw _handleError(error);
    }
  }

  Future<EngineeringSiteReport> rejectReport({
    required String accessToken,
    required int reportId,
    required String feedback,
  }) async {
    try {
      final response = await _dio.post(
        '$_path/$reportId/reject',
        data: {'feedback': feedback.trim()},
        options: _auth(accessToken),
      );
      return EngineeringSiteReport.fromJson(_map(response.data));
    } on DioException catch (error) {
      throw _handleError(error);
    }
  }

  Future<({List<UnifiedReportSummary> items, int count})> listUnifiedReports({
    required String accessToken,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/reports/',
        queryParameters: {'limit': limit, 'offset': offset},
        options: _auth(accessToken),
      );
      return _parsePage(response.data, UnifiedReportSummary.fromJson);
    } on DioException catch (error) {
      throw _handleError(error);
    }
  }

  static ({List<T> items, int count}) _parsePage<T>(
    dynamic data,
    T Function(Map<String, dynamic>) parse,
  ) {
    if (data is List) {
      return (
        items: data
            .whereType<Map>()
            .map((row) => parse(Map<String, dynamic>.from(row)))
            .toList(),
        count: data.length,
      );
    }
    final json = _map(data);
    final rows = json['items'] is List ? json['items'] as List : const [];
    return (
      items: rows
          .whereType<Map>()
          .map((row) => parse(Map<String, dynamic>.from(row)))
          .toList(),
      count: int.tryParse(
            (json['count'] ?? json['total'] ?? rows.length).toString(),
          ) ??
          rows.length,
    );
  }

  static Map<String, dynamic> _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

  Exception _handleError(DioException error) {
    final body = error.response?.data;
    var message = error.message ?? 'Unexpected error';
    if (body is Map) {
      message = (body['detail'] ?? body['message'] ?? body['errors'] ?? message)
          .toString();
    } else if (body is String && body.isNotEmpty) {
      message = body;
    }
    log('Engineering site report API error: ${error.response?.statusCode} $message');
    return Exception(
      'API Error: ${error.response?.statusCode ?? 'connection'} - $message',
    );
  }
}
