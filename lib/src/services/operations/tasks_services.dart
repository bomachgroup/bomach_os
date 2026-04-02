import 'dart:developer';
import 'package:bms_front_end/pages/operations/models/models.dart';
import 'package:dio/dio.dart';

class TaskService {
  final Dio _dio;

  TaskService({
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

  Future<({List<Task> items, int count})> getTasks({
    required String accessToken,
    int? projectId,
    String? status,
    String? priority,
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
      if (priority != null && priority.isNotEmpty) {
        queryParams['priority'] = priority;
      }
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _dio.get(
        '/api/v1/tasks',
        queryParameters: queryParams,
        options: _authOptions(accessToken),
      );

      final data = response.data;
      if (data != null && data['items'] is List) {
        return (
          items: (data['items'] as List)
              .map((item) => Task.fromJson(item))
              .toList(),
          count: (data['count'] as num?)?.toInt() ?? 0,
        );
      }
      return (items: <Task>[], count: 0);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Task> createTask({
    required String accessToken,
    required Task task,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/tasks',
        data: task.toJson(),
        options: _authOptions(accessToken),
      );
      return Task.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Task> getTaskById({
    required String accessToken,
    required int taskId,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/tasks/$taskId',
        options: _authOptions(accessToken),
      );
      return Task.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Task> updateTask({
    required String accessToken,
    required int taskId,
    required Task task,
  }) async {
    try {
      final response = await _dio.put(
        '/api/v1/tasks/$taskId',
        data: task.toJson(),
        options: _authOptions(accessToken),
      );
      return Task.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteTask({
    required String accessToken,
    required int taskId,
  }) async {
    try {
      await _dio.delete(
        '/api/v1/tasks/$taskId',
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
      log("Task Service Error: $data");

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
