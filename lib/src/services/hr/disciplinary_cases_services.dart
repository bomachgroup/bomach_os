import 'package:dio/dio.dart';

import '../../../pages/hr/models/disciplinary_cases_model.dart';

class DisciplinaryCaseService {
  final Dio _dio;

  static const String _baseUrl = 'https://bomachhr.bgbot.app/api/v1';

  DisciplinaryCaseService({
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

  Future<List<DisciplinaryCase>> getDisciplinaryCases(
    String token, {
    String? employeeId,
    String? actionType,
    String? violationCategory,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/disciplinary-cases/',
        queryParameters: {
          if (employeeId != null) 'employee_id': employeeId,
          if (actionType != null) 'action_type': actionType,
          if (violationCategory != null)
            'violation_category': violationCategory,
          'limit': limit,
          'offset': offset,
        },
        options: _authOptions(token),
      );

      final data = response.data;
      final List<dynamic> list =
          (data is Map && data.containsKey('items')) ? data['items'] : data;

      return list.map((json) => DisciplinaryCase.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<DisciplinaryCase> createDisciplinaryCase(
      String token, DisciplinaryCase kase) async {
    try {
      final response = await _dio.post(
        '/disciplinary-cases/',
        data: kase.toJson(),
        options: _authOptions(token),
      );
      return DisciplinaryCase.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<DisciplinaryCase> getDisciplinaryCaseById(
      String token, String caseId) async {
    try {
      final response = await _dio.get(
        '/disciplinary-cases/$caseId',
        options: _authOptions(token),
      );
      return DisciplinaryCase.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<DisciplinaryCase> updateDisciplinaryCase(
      String token, String caseId, DisciplinaryCase kase) async {
    try {
      final response = await _dio.put(
        '/disciplinary-cases/$caseId',
        data: kase.toJson(),
        options: _authOptions(token),
      );
      return DisciplinaryCase.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteDisciplinaryCase(String token, String caseId) async {
    try {
      await _dio.delete(
        '/disciplinary-cases/$caseId',
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
