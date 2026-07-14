import 'package:dio/dio.dart';
import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:bomach_os/src/model/role_success_playbook_model.dart';

class RoleSuccessPlaybookService {
  final Dio _dio;

  static final String _baseUrl = ApiConstants.baseUrl;

  RoleSuccessPlaybookService({Dio? dioOverride})
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

  Future<({List<RoleSuccessPlaybook> list, int count})> listPlaybooks(
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
        '/api/v1/roles/$roleId/success-playbook',
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
        list: items.map((json) => RoleSuccessPlaybook.fromJson(json)).toList(),
        count: count,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<RoleSuccessPlaybook> createPlaybook(
    String token,
    int roleId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _dio.post(
        '/api/v1/roles/$roleId/success-playbook',
        data: payload,
        options: _authOptions(token),
      );
      return RoleSuccessPlaybook.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<RoleSuccessPlaybook> updatePlaybook(
    String token,
    int roleId,
    int playbookId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _dio.put(
        '/api/v1/roles/$roleId/success-playbook/$playbookId',
        data: payload,
        options: _authOptions(token),
      );
      return RoleSuccessPlaybook.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deletePlaybook(String token, int roleId, int playbookId) async {
    try {
      await _dio.delete(
        '/api/v1/roles/$roleId/success-playbook/$playbookId',
        options: _authOptions(token),
      );
    } catch (e) {
      throw _handleError(e);
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
