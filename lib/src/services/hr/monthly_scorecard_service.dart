import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:dio/dio.dart';

import '../../../pages/hr/models/monthly_scorecard_models.dart';
import '../../../pages/hr/models/performance_leaderboard_models.dart';

class MonthlyScorecardService {
  final Dio _dio;

  static final String _baseUrl = '${ApiConstants.baseUrl}/api/v1';

  MonthlyScorecardService({
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

  Future<MonthlyScorecard> getEmployeeScorecard(
    String token, {
    required String employeeId,
    required int month,
    required int year,
  }) async {
    try {
      final response = await _dio.get(
        '/monthly-scorecards/employee/$employeeId',
        queryParameters: {
          'month': month,
          'year': year,
        },
        options: _authOptions(token),
      );
      return MonthlyScorecard.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<LeaderboardResponse> getLeaderboard(
    String token, {
    required int month,
    required int year,
  }) async {
    try {
      final response = await _dio.get(
        '/monthly-scorecards/leaderboard',
        queryParameters: {
          'month': month,
          'year': year,
        },
        options: _authOptions(token),
      );
      return LeaderboardResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<MonthlyScorecard> updateScorecard(
    String token, {
    required int scorecardId,
    double? attendanceScore,
    double? taskDeliveryScore,
    double? reportAccuracyScore,
    double? brandContributionScore,
    double? trainingProgressScore,
    double? targetScore,
    String? notes,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (attendanceScore != null) data['attendance_score'] = attendanceScore;
      if (taskDeliveryScore != null)
        data['task_delivery_score'] = taskDeliveryScore;
      if (reportAccuracyScore != null)
        data['report_accuracy_score'] = reportAccuracyScore;
      if (brandContributionScore != null)
        data['brand_contribution_score'] = brandContributionScore;
      if (trainingProgressScore != null)
        data['training_progress_score'] = trainingProgressScore;
      if (targetScore != null) data['target_score'] = targetScore;
      if (notes != null) data['notes'] = notes;

      final response = await _dio.put(
        '/monthly-scorecards/$scorecardId',
        data: data,
        options: _authOptions(token),
      );
      return MonthlyScorecard.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      String? errorMessage;
      final data = error.response?.data;
      if (data is Map) {
        errorMessage = data['message']?.toString() ?? data['detail']?.toString();
      } else {
        errorMessage = data?.toString();
      }
      errorMessage ??= error.message;
      return Exception(
          'API Error: ${error.response?.statusCode} - $errorMessage');
    }
    return Exception('Unexpected error: $error');
  }
}
