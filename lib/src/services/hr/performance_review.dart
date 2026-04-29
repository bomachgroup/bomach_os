import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:dio/dio.dart';

import '../../../pages/hr/models/performance_review.dart';

class PerformanceReviewService {
  final Dio _dio;

  static final String _baseUrl = '${ApiConstants.baseUrl}/api/v1';

  PerformanceReviewService({
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

  Future<List<PerformanceReview>> getPerformanceReviews(
    String token, {
    String? employeeId,
    String? reviewerId,
    String? reviewPeriod,
    int? minRating,
    int? maxRating,
    String? dateFrom,
    String? dateTo,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/performance-reviews/',
        queryParameters: {
          if (employeeId != null) 'employee_id': employeeId,
          if (reviewerId != null) 'reviewer_id': reviewerId,
          if (reviewPeriod != null) 'review_period': reviewPeriod,
          if (minRating != null) 'min_rating': minRating,
          if (maxRating != null) 'max_rating': maxRating,
          if (dateFrom != null) 'date_from': dateFrom,
          if (dateTo != null) 'date_to': dateTo,
          'limit': limit,
          'offset': offset,
        },
        options: _authOptions(token),
      );

      final data = response.data;
      final List<dynamic> list =
          (data is Map && data.containsKey('items')) ? data['items'] : data;

      return list.map((json) => PerformanceReview.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<PerformanceReview> createPerformanceReview(
      String token, PerformanceReview review) async {
    try {
      final response = await _dio.post(
        '/performance-reviews/',
        data: review.toJson(),
        options: _authOptions(token),
      );
      return PerformanceReview.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<PerformanceReview> getPerformanceReviewById(
      String token, String reviewId) async {
    try {
      final response = await _dio.get(
        '/performance-reviews/$reviewId',
        options: _authOptions(token),
      );
      return PerformanceReview.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<PerformanceReview> updatePerformanceReview(
      String token, String reviewId, PerformanceReview review) async {
    try {
      final response = await _dio.put(
        '/performance-reviews/$reviewId',
        data: review.toJson(),
        options: _authOptions(token),
      );
      return PerformanceReview.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deletePerformanceReview(String token, String reviewId) async {
    try {
      await _dio.delete(
        '/performance-reviews/$reviewId',
        options: _authOptions(token),
      );
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
