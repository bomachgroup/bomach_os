import 'package:dio/dio.dart';

class EmployeeEvaluationService {
  final Dio _dio;

  static const String _baseUrl = 'https://bomachhr.bgbot.app/api/v1';

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
    required String employeeId,
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
