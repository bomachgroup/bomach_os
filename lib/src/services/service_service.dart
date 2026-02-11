import 'package:dio/dio.dart';

import '../../pages/services/models/service_model.dart';

class ServiceService {
  final Dio _dio;

  static const String _baseUrl = 'https://bomachservice.bgbot.app/api/v1';

  ServiceService({
    Dio? dioOverride,
  }) : _dio = dioOverride ??
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
    return Options(headers: {
      'Authorization': 'Bearer $token',
    });
  }

  Future<List<Service>> getServices(
    String token, {
    String? status,
    int? categoryId,
    String? search,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/services',
        queryParameters: {
          if (status != null) 'status': status,
          if (categoryId != null) 'category_id': categoryId,
          if (search != null) 'search': search,
          'limit': limit,
          'offset': offset,
        },
        options: _authOptions(token),
      );

      final data = response.data;
      final List<dynamic> list =
          (data is Map && data.containsKey('items')) ? data['items'] : data;

      return list.map((json) => Service.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Service> getServiceById(String token, int serviceId) async {
    try {
      final response = await _dio.get(
        '/services/$serviceId',
        options: _authOptions(token),
      );
      return Service.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Service> createService(String token, Service service) async {
    try {
      final response = await _dio.post(
        '/services',
        data: service.toJson(),
        options: _authOptions(token),
      );
      return Service.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Service> updateService(
      String token, int serviceId, Service service) async {
    try {
      final response = await _dio.put(
        '/services/$serviceId',
        data: service.toJson(),
        options: _authOptions(token),
      );
      return Service.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteService(String token, int serviceId) async {
    try {
      await _dio.delete(
        '/services/$serviceId',
        options: _authOptions(token),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<ServiceCategory>> getCategories(
    String token, {
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/categories',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
        options: _authOptions(token),
      );

      final data = response.data;
      final List<dynamic> list =
          (data is Map && data.containsKey('items')) ? data['items'] : data;

      return list.map((json) => ServiceCategory.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      final errorMessage = error.response?.data?['message'] ?? error.message;
      return Exception(
          'API Error: ${error.response?.statusCode} - $errorMessage');
    }
    return Exception('Unexpected error: $error');
  }
}
