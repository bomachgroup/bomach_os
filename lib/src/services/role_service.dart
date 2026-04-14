import 'package:dio/dio.dart';
import 'package:bms_front_end/src/constants/api_constants.dart';

import '../model/role_model.dart';

class RoleService {
  final Dio _dio;

  static final String _baseUrl = ApiConstants.baseUrl;

  RoleService({Dio? dioOverride})
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

  // ─── LIST ROLES ────────────────────────────────────────────────────

  Future<({List<Role> list, int count})> listRoles(
    String token, {
    String? search,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/roles/',
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          'limit': limit,
          'offset': offset,
        },
        options: _authOptions(token),
      );

      final data = response.data;
      final List<dynamic> items =
          (data is Map && data.containsKey('items')) ? data['items'] : data;
      final int count = (data is Map && data.containsKey('count'))
          ? data['count']
          : items.length;

      return (
        list: items.map((json) => Role.fromJson(json)).toList(),
        count: count,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── CREATE ROLE ───────────────────────────────────────────────────

  Future<Role> createRole(String token, Map<String, dynamic> payload) async {
    try {
      final response = await _dio.post(
        '/api/v1/roles/',
        data: payload,
        options: _authOptions(token),
      );
      return Role.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── UPDATE ROLE ───────────────────────────────────────────────────

  Future<Role> updateRole(
      String token, int roleId, Map<String, dynamic> payload) async {
    try {
      final response = await _dio.put(
        '/api/v1/roles/$roleId',
        data: payload,
        options: _authOptions(token),
      );
      return Role.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── DELETE ROLE ───────────────────────────────────────────────────

  Future<void> deleteRole(String token, int roleId) async {
    try {
      await _dio.delete(
        '/api/v1/roles/$roleId',
        options: _authOptions(token),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── PERMISSIONS MAP ───────────────────────────────────────────────

  Future<Map<String, List<String>>> getPermissionsMap(String token) async {
    try {
      final response = await _dio.get(
        '/api/v1/roles/permissions-map',
        options: _authOptions(token),
      );

      final data = response.data;
      final Map<String, dynamic> rawMap =
          (data is Map && data.containsKey('permissions_map'))
              ? data['permissions_map']
              : data;

      final result = <String, List<String>>{};
      rawMap.forEach((key, value) {
        if (value is Iterable) {
          result[key] = List<String>.from(value);
        }
      });
      return result;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── ERROR HANDLER ─────────────────────────────────────────────────

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      final errorMessage = error.response?.data?['message'] ??
          error.response?.data?['detail'] ??
          error.message;
      return Exception(
          'API Error: ${error.response?.statusCode} - $errorMessage');
    }
    return Exception('Unexpected error: $error');
  }
}
