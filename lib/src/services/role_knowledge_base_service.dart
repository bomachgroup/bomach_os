import 'package:dio/dio.dart';
import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:bomach_os/src/model/role_knowledge_base_model.dart';

class RoleKnowledgeBaseService {
  final Dio _dio;
  static final String _baseUrl = ApiConstants.baseUrl;

  RoleKnowledgeBaseService({Dio? dioOverride})
      : _dio = dioOverride ?? Dio(BaseOptions(
          baseUrl: _baseUrl, connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        )) { _dio.interceptors.add(LogInterceptor(request: true, requestHeader: true, responseBody: true, responseHeader: false)); }

  Options _authOptions(String token) => Options(headers: {'Authorization': 'Bearer $token'});

  Future<List<RoleKnowledgeEntry>> getEntries(String token, {int? roleId, String? category, String? search, int limit = 100, int offset = 0}) async {
    try {
      final qp = <String, dynamic>{'limit': limit, 'offset': offset};
      if (roleId != null) qp['role_id'] = roleId;
      if (category != null && category.isNotEmpty) qp['category'] = category;
      if (search != null && search.isNotEmpty) qp['search'] = search;
      final res = await _dio.get('/api/v1/knowledge-base/', queryParameters: qp, options: _authOptions(token));
      final data = res.data; final List items = data is Map ? (data['items'] ?? data['data'] ?? []) : data;
      return items.map((j) => RoleKnowledgeEntry.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        return [];
      }
      throw _handleError(e);
    }
  }

  Future<RoleKnowledgeEntry> createEntry(String token, Map<String, dynamic> payload) async {
    try {
      final res = await _dio.post('/api/v1/knowledge-base/', data: payload, options: _authOptions(token));
      final json = res.data is Map ? (res.data['data'] ?? res.data) : res.data;
      return RoleKnowledgeEntry.fromJson(json as Map<String, dynamic>);
    } catch (e) { throw _handleError(e); }
  }

  Future<RoleKnowledgeEntry> updateEntry(String token, int id, Map<String, dynamic> payload) async {
    try {
      final res = await _dio.put('/api/v1/knowledge-base/$id', data: payload, options: _authOptions(token));
      final json = res.data is Map ? (res.data['data'] ?? res.data) : res.data;
      return RoleKnowledgeEntry.fromJson(json as Map<String, dynamic>);
    } catch (e) { throw _handleError(e); }
  }

  Future<void> deleteEntry(String token, int id) async {
    try { await _dio.delete('/api/v1/knowledge-base/$id', options: _authOptions(token)); }
    catch (e) { throw _handleError(e); }
  }

  Exception _handleError(dynamic e) {
    if (e is DioException) {
      final msg = (e.response?.data is Map) ? (e.response?.data?['message'] ?? e.response?.data?['detail'] ?? e.message) : e.message;
      return Exception('API Error: ${e.response?.statusCode} - $msg');
    }
    return Exception('Unexpected error: $e');
  }
}
