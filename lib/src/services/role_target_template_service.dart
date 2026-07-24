import 'package:dio/dio.dart';
import 'package:bomach_os/src/constants/api_constants.dart';
import '../model/role_target_template_model.dart';

class RoleTargetTemplateService {
  final Dio _dio;

  RoleTargetTemplateService({Dio? dioOverride})
      : _dio = dioOverride ??
            Dio(BaseOptions(
              baseUrl: ApiConstants.baseUrl,
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

  Options _auth(String token) =>
      Options(headers: {'Authorization': 'Bearer $token'});

  Future<({List<RoleTargetTemplate> list, int count})> list(
    String token,
    int roleId, {
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/roles/$roleId/target-templates',
        queryParameters: {'limit': limit, 'offset': offset},
        options: _auth(token),
      );
      final data = response.data;
      final List items =
          (data is Map && data.containsKey('items')) ? data['items'] : (data is List ? data : []);
      final int count =
          (data is Map && data.containsKey('count')) ? data['count'] : items.length;
      return (
        list: items.map((j) => RoleTargetTemplate.fromJson(j as Map<String, dynamic>)).toList(),
        count: count,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<RoleTargetTemplate> create(
    String token,
    int roleId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _dio.post(
        '/api/v1/roles/$roleId/target-templates',
        data: payload,
        options: _auth(token),
      );
      final data = response.data;
      final json = data is Map ? (data['data'] ?? data) : data;
      return RoleTargetTemplate.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<RoleTargetTemplate> update(
    String token,
    int roleId,
    int templateId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _dio.patch(
        '/api/v1/roles/$roleId/target-templates/$templateId',
        data: payload,
        options: _auth(token),
      );
      final data = response.data;
      final json = data is Map ? (data['data'] ?? data) : data;
      return RoleTargetTemplate.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> delete(String token, int roleId, int templateId) async {
    try {
      await _dio.delete(
        '/api/v1/roles/$roleId/target-templates/$templateId',
        options: _auth(token),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      final body = error.response?.data;
      final msg = (body is Map)
          ? (body['message'] ?? body['detail'] ?? error.message)
          : error.message;
      return Exception('API Error: ${error.response?.statusCode} - $msg');
    }
    return Exception('Unexpected error: $error');
  }
}
