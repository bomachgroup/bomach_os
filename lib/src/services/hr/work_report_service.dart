import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:dio/dio.dart';

import '../../../pages/hr/models/work_report_model.dart';

class WorkReportService {
  final Dio _dio;

  static final String _baseUrl = '${ApiConstants.baseUrl}/api/v1';

  WorkReportService({
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

  Future<List<WorkReport>> getWorkReports(
    String token, {
    String? search,
    String? employeeId,
    String? status,
    String? mood,
    String? dateFrom,
    String? dateTo,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/work-reports/',
        queryParameters: {
          if (search != null) 'search': search,
          if (employeeId != null) 'employee_id': employeeId,
          if (status != null) 'status': status,
          // `mood` is retained for source compatibility, but is not part of
          // the published WorkReport filter contract.
          if (dateFrom != null) 'date_from': dateFrom,
          if (dateTo != null) 'date_to': dateTo,
          'limit': limit,
          'offset': offset,
        },
        options: _authOptions(token),
      );

      final data = response.data;
      final List<dynamic> list =
          (data is Map && data.containsKey('items')) ? data['items'] : data;

      return list.map((json) => WorkReport.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<WorkReport> createWorkReport(String token, WorkReport report) async {
    try {
      final response = await _dio.post(
        '/work-reports/',
        data: report.toCreateJson(),
        options: _authOptions(token),
      );
      return WorkReport.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<WorkReport> getWorkReportById(String token, String reportId) async {
    try {
      final response = await _dio.get(
        '/work-reports/$reportId',
        options: _authOptions(token),
      );
      return WorkReport.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<WorkReport> updateWorkReport(
      String token, String reportId, WorkReport report) async {
    try {
      final response = await _dio.put(
        '/work-reports/$reportId',
        data: report.toUpdateJson(),
        options: _authOptions(token),
      );
      return WorkReport.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteWorkReport(String token, String reportId) async {
    try {
      await _dio.delete(
        '/work-reports/$reportId',
        options: _authOptions(token),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<WorkReport> approveWorkReport(
    String token,
    String reportId, {
    int? rating,
    String? feedback,
  }) async {
    try {
      final response = await _dio.post(
        '/work-reports/$reportId/approve',
        data: {
          if (rating != null) 'rating': rating,
          if (feedback != null && feedback.isNotEmpty) 'feedback': feedback,
        },
        options: _authOptions(token),
      );
      return WorkReport.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<WorkReport> rejectWorkReport(
    String token,
    String reportId, {
    required String feedback,
  }) async {
    if (feedback.trim().isEmpty) {
      throw Exception('Rejection reason is required');
    }
    try {
      final response = await _dio.post(
        '/work-reports/$reportId/reject',
        data: {'feedback': feedback.trim()},
        options: _authOptions(token),
      );
      return WorkReport.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      String? errorMessage;
      final data = error.response?.data;
      if (data is Map) {
        errorMessage = data['message'] ?? data['detail']?.toString();
      } else if (data is String && data.isNotEmpty) {
        errorMessage = data;
      }
      errorMessage ??= error.message;
      return Exception(
          'API Error: ${error.response?.statusCode} - $errorMessage');
    }
    return Exception('Unexpected error: $error');
  }
}
