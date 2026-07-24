import 'package:dio/dio.dart';
import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:bomach_os/src/model/decision_matrix_model.dart';

class DecisionMatrixService {
  final Dio _dio;
  static final String _baseUrl = ApiConstants.baseUrl;

  DecisionMatrixService({Dio? dioOverride})
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

  Future<List<DecisionMatrixEntry>> getEntries(String token, int roleId) async {
    try {
      final response = await _dio.get(
        '/api/v1/roles/$roleId/decision-matrix',
        options: _authOptions(token),
      );
      final data = response.data;
      final List items = data is Map ? (data['data'] ?? data['items'] ?? []) : data;
      return items.map((j) => DecisionMatrixEntry.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        return [];
      }
      throw _handleError(e);
    }
  }

  Future<DecisionMatrixEntry> createEntry(
      String token, Map<String, dynamic> payload) async {
    try {
      final response = await _dio.post(
        '/api/v1/decision-matrix/',
        data: payload,
        options: _authOptions(token),
      );
      final json = response.data is Map
          ? (response.data['data'] ?? response.data)
          : response.data;
      return DecisionMatrixEntry.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<DecisionMatrixEntry> updateEntry(
      String token, int id, Map<String, dynamic> payload) async {
    try {
      final response = await _dio.put(
        '/api/v1/decision-matrix/$id',
        data: payload,
        options: _authOptions(token),
      );
      final json = response.data is Map
          ? (response.data['data'] ?? response.data)
          : response.data;
      return DecisionMatrixEntry.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteEntry(String token, int id) async {
    try {
      await _dio.delete('/api/v1/decision-matrix/$id', options: _authOptions(token));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      final body = error.response?.data;
      final msg = (body is Map) ? (body['message'] ?? body['detail'] ?? error.message) : error.message;
      return Exception('API Error: ${error.response?.statusCode} - $msg');
    }
    return Exception('Unexpected error: $error');
  }
}
