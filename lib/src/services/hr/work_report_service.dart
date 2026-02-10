import 'package:dio/dio.dart';

import '../../../pages/hr/models/work_report_model.dart';

class WorkReportService {
  final Dio _dio;

  static const String _baseUrl = 'https://bomachhr.bgbot.app/api/v1';

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
          if (mood != null) 'mood': mood,
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
        data: report.toJson(),
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
        data: report.toJson(),
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

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      final errorMessage = error.response?.data?['message'] ?? error.message;
      return Exception(
          'API Error: ${error.response?.statusCode} - $errorMessage');
    }
    return Exception('Unexpected error: $error');
  }
}
