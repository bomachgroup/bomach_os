import 'package:dio/dio.dart';
import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:bomach_os/src/model/role_risk_profile_model.dart';

class RoleRiskService {
  final Dio _dio;
  static final String _baseUrl = ApiConstants.baseUrl;

  RoleRiskService({Dio? dioOverride})
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

  Future<List<RoleRiskProfile>> getRiskProfiles(String token, int roleId) async {
    try {
      final response = await _dio.get(
        '/api/v1/roles/$roleId/risk-profiles',
        options: _authOptions(token),
      );
      final data = response.data;
      final List items = data is Map ? (data['data'] ?? data['items'] ?? []) : data;
      return items.map((j) => RoleRiskProfile.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<RoleRiskProfile> createRiskProfile(
      String token, Map<String, dynamic> payload) async {
    try {
      final response = await _dio.post(
        '/api/v1/risk-profiles/',
        data: payload,
        options: _authOptions(token),
      );
      final json = response.data is Map
          ? (response.data['data'] ?? response.data)
          : response.data;
      return RoleRiskProfile.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<RoleRiskProfile> updateRiskProfile(
      String token, int id, Map<String, dynamic> payload) async {
    try {
      final response = await _dio.put(
        '/api/v1/risk-profiles/$id',
        data: payload,
        options: _authOptions(token),
      );
      final json = response.data is Map
          ? (response.data['data'] ?? response.data)
          : response.data;
      return RoleRiskProfile.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteRiskProfile(String token, int id) async {
    try {
      await _dio.delete('/api/v1/risk-profiles/$id', options: _authOptions(token));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<({int total, int compliant, int atRisk, int overdue})> getComplianceSummary(
      String token) async {
    try {
      final response = await _dio.get(
        '/api/v1/risk-profiles/summary',
        options: _authOptions(token),
      );
      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      return (
        total: (data['total'] ?? 0) as int,
        compliant: (data['compliant'] ?? 0) as int,
        atRisk: (data['at_risk'] ?? 0) as int,
        overdue: (data['overdue'] ?? 0) as int,
      );
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
