import 'package:dio/dio.dart';
import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:bomach_os/src/model/role_report_model.dart';

class RoleReportService {
  final Dio _dio;

  static final String _baseUrl = ApiConstants.baseUrl;

  RoleReportService({Dio? dioOverride})
      : _dio = dioOverride ??
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

  Options _authOptions(String token) =>
      Options(headers: {'Authorization': 'Bearer $token'});

  Future<({List<RoleReport> list, int count})> listReports(
    String token, {
    int? roleId,
    String? reportType,
    String? format,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };
      if (roleId != null) queryParams['role_id'] = roleId;
      if (reportType != null) queryParams['report_type'] = reportType;
      if (format != null) queryParams['format'] = format;

      final response = await _dio.get(
        '/api/v1/role-reports/',
        queryParameters: queryParams,
        options: _authOptions(token),
      );

      final data = response.data;
      final List<dynamic> items =
          (data is Map && data.containsKey('items')) ? data['items'] : data;
      final int count = (data is Map && data.containsKey('count'))
          ? data['count']
          : items.length;

      return (
        list: items.map((json) => RoleReport.fromJson(json)).toList(),
        count: count,
      );
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        return (list: <RoleReport>[], count: 0);
      }
      throw _handleError(e);
    }
  }

  Future<RoleReport> createReport(
    String token,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _dio.post(
        '/api/v1/role-reports/',
        data: payload,
        options: _authOptions(token),
      );
      return RoleReport.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<RoleReport> updateReport(
    String token,
    int id,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _dio.put(
        '/api/v1/role-reports/$id',
        data: payload,
        options: _authOptions(token),
      );
      return RoleReport.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteReport(String token, int id) async {
    try {
      await _dio.delete(
        '/api/v1/role-reports/$id',
        options: _authOptions(token),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      final body = error.response?.data;
      final errorMessage = (body is Map) ? (body['message'] ?? body['detail'] ?? error.message) : error.message;
      return Exception(
          'API Error: ${error.response?.statusCode} - $errorMessage');
    }
    return Exception('Unexpected error: $error');
  }
}
