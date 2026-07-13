import 'package:dio/dio.dart';
import 'package:bomach_os/src/constants/api_constants.dart';

import '../model/authority_limit_model.dart';

class AuthorityLimitService {
  final Dio _dio;

  static final String _baseUrl = ApiConstants.baseUrl;

  AuthorityLimitService({Dio? dioOverride})
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

  // ─── LIST AUTHORITY LIMITS ────────────────────────────────────────────

  Future<({List<AuthorityLimit> list, int count})> listAuthorityLimits(
    String token, {
    String? roleId,
    String? resource,
    String? action,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };
      if (roleId != null && roleId.isNotEmpty) {
        queryParams['role_id'] = roleId;
      }
      if (resource != null && resource.isNotEmpty) {
        queryParams['resource'] = resource;
      }
      if (action != null && action.isNotEmpty) {
        queryParams['action'] = action;
      }

      final response = await _dio.get(
        '/api/v1/authority-limits/',
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
        list: items.map((json) => AuthorityLimit.fromJson(json)).toList(),
        count: count,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── GET SINGLE AUTHORITY LIMIT ──────────────────────────────────────

  Future<AuthorityLimit> getAuthorityLimit(String token, String id) async {
    try {
      final response = await _dio.get(
        '/api/v1/authority-limits/$id',
        options: _authOptions(token),
      );
      return AuthorityLimit.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── CREATE AUTHORITY LIMIT ──────────────────────────────────────────

  Future<AuthorityLimit> createAuthorityLimit(
    String token,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _dio.post(
        '/api/v1/authority-limits/',
        data: payload,
        options: _authOptions(token),
      );
      return AuthorityLimit.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── UPDATE AUTHORITY LIMIT ──────────────────────────────────────────

  Future<AuthorityLimit> updateAuthorityLimit(
    String token,
    String id,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _dio.put(
        '/api/v1/authority-limits/$id',
        data: payload,
        options: _authOptions(token),
      );
      return AuthorityLimit.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── DELETE AUTHORITY LIMIT ──────────────────────────────────────────

  Future<void> deleteAuthorityLimit(String token, String id) async {
    try {
      await _dio.delete(
        '/api/v1/authority-limits/$id',
        options: _authOptions(token),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── ERROR HANDLER ───────────────────────────────────────────────────

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