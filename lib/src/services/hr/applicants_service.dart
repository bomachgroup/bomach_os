import 'package:dio/dio.dart';

import '../../../pages/hr/models/applicant_model.dart';

class ApplicantService {
  final Dio _dio;

  static const String _baseUrl = 'https://bomachhr.bgbot.app/api/v1';

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
            ));

  Options _authOptions(String token) {
    return Options(headers: {
      'Authorization': 'Bearer $token',
    });
  }

  Future<List<Applicant>> getApplicants(
    String token, {
    String? search,
    String? jobPostingId,
    String? stage,
    String? status,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/applicants/',
        queryParameters: {
          if (search != null) 'search': search,
          if (jobPostingId != null) 'job_posting_id': jobPostingId,
          if (stage != null) 'stage': stage,
          if (status != null) 'status': status,
          'limit': limit,
          'offset': offset,
        },
        options: _authOptions(token),
      );

      final List<dynamic> data = response.data;
      return data.map((json) => Applicant.fromJson(json)).toList();
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
