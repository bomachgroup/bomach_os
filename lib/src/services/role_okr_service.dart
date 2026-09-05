import 'package:dio/dio.dart';
import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:bomach_os/src/model/role_okr_model.dart';

class RoleOkrService {
  final Dio _dio;

  static final String _baseUrl = ApiConstants.baseUrl;

  RoleOkrService({Dio? dioOverride})
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

  // ─── LIST OKRs ────────────────────────────────────────────────────────

  Future<({List<RoleOkr> list, int count})> listRoleOkrs(
    String token, {
    int? roleId,
    int? quarter,
    int? year,
    String? status,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };
      if (roleId != null) queryParams['role_id'] = roleId;
      if (quarter != null) queryParams['quarter'] = quarter;
      if (year != null) queryParams['year'] = year;
      if (status != null && status.isNotEmpty) queryParams['status'] = status;

      final response = await _dio.get(
        '/api/v1/role-okrs/',
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
        list: items.map((json) => RoleOkr.fromJson(json)).toList(),
        count: count,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── GET SINGLE OKR ───────────────────────────────────────────────────

  Future<RoleOkr> getRoleOkr(String token, int id) async {
    try {
      final response = await _dio.get(
        '/api/v1/role-okrs/$id',
        options: _authOptions(token),
      );
      return RoleOkr.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── CREATE OKR ───────────────────────────────────────────────────────

  Future<RoleOkr> createRoleOkr(
    String token,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _dio.post(
        '/api/v1/role-okrs/',
        data: payload,
        options: _authOptions(token),
      );
      return RoleOkr.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── UPDATE OKR ───────────────────────────────────────────────────────

  Future<RoleOkr> updateRoleOkr(
    String token,
    int id,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _dio.put(
        '/api/v1/role-okrs/$id',
        data: payload,
        options: _authOptions(token),
      );
      return RoleOkr.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── DELETE OKR ───────────────────────────────────────────────────────

  Future<void> deleteRoleOkr(String token, int id) async {
    try {
      await _dio.delete(
        '/api/v1/role-okrs/$id',
        options: _authOptions(token),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── KEY RESULT CRUD ─────────────────────────────────────────────────

  Future<OkrKeyResult> createKeyResult(
    String token,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _dio.post(
        '/api/v1/role-okrs/key-results/',
        data: payload,
        options: _authOptions(token),
      );
      return OkrKeyResult.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<OkrKeyResult> updateKeyResult(
    String token,
    int id,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _dio.put(
        '/api/v1/role-okrs/key-results/$id',
        data: payload,
        options: _authOptions(token),
      );
      return OkrKeyResult.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteKeyResult(String token, int id) async {
    try {
      await _dio.delete(
        '/api/v1/role-okrs/key-results/$id',
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
