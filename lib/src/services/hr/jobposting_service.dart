import 'package:dio/dio.dart';

import '../../../pages/hr/models/job_posting.dart';

class JobPostingService {
  final Dio _dio;

  static const String _baseUrl = 'https://bomachhr.bgbot.app/api/v1';

  JobPostingService({
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

  Future<List<JobPosting>> getJobPostings(
    String token, {
    String? search,
    String? branchId,
    String? status,
    String? jobType,
    String? departmentId,
    bool? isActive,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/job-postings/',
        queryParameters: {
          if (search != null) 'search': search,
          if (branchId != null) 'branch_id': branchId,
          if (status != null) 'status': status,
          if (jobType != null) 'job_type': jobType,
          if (departmentId != null) 'department_id': departmentId,
          if (isActive != null) 'is_active': isActive,
          'limit': limit,
          'offset': offset,
        },
        options: _authOptions(token),
      );

      final List<dynamic> data = response.data;
      return data.map((json) => JobPosting.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<JobPosting> createJobPosting(String token, JobPosting posting) async {
    try {
      final response = await _dio.post(
        '/job-postings/',
        data: posting.toJson(),
        options: _authOptions(token),
      );
      return JobPosting.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<JobPosting> getJobPostingById(String token, String id) async {
    try {
      final response = await _dio.get(
        '/job-postings/$id',
        options: _authOptions(token),
      );
      return JobPosting.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<JobPosting> updateJobPosting(
      String token, String id, JobPosting posting) async {
    try {
      final response = await _dio.put(
        '/job-postings/$id',
        data: posting.toJson(),
        options: _authOptions(token),
      );
      return JobPosting.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteJobPosting(String token, String id) async {
    try {
      await _dio.delete(
        '/job-postings/$id',
        options: _authOptions(token),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<JobPosting> updateJobPostingStatus(
      String token, String id, String status) async {
    try {
      final response = await _dio.patch(
        '/job-postings/$id/status',
        data: {'status': status},
        options: _authOptions(token),
      );
      return JobPosting.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> getJobPostingsSummary(String token) async {
    try {
      final response = await _dio.get(
        '/job-postings/summary',
        options: _authOptions(token),
      );
      return response.data;
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
