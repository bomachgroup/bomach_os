import 'package:dio/dio.dart';
import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:bomach_os/src/model/role_task_template_model.dart';

class RoleTaskTemplateService {
  final Dio _dio;

  static final String _baseUrl = ApiConstants.baseUrl;

  RoleTaskTemplateService({Dio? dioOverride})
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

  Future<({List<RoleTaskTemplate> list, int count})> listTaskTemplates(
    String token, {
    required int roleId,
    String? frequency,
    String? priority,
    bool? isActive,
    String? search,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };
      if (priority != null) queryParams['default_priority'] = priority;
      if (isActive != null) queryParams['is_active'] = isActive;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _dio.get(
        '/api/v1/roles/$roleId/task-templates',
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
        list: items.map((json) => RoleTaskTemplate.fromJson(json)).toList(),
        count: count,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<RoleTaskTemplate> createTaskTemplate(
    String token,
    int roleId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _dio.post(
        '/api/v1/roles/$roleId/task-templates',
        data: payload,
        options: _authOptions(token),
      );
      return RoleTaskTemplate.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<RoleTaskTemplate> updateTaskTemplate(
    String token,
    int roleId,
    int templateId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _dio.patch(
        '/api/v1/roles/$roleId/task-templates/$templateId',
        data: payload,
        options: _authOptions(token),
      );
      return RoleTaskTemplate.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteTaskTemplate(
      String token, int roleId, int templateId) async {
    try {
      await _dio.delete(
        '/api/v1/roles/$roleId/task-templates/$templateId',
        options: _authOptions(token),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      final body = error.response?.data;
      final errorMessage = (body is Map)
          ? (body['message'] ?? body['detail'] ?? error.message)
          : error.message;
      return Exception(
          'API Error: ${error.response?.statusCode} - $errorMessage');
    }
    return Exception('Unexpected error: $error');
  }
}
