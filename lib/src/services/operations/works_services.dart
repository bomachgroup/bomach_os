import 'dart:developer';
import 'package:dio/dio.dart';

import '../../../pages/operations/models/models.dart';

class WorksiteService {
  final Dio _dio;

  WorksiteService({
    required String baseUrl,
    Dio? dioOverride,
  }) : _dio = dioOverride ??
            Dio(BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            ));

  Options _authOptions(String token) {
    return Options(headers: {
      'Authorization': 'Bearer $token',
    });
  }

  Future<List<Worksite>> getWorksites({
    required String accessToken,
    int? projectId,
    String? status,
    String? search,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'limit': limit,
        'offset': offset,
      };

      if (projectId != null) queryParams['project_id'] = projectId;
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _dio.get(
        '/api/v1/worksites',
        queryParameters: queryParams,
        options: _authOptions(accessToken),
      );

      final data = response.data;
      if (data != null && data['items'] is List) {
        return (data['items'] as List)
            .map((item) => Worksite.fromJson(item))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Worksite> createWorksite({
    required String accessToken,
    required Worksite worksite,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/worksites',
        data: worksite.toJson(),
        options: _authOptions(accessToken),
      );
      return Worksite.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Worksite> getWorksiteById({
    required String accessToken,
    required int worksiteId,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/worksites/$worksiteId',
        options: _authOptions(accessToken),
      );
      return Worksite.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Worksite> updateWorksite({
    required String accessToken,
    required int worksiteId,
    required Worksite worksite,
  }) async {
    try {
      final response = await _dio.put(
        '/api/v1/worksites/$worksiteId',
        data: worksite.toJson(),
        options: _authOptions(accessToken),
      );
      return Worksite.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteWorksite({
    required String accessToken,
    required int worksiteId,
  }) async {
    try {
      await _dio.delete(
        '/api/v1/worksites/$worksiteId',
        options: _authOptions(accessToken),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    String msg = 'An unknown error occurred.';
    if (e.response != null) {
      final data = e.response?.data;
      log("Worksite Service Error: $data");

      if (data is Map<String, dynamic>) {
        if (data['errors'] != null) {
          return Exception("Validation: ${data['errors']}");
        }
        if (data.containsKey('detail')) {
          msg = data['detail'];
        } else if (data.containsKey('message')) {
          msg = data['message'];
        }
      }
    } else {
      msg = "Connection error. Please check your internet.";
    }
    return Exception(msg);
  }
}
