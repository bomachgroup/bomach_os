import 'package:dio/dio.dart';
import 'package:bms_front_end/src/constants/api_constants.dart';
import 'package:bms_front_end/pages/services/models/estate_models.dart';

class EstateService {
  final Dio _dio;

  static final String _baseUrl = ApiConstants.baseUrl;

  EstateService({Dio? dioOverride})
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

  /// Get field choices for dropdowns (estate_type, estate_status, area_unit)
  Future<Map<String, List<Map<String, dynamic>>>> getFieldChoices(
      String token) async {
    try {
      final response = await _dio.get(
        '/api/v1/estates/choices/fields',
        options: _authOptions(token),
      );
      final data = response.data as Map<String, dynamic>;
      final result = <String, List<Map<String, dynamic>>>{};
      data.forEach((key, value) {
        if (value is List) {
          result[key] = value.cast<Map<String, dynamic>>();
        }
      });
      return result;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// List all estates with optional filters and pagination
  Future<({List<Estate> items, int count})> getEstates(
    String token, {
    String? search,
    String? estateStatus,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/estates/',
        queryParameters: {
          'limit': limit,
          'offset': offset,
          if (search != null && search.isNotEmpty) 'search': search,
          if (estateStatus != null && estateStatus.isNotEmpty)
            'estate_status': estateStatus,
        },
        options: _authOptions(token),
      );

      final data = response.data;
      final List<dynamic> items =
          (data is Map && data.containsKey('items')) ? data['items'] : [];
      final int count = (data is Map && data.containsKey('count'))
          ? data['count']
          : items.length;

      return (
        items: items.map((json) => Estate.fromJson(json)).toList(),
        count: count,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get a single estate by ID
  Future<Estate> getEstate(String token, int estateId) async {
    try {
      final response = await _dio.get(
        '/api/v1/estates/$estateId',
        options: _authOptions(token),
      );
      return Estate.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Create a new estate
  Future<Estate> createEstate(
      String token, Map<String, dynamic> payload) async {
    try {
      final response = await _dio.post(
        '/api/v1/estates/',
        data: payload,
        options: _authOptions(token),
      );
      return Estate.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Update an estate
  Future<Estate> updateEstate(
      String token, int estateId, Map<String, dynamic> payload) async {
    try {
      final response = await _dio.put(
        '/api/v1/estates/$estateId',
        data: payload,
        options: _authOptions(token),
      );
      return Estate.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete an estate
  Future<void> deleteEstate(String token, int estateId) async {
    try {
      await _dio.delete(
        '/api/v1/estates/$estateId',
        options: _authOptions(token),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

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
