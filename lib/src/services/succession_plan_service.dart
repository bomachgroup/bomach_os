import 'package:dio/dio.dart';
import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:bomach_os/src/model/succession_plan_model.dart';

class SuccessionPlanService {
  final Dio _dio;
  static final String _baseUrl = ApiConstants.baseUrl;

  SuccessionPlanService({Dio? dioOverride})
      : _dio = dioOverride ?? Dio(BaseOptions(
          baseUrl: _baseUrl, connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        )) { _dio.interceptors.add(LogInterceptor(request: true, requestHeader: true, responseBody: true, responseHeader: false)); }

  Options _authOptions(String token) => Options(headers: {'Authorization': 'Bearer $token'});

  Future<List<SuccessionPlan>> getPlans(String token, int roleId) async {
    try {
      final res = await _dio.get('/api/v1/roles/$roleId/succession-plans', options: _authOptions(token));
      final data = res.data; final List items = data is Map ? (data['data'] ?? data['items'] ?? []) : data;
      return items.map((j) => SuccessionPlan.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        return [];
      }
      throw _handleError(e);
    }
  }

  Future<SuccessionPlan> createPlan(String token, Map<String, dynamic> payload) async {
    try {
      final res = await _dio.post('/api/v1/succession-plans/', data: payload, options: _authOptions(token));
      final json = res.data is Map ? (res.data['data'] ?? res.data) : res.data;
      return SuccessionPlan.fromJson(json as Map<String, dynamic>);
    } catch (e) { throw _handleError(e); }
  }

  Future<SuccessionPlan> updatePlan(String token, int id, Map<String, dynamic> payload) async {
    try {
      final res = await _dio.put('/api/v1/succession-plans/$id', data: payload, options: _authOptions(token));
      final json = res.data is Map ? (res.data['data'] ?? res.data) : res.data;
      return SuccessionPlan.fromJson(json as Map<String, dynamic>);
    } catch (e) { throw _handleError(e); }
  }

  Future<void> deletePlan(String token, int id) async {
    try { await _dio.delete('/api/v1/succession-plans/$id', options: _authOptions(token)); }
    catch (e) { throw _handleError(e); }
  }

  Exception _handleError(dynamic e) {
    if (e is DioException) {
      final msg = (e.response?.data is Map) ? (e.response?.data?['message'] ?? e.response?.data?['detail'] ?? e.message) : e.message;
      return Exception('API Error: ${e.response?.statusCode} - $msg');
    }
    return Exception('Unexpected error: $e');
  }
}
