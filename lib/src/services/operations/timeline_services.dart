import 'dart:developer';
import 'package:dio/dio.dart';

import '../../../pages/operations/models/models.dart';

class TimelineService {
  final Dio _dio;

  TimelineService({
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
            )){
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

  Future<List<TimelineModel>> getTimelines({
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
        '/api/v1/timelines',
        queryParameters: queryParams,
        options: _authOptions(accessToken),
      );

      final data = response.data;
      if (data != null && data['items'] is List) {
        return (data['items'] as List)
            .map((item) => TimelineModel.fromJson(item))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<TimelineModel> createTimeline({
    required String accessToken,
    required TimelineModel timeline,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/timelines',
        data: timeline.toJson(),
        options: _authOptions(accessToken),
      );
      return TimelineModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<TimelineModel> getTimelineById({
    required String accessToken,
    required int timelineId,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/timelines/$timelineId',
        options: _authOptions(accessToken),
      );
      return TimelineModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<TimelineModel> updateTimeline({
    required String accessToken,
    required int timelineId,
    required TimelineModel timeline,
  }) async {
    try {
      final response = await _dio.put(
        '/api/v1/timelines/$timelineId',
        data: timeline.toJson(),
        options: _authOptions(accessToken),
      );
      return TimelineModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteTimeline({
    required String accessToken,
    required int timelineId,
  }) async {
    try {
      await _dio.delete(
        '/api/v1/timelines/$timelineId',
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
      log("Timeline Service Error: $data");

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
