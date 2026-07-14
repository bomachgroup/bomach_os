import 'package:dio/dio.dart';
import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:bomach_os/src/model/role_kpi_model.dart';

class RoleKpiService {
  final Dio _dio;

  static final String _baseUrl = ApiConstants.baseUrl;

  RoleKpiService({Dio? dioOverride})
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

  // ─── LIST KPIs ────────────────────────────────────────────────────────

  Future<({List<RoleKpi> list, int count})> listRoleKpis(
    String token, {
    required int roleId,
    String? category,
    bool? isActive,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (isActive != null) queryParams['is_active'] = isActive;

      final response = await _dio.get(
        '/api/v1/roles/$roleId/kpis',
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
        list: items.map((json) => RoleKpi.fromJson(json)).toList(),
        count: count,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── GET SINGLE KPI ───────────────────────────────────────────────────

  Future<RoleKpi> getRoleKpi(String token, int roleId, int kpiId) async {
    try {
      final response = await _dio.get(
        '/api/v1/roles/$roleId/kpis/$kpiId',
        options: _authOptions(token),
      );
      return RoleKpi.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── CREATE KPI ───────────────────────────────────────────────────────

  Future<RoleKpi> createRoleKpi(
    String token,
    int roleId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _dio.post(
        '/api/v1/roles/$roleId/kpis',
        data: payload,
        options: _authOptions(token),
      );
      return RoleKpi.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── UPDATE KPI ───────────────────────────────────────────────────────

  Future<RoleKpi> updateRoleKpi(
    String token,
    int roleId,
    int kpiId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _dio.put(
        '/api/v1/roles/$roleId/kpis/$kpiId',
        data: payload,
        options: _authOptions(token),
      );
      return RoleKpi.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── DELETE KPI ───────────────────────────────────────────────────────

  Future<void> deleteRoleKpi(String token, int roleId, int kpiId) async {
    try {
      await _dio.delete(
        '/api/v1/roles/$roleId/kpis/$kpiId',
        options: _authOptions(token),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── ERROR HANDLER ────────────────────────────────────────────────────

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
