import 'package:dio/dio.dart';
import 'package:bms_front_end/src/constants/api_constants.dart';

import '../../pages/dashboad/models/dashboard_models.dart';

class DashboardService {
  final Dio _dio;

  static const String _baseUrl = '${ApiConstants.baseUrl}/api/v1';

  DashboardService({
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

  Future<DashboardSummary> getSummary(String token) async {
    try {
      final response = await _dio.get(
        '/dashboard/summary',
        options: _authOptions(token),
      );
      return DashboardSummary.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<PerformanceCard> getPerformanceCard(String token) async {
    try {
      final response = await _dio.get(
        '/dashboard/performance-card',
        options: _authOptions(token),
      );
      return PerformanceCard.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<DashboardOverview> getOverview(String token) async {
    try {
      final response = await _dio.get(
        '/dashboard/overview',
        options: _authOptions(token),
      );
      return DashboardOverview.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<EmployeeDashboardStats> getStats(String token) async {
    try {
      final response = await _dio.get(
        '/dashboard/stats',
        options: _authOptions(token),
      );
      return EmployeeDashboardStats.fromJson(response.data);
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
