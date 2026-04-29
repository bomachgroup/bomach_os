import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:dio/dio.dart';

class EmployeeEvaluationService {
  final Dio _dio;

  static final String _baseUrl = '${ApiConstants.baseUrl}/api/v1';

  EmployeeEvaluationService({
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

  Future<Map<String, dynamic>> createEvaluation(
    String token, {
    required int employeeId,
    required String evaluatorId,
    required int month,
    required int year,
    required String managerComments,
    required bool promotionRequired,
    required bool trainingRequired,
    required bool salaryIncrease,
  }) async {
    try {
      final response = await _dio.post(
        '/employee-evaluations/',
        data: {
          'employee_id': employeeId,
          'evaluator_id': evaluatorId,
          'month': month,
          'year': year,
          'manager_comments': managerComments,
          'promotion_required': promotionRequired,
          'training_required': trainingRequired,
          'salary_increase': salaryIncrease,
        },
        options: _authOptions(token),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> listEvaluations(
    String token, {
    required int employeeId,
    int? month,
    int? year,
  }) async {
    try {
      final response = await _dio.get(
        '/employee-evaluations/employee/$employeeId',
        queryParameters: {
          if (month != null) 'month': month,
          if (year != null) 'year': year,
        },
        options: _authOptions(token),
      );
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getEvaluation(
    String token, {
    required int evaluationId,
  }) async {
    try {
      final response = await _dio.get(
        '/employee-evaluations/$evaluationId',
        options: _authOptions(token),
      );
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateEvaluation(
    String token, {
    required int evaluationId,
    String? managerComments,
    bool? promotionRequired,
    bool? trainingRequired,
    bool? salaryIncrease,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (managerComments != null) data['manager_comments'] = managerComments;
      if (promotionRequired != null)
        data['promotion_required'] = promotionRequired;
      if (trainingRequired != null)
        data['training_required'] = trainingRequired;
      if (salaryIncrease != null) data['salary_increase'] = salaryIncrease;

      final response = await _dio.put(
        '/employee-evaluations/$evaluationId',
        data: data,
        options: _authOptions(token),
      );
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      final errorMessage = error.response?.data?['message'] ??
          error.response?.data?['detail'] ??
          error.message;
      return Exception(
          'API Error: ${error.response?.statusCode} - $errorMessage');
    }
    return Exception('Unexpected error: $error');
  }
}
