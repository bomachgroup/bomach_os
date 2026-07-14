import 'package:dio/dio.dart';
import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:bomach_os/src/model/stakeholder_model.dart';

class StakeholderService {
  final Dio _dio;
  static final String _baseUrl = ApiConstants.baseUrl;

  StakeholderService({Dio? dioOverride})
      : _dio = dioOverride ?? Dio(BaseOptions(
          baseUrl: _baseUrl, connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        )) { _dio.interceptors.add(LogInterceptor(request: true, requestHeader: true, responseBody: true, responseHeader: false)); }

  Options _authOptions(String token) => Options(headers: {'Authorization': 'Bearer $token'});

  Future<List<RoleStakeholder>> getStakeholders(String token, int roleId) async {
    try {
      final res = await _dio.get('/api/v1/roles/$roleId/stakeholders', options: _authOptions(token));
      final data = res.data; final List items = data is Map ? (data['data'] ?? data['items'] ?? []) : data;
      return items.map((j) => RoleStakeholder.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) { throw _handleError(e); }
  }

  Future<RoleStakeholder> createStakeholder(String token, Map<String, dynamic> payload) async {
    try {
      final res = await _dio.post('/api/v1/stakeholders/', data: payload, options: _authOptions(token));
      final json = res.data is Map ? (res.data['data'] ?? res.data) : res.data;
      return RoleStakeholder.fromJson(json as Map<String, dynamic>);
    } catch (e) { throw _handleError(e); }
  }

  Future<RoleStakeholder> updateStakeholder(String token, int id, Map<String, dynamic> payload) async {
    try {
      final res = await _dio.put('/api/v1/stakeholders/$id', data: payload, options: _authOptions(token));
      final json = res.data is Map ? (res.data['data'] ?? res.data) : res.data;
      return RoleStakeholder.fromJson(json as Map<String, dynamic>);
    } catch (e) { throw _handleError(e); }
  }

  Future<void> deleteStakeholder(String token, int id) async {
    try { await _dio.delete('/api/v1/stakeholders/$id', options: _authOptions(token)); }
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
