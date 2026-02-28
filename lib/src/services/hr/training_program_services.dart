import 'package:dio/dio.dart';
import '../../../pages/hr/models/training_program_model.dart';

class TrainingProgramService {
  final Dio _dio;

  static const String _baseUrl = 'https://bomachhr.bgbot.app/api/v1';

  TrainingProgramService({
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

  // Updated return type to include count for pagination
  Future<({List<TrainingProgram> items, int count})> getTrainingPrograms(
    String token, {
    String? search,
    String? programName,
    String? provider,
    String? status,
    String? targetAudience,
    String? startDateFrom,
    String? startDateTo,
    String? endDateFrom,
    String? endDateTo,
    double? minCost,
    double? maxCost,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/training-programs/',
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          if (programName != null) 'program_name': programName,
          if (provider != null) 'provider': provider,
          if (status != null && status != 'All Statutes') 'status': status,
          if (targetAudience != null) 'target_audience': targetAudience,
          if (startDateFrom != null) 'start_date_from': startDateFrom,
          if (startDateTo != null) 'start_date_to': startDateTo,
          if (endDateFrom != null) 'end_date_from': endDateFrom,
          if (endDateTo != null) 'end_date_to': endDateTo,
          if (minCost != null) 'min_cost': minCost,
          if (maxCost != null) 'max_cost': maxCost,
          'limit': limit,
          'offset': offset,
        },
        options: _authOptions(token),
      );

      final data = response.data;
      final List<dynamic> list =
          (data is Map && data.containsKey('items')) ? data['items'] : data;

      // Try to get count from API response, fallback to list length
      final int count = (data is Map && data.containsKey('count'))
          ? (data['count'] as int)
          : list.length;

      return (
        items: list.map((json) => TrainingProgram.fromJson(json)).toList(),
        count: count
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<TrainingProgram> createTrainingProgram(
      String token, TrainingProgram program) async {
    try {
      final response = await _dio.post(
        '/training-programs/',
        data: program.toJson(),
        options: _authOptions(token),
      );
      return TrainingProgram.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<TrainingProgram> updateTrainingProgram(
      String token, String programId, TrainingProgram program) async {
    try {
      final response = await _dio.put(
        '/training-programs/$programId',
        data: program.toJson(),
        options: _authOptions(token),
      );
      return TrainingProgram.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteTrainingProgram(String token, String programId) async {
    try {
      await _dio.delete(
        '/training-programs/$programId',
        options: _authOptions(token),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<TrainingProgram> updateTrainingProgramStatus(
      String token, String programId, String status) async {
    try {
      final response = await _dio.patch(
        '/training-programs/$programId/status',
        queryParameters: {'status': status},
        options: _authOptions(token),
      );
      return TrainingProgram.fromJson(response.data);
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
