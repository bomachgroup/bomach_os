import 'dart:developer';
import 'package:dio/dio.dart';

import '../../../pages/operations/models/models.dart';

class DashboardService {
  final Dio _dio;

  DashboardService({
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

  Future<DashboardStats> getDashboardStats(
      {required String accessToken}) async {
    try {
      final response = await _dio.get(
        '/api/v1/dashboard/stats',
        options: _authOptions(accessToken),
      );

      return DashboardStats.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PROJECTS
  Future<List<Project>> getProjects({
    required String accessToken,
    String? status,
    String? priority,
    int? clientId,
    String? search,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'limit': limit,
        'offset': offset,
      };

      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (priority != null && priority.isNotEmpty) {
        queryParams['priority'] = priority;
      }
      if (clientId != null) queryParams['client_id'] = clientId;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _dio.get(
        '/api/v1/projects',
        queryParameters: queryParams,
        options: _authOptions(accessToken),
      );

      final data = response.data;
      if (data != null && data['items'] is List) {
        return (data['items'] as List)
            .map((item) => Project.fromJson(item))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Project> createProject({
    required String accessToken,
    required Project project,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/projects',
        data: project.toJson(),
        options: _authOptions(accessToken),
      );
      return Project.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Project> getProjectById({
    required String accessToken,
    required int projectId,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/projects/$projectId',
        options: _authOptions(accessToken),
      );
      return Project.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Project> updateProject({
    required String accessToken,
    required int projectId,
    required Project project,
  }) async {
    try {
      final response = await _dio.put(
        '/api/v1/projects/$projectId',
        data: project.toJson(),
        options: _authOptions(accessToken),
      );
      return Project.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteProject({
    required String accessToken,
    required int projectId,
  }) async {
    try {
      await _dio.delete(
        '/api/v1/projects/$projectId',
        options: _authOptions(accessToken),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> getProjectStats({
    required String accessToken,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/projects/stats',
        options: _authOptions(accessToken),
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Error Handler
  Exception _handleError(DioException e) {
    String msg = 'An unknown error occurred.';
    if (e.response != null) {
      final data = e.response?.data;
      log("Dashboard Service Error: $data");

      if (data is Map<String, dynamic>) {
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
