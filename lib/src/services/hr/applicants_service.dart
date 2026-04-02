import 'package:dio/dio.dart';
import 'package:bms_front_end/src/constants/api_constants.dart';

import '../../../pages/hr/models/applicant_model.dart';

class ApplicantService {
  final Dio _dio;

  static const String _baseUrl = '${ApiConstants.baseUrl}/api/v1';

  ApplicantService({
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

  Future<({List<Applicant> items, int count})> getApplicants(
    String token, {
    String? search,
    String? status,
    String? stage,
    String? jobId,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/applicants/',
        queryParameters: {
          if (search != null) 'search': search,
          if (status != null) 'status': status,
          if (stage != null) 'stage': stage,
          if (jobId != null) 'job_posting_id': jobId,
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

      final items = list.map((json) => Applicant.fromJson(json)).toList();
      return (items: items, count: count);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Applicant> createApplicant(String token, Applicant applicant) async {
    try {
      final response = await _dio.post(
        '/applicants/',
        data: applicant.toJson(),
        options: _authOptions(token),
      );
      return Applicant.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Applicant> getApplicantById(String token, String id) async {
    try {
      final response = await _dio.get(
        '/applicants/$id',
        options: _authOptions(token),
      );
      return Applicant.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Applicant> updateApplicant(
      String token, String id, Applicant applicant) async {
    try {
      final response = await _dio.put(
        '/applicants/$id',
        data: applicant.toJson(),
        options: _authOptions(token),
      );
      return Applicant.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteApplicant(String token, String id) async {
    try {
      await _dio.delete(
        '/applicants/$id',
        options: _authOptions(token),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Applicant> updateApplicantStage(
      String token, String id, String stage) async {
    try {
      final response = await _dio.patch(
        '/applicants/$id/stage',
        data: {'stage': stage},
        options: _authOptions(token),
      );
      return Applicant.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Applicant> updateApplicantStatus(
      String token, String id, String status) async {
    try {
      final response = await _dio.patch(
        '/applicants/$id/status',
        data: {'status': status},
        options: _authOptions(token),
      );
      return Applicant.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Applicant> updateApplicantRating(
      String token, String id, int rating) async {
    try {
      final response = await _dio.patch(
        '/applicants/$id/rating',
        data: {'rating': rating},
        options: _authOptions(token),
      );
      return Applicant.fromJson(response.data);
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
