import 'package:dio/dio.dart';
import 'package:bomach_os/src/constants/api_constants.dart';

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

  Future<Role> getRoleById(String token, int roleId) async {
    try {
      final response = await _dio.get(
        '/api/v1/roles/$roleId',
        options: _authOptions(token),
      );
      if (response.data is! Map) {
        throw const FormatException('Role response is not an object');
      }
      return Role.fromJson(Map<String, dynamic>.from(response.data as Map));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getRoleDescription(
      String token, int roleId) async {
    try {
      final response = await _dio.get(
        '/api/v1/roles/$roleId/description',
        options: _authOptions(token),
      );
      if (response.data is! Map) {
        throw const FormatException('Role description response is not an object');
      }
      return Map<String, dynamic>.from(response.data as Map);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createRoleDescription(
    String token,
    int roleId, {
    required String purpose,
    required String jobDescription,
    required String responsibilities,
  }) async {
    return _saveRoleDescription(
      token,
      roleId,
      method: 'post',
      purpose: purpose,
      jobDescription: jobDescription,
      responsibilities: responsibilities,
    );
  }

  Future<Map<String, dynamic>> updateRoleDescription(
    String token,
    int roleId, {
    required String purpose,
    required String jobDescription,
    required String responsibilities,
  }) async {
    return _saveRoleDescription(
      token,
      roleId,
      method: 'patch',
      purpose: purpose,
      jobDescription: jobDescription,
      responsibilities: responsibilities,
    );
  }

  /// Updates an existing description and creates it when the role has no
  /// description record yet. A missing description is the only GET failure
  /// treated as a create; all other failures remain visible to the caller.
  Future<Map<String, dynamic>> saveRoleDescription(
    String token,
    int roleId, {
    required String purpose,
    required String jobDescription,
    required String responsibilities,
  }) async {
    try {
      await _dio.get(
        '/api/v1/roles/$roleId/description',
        options: _authOptions(token),
      );
    } on DioException catch (error) {
      if (error.response?.statusCode != 404) {
        throw _handleError(error);
      }
      return createRoleDescription(
        token,
        roleId,
        purpose: purpose,
        jobDescription: jobDescription,
        responsibilities: responsibilities,
      );
    }

    return updateRoleDescription(
      token,
      roleId,
      purpose: purpose,
      jobDescription: jobDescription,
      responsibilities: responsibilities,
    );
  }

  Future<Map<String, dynamic>> _saveRoleDescription(
    String token,
    int roleId, {
    required String method,
    required String purpose,
    required String jobDescription,
    required String responsibilities,
  }) async {
    try {
      final payload = {
        'purpose': purpose,
        'job_description': jobDescription,
        'responsibilities': responsibilities,
      };
      final response = method == 'post'
          ? await _dio.post('/api/v1/roles/$roleId/description',
              data: payload, options: _authOptions(token))
          : await _dio.patch('/api/v1/roles/$roleId/description',
              data: payload, options: _authOptions(token));
      if (response.data is! Map) {
        throw const FormatException('Role description response is not an object');
      }
      return Map<String, dynamic>.from(response.data as Map);
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

  /// Returns the reporting relationships for a role from the dedicated
  /// reporting endpoint. The response is intentionally kept as a map because
  /// the API exposes nested role objects whose shape may evolve independently
  /// from the role list response.
  Future<Map<String, dynamic>> getReportingTree(String token, int roleId) async {
    try {
      final response = await _dio.get(
        '/api/v1/roles/$roleId/reporting-tree',
        options: _authOptions(token),
      );
      if (response.data is! Map) {
        throw const FormatException('Reporting tree response is not an object');
      }
      return Map<String, dynamic>.from(response.data as Map);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Returns the reporting lines for a role from the dedicated API endpoint.
  Future<Map<String, dynamic>> getReportingLines(String token, int roleId) async {
    try {
      final response = await _dio.get(
        '/api/v1/roles/$roleId/reporting-lines',
        options: _authOptions(token),
      );
      if (response.data is! Map) {
        throw const FormatException('Reporting lines response is not an object');
      }
      return Map<String, dynamic>.from(response.data as Map);
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
