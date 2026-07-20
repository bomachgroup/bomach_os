import 'package:dio/dio.dart';
import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:bomach_os/src/model/kpi_metric_model.dart';

class KpiMetricService {
  final Dio _dio;
  static final String _baseUrl = ApiConstants.baseUrl;

  KpiMetricService({Dio? dioOverride})
      : _dio = dioOverride ??
            Dio(BaseOptions(
              baseUrl: _baseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
            )) {
    _dio.interceptors.add(LogInterceptor(
      request: true, requestHeader: true, responseBody: true, responseHeader: false,
    ));
  }

  Options _authOptions(String token) =>
      Options(headers: {'Authorization': 'Bearer $token'});

  Future<({List<KPIMetric> list, int count})> listMetrics(
    String token, {
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/kpis/metrics/',
        queryParameters: {'limit': limit, 'offset': offset},
        options: _authOptions(token),
      );
      final data = response.data;
      final List<dynamic> items =
          (data is Map && data.containsKey('items')) ? data['items'] : data;
      final int count = (data is Map && data.containsKey('count'))
          ? data['count']
          : items.length;
      return (
        list: items.map((json) => KPIMetric.fromJson(json)).toList(),
        count: count,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<KPIMetric> createMetric(
    String token, {
    required String name,
    String description = '',
    String unit = 'percentage',
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/kpis/metrics/',
        data: {'name': name, 'description': description, 'unit': unit},
        options: _authOptions(token),
      );
      return KPIMetric.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      final body = error.response?.data;
      final errorMessage = (body is Map) ? (body['message'] ?? body['detail'] ?? error.message) : error.message;
      return Exception('API Error: ${error.response?.statusCode} - $errorMessage');
    }
    return Exception('Unexpected error: $error');
  }
}
