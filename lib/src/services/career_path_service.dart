import 'package:dio/dio.dart';
import 'package:bomach_os/src/constants/api_constants.dart';

import '../model/career_path_model.dart';

class CareerPathService {
  final Dio _dio;

  static final String _baseUrl = ApiConstants.baseUrl;

  CareerPathService({Dio? dioOverride})
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

  Options _authOptions(String token) {
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<List<CareerPathStep>> getSteps(String token, int roleId) async {
    try {
      final response = await _dio.get(
        '/api/v1/roles/$roleId/career-path',
        options: _authOptions(token),
      );
      final data = response.data;
      final List items = data is Map ? (data['data'] ?? data['items'] ?? []) : data;
      return items.map((j) => CareerPathStep.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<CareerPathStep> createStep(String token, int roleId, Map<String, dynamic> payload) async {
    try {
      final response = await _dio.post(
        '/api/v1/roles/$roleId/career-path/',
        data: payload,
        options: _authOptions(token),
      );
      final data = response.data;
      final json = data is Map ? (data['data'] ?? data) : data;
      return CareerPathStep.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<CareerPathStep> updateStep(
      String token, int roleId, int pathId, Map<String, dynamic> payload) async {
    try {
      final response = await _dio.put(
        '/api/v1/roles/$roleId/career-path/$pathId',
        data: payload,
        options: _authOptions(token),
      );
      final data = response.data;
      final json = data is Map ? (data['data'] ?? data) : data;
      return CareerPathStep.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteStep(String token, int roleId, int pathId) async {
    try {
      await _dio.delete(
        '/api/v1/roles/$roleId/career-path/$pathId',
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
      return Exception('API Error: ${error.response?.statusCode} - $errorMessage');
    }
    return Exception('Unexpected error: $error');
  }
}
