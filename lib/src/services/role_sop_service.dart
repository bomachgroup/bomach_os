import 'package:dio/dio.dart';
import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:bomach_os/src/model/role_sop_model.dart';

class RoleSopService {
  final Dio _dio;

  static final String _baseUrl = ApiConstants.baseUrl;

  RoleSopService({Dio? dioOverride})
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

  Future<({List<RoleSop> list, int count})> listSops(
    String token, {
    required int roleId,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };

      final response = await _dio.get(
        '/api/v1/roles/$roleId/sops',
        queryParameters: queryParams,
        options: _authOptions(token),
      );

      final data = response.data;
      final List<dynamic> items =
          (data is Map && data.containsKey('items')) ? data['items'] : (data is List ? data : []);
      final int count = (data is Map && data.containsKey('count'))
          ? data['count']
          : items.length;

      return (
        list: items.map((json) => RoleSop.fromJson(json as Map<String, dynamic>)).toList(),
        count: count,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<RoleSop> attachSopToRole(
    String token,
    int roleId,
    int sopId, {
    bool isActive = true,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/roles/$roleId/sops',
        data: {
          'sop_id': sopId,
          'is_active': isActive,
        },
        options: _authOptions(token),
      );
      return RoleSop.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<RoleSop> updateRoleSop(
    String token,
    int roleId,
    int roleSopId, {
    int? sopId,
    bool? isActive,
  }) async {
    try {
      final payload = <String, dynamic>{};
      if (sopId != null) payload['sop_id'] = sopId;
      if (isActive != null) payload['is_active'] = isActive;

      final response = await _dio.patch(
        '/api/v1/roles/$roleId/sops/$roleSopId',
        data: payload,
        options: _authOptions(token),
      );
      return RoleSop.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteRoleSop(String token, int roleId, int roleSopId) async {
    try {
      await _dio.delete(
        '/api/v1/roles/$roleId/sops/$roleSopId',
        options: _authOptions(token),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Fetches global/department SOP list for user selection when linking to a role
  Future<List<Map<String, dynamic>>> fetchAvailableSops(String token, {int? deptId}) async {
    try {
      final endpoint = deptId != null
          ? '/api/v1/sop/departments/$deptId/sops'
          : '/api/v1/sop/departments/1/sops'; // fallback default dept
      final response = await _dio.get(
        endpoint,
        options: _authOptions(token),
      );
      final data = response.data;
      final List items = (data is Map && data.containsKey('items'))
          ? data['items']
          : (data is List ? data : []);
      return items.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

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
