import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:dio/dio.dart';

import '../../../pages/hr/models/interview_model.dart';

class InterviewService {
  final Dio _dio;

  static final String _baseUrl = '${ApiConstants.baseUrl}/api/v1';

  InterviewService({
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

  /// GET /applicants/{applicantId}/interviews/ — list interviews for an applicant
  Future<({List<Interview> items, int count})> getInterviews(
    String token,
    int applicantId, {
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/applicants/$applicantId/interviews/',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
        options: _authOptions(token),
      );

      final dynamic data = response.data;
      List<dynamic> list = [];
      int count = 0;

      if (data is Map<String, dynamic>) {
        if (data.containsKey('items')) list = data['items'];
        if (data.containsKey('count')) {
          count = data['count'] is int ? data['count'] : 0;
        }
      } else if (data is List) {
        list = data;
        count = list.length;
      }

      final items = list.map((json) => Interview.fromJson(json)).toList();
      return (items: items, count: count);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST /applicants/{applicantId}/interviews/ — create an interview
  Future<Interview> createInterview(
    String token,
    int applicantId,
    Interview interview,
  ) async {
    try {
      final response = await _dio.post(
        '/applicants/$applicantId/interviews/',
        data: interview.toCreateJson(),
        options: _authOptions(token),
      );
      return Interview.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// GET /applicants/{applicantId}/interviews/{interviewId} — get single interview
  Future<Interview> getInterviewById(
    String token,
    int applicantId,
    int interviewId,
  ) async {
    try {
      final response = await _dio.get(
        '/applicants/$applicantId/interviews/$interviewId',
        options: _authOptions(token),
      );
      return Interview.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH /applicants/{applicantId}/interviews/{interviewId} — update an interview
  Future<Interview> updateInterview(
    String token,
    int applicantId,
    int interviewId,
    Interview interview,
  ) async {
    try {
      final response = await _dio.patch(
        '/applicants/$applicantId/interviews/$interviewId',
        data: interview.toUpdateJson(),
        options: _authOptions(token),
      );
      return Interview.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE /applicants/{applicantId}/interviews/{interviewId} — delete an interview
  Future<void> deleteInterview(
    String token,
    int applicantId,
    int interviewId,
  ) async {
    try {
      await _dio.delete(
        '/applicants/$applicantId/interviews/$interviewId',
        options: _authOptions(token),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH /applicants/{applicantId}/interviews/{interviewId}/feedback — submit feedback
  Future<Interview> submitFeedback(
    String token,
    int applicantId,
    int interviewId, {
    required String feedback,
    String? status,
  }) async {
    try {
      final data = <String, dynamic>{
        'feedback': feedback,
        if (status != null) 'status': status,
      };

      final response = await _dio.patch(
        '/applicants/$applicantId/interviews/$interviewId/feedback',
        data: data,
        options: _authOptions(token),
      );
      return Interview.fromJson(response.data);
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
