import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:dio/dio.dart';

class EmployeePerformancePlanApiException implements Exception {
  final int? statusCode;
  final String message;

  const EmployeePerformancePlanApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class EmployeePerformancePlanService {
  final Dio _dio;

  EmployeePerformancePlanService({Dio? dioOverride})
      : _dio = dioOverride ??
            Dio(BaseOptions(
              baseUrl: ApiConstants.baseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              headers: const {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            ));

  Options _auth(String token) =>
      Options(headers: {'Authorization': 'Bearer $token'});

  Future<Map<String, dynamic>> getMine(
    String token, {
    required DateTime periodStart,
    required DateTime periodEnd,
  }) =>
      _get(
        token,
        '/api/v1/employees/me/performance-plan',
        periodStart,
        periodEnd,
      );

  Future<Map<String, dynamic>> getEmployee(
    String token,
    int userId, {
    required DateTime periodStart,
    required DateTime periodEnd,
  }) =>
      _get(
        token,
        '/api/v1/employees/$userId/performance-plan',
        periodStart,
        periodEnd,
      );

  Future<Map<String, dynamic>> _get(
    String token,
    String path,
    DateTime periodStart,
    DateTime periodEnd,
  ) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: {
          'period_start': _date(periodStart),
          'period_end': _date(periodEnd),
        },
        options: _auth(token),
      );
      return Map<String, dynamic>.from(response.data as Map);
    } catch (error) {
      throw _message(error);
    }
  }

  Future<Map<String, dynamic>> updateEmployee(
    String token,
    int userId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _dio.put(
        '/api/v1/employees/$userId/performance-plan',
        data: payload,
        options: _auth(token),
      );
      return Map<String, dynamic>.from(response.data as Map);
    } catch (error) {
      throw _message(error);
    }
  }

  Future<Map<String, dynamic>> previewRefresh(
    String token,
    int userId, {
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/employees/$userId/performance-plan/refresh-preview',
        queryParameters: {
          'period_start': _date(periodStart),
          'period_end': _date(periodEnd),
        },
        options: _auth(token),
      );
      return Map<String, dynamic>.from(response.data as Map);
    } catch (error) {
      throw _message(error);
    }
  }

  Future<Map<String, dynamic>> applyRefresh(
    String token,
    int userId, {
    required DateTime periodStart,
    required DateTime periodEnd,
    required String reason,
    required String previewToken,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/employees/$userId/performance-plan/refresh',
        data: {
          'period_start': _date(periodStart),
          'period_end': _date(periodEnd),
          'reason': reason,
          'preview_token': previewToken,
        },
        options: _auth(token),
      );
      return Map<String, dynamic>.from(response.data as Map);
    } catch (error) {
      throw _message(error);
    }
  }

  Future<List<Map<String, dynamic>>> history(String token, int userId) async {
    try {
      final response = await _dio.get(
        '/api/v1/employees/$userId/performance-plan/history',
        options: _auth(token),
      );
      return (response.data as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    } catch (error) {
      throw _message(error);
    }
  }

  static String _date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

  EmployeePerformancePlanApiException _message(Object error) {
    if (error is DioException) {
      final body = error.response?.data;
      final detail = body is Map
          ? (body['detail'] ?? body['message'] ?? error.message)
          : error.message;
      return EmployeePerformancePlanApiException(
        detail?.toString() ?? 'The request could not be completed.',
        statusCode: error.response?.statusCode,
      );
    }
    return EmployeePerformancePlanApiException(error.toString());
  }
}
