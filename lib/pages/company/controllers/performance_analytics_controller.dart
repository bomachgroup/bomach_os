import 'dart:developer';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../../hr/models/monthly_scorecard_models.dart';
import '../../hr/models/performance_review.dart';
import '../../../src/model/employees_model.dart';
import '../../../src/services/employees_services.dart';
import '../../../src/services/hr/monthly_scorecard_service.dart';
import '../../../src/services/hr/performance_review.dart' as pr;

class EmployeePerfData {
  final Employee employee;
  final MonthlyScorecard? latestScorecard;
  final PerformanceReview? latestReview;
  final double? avgScore;

  EmployeePerfData({
    required this.employee,
    this.latestScorecard,
    this.latestReview,
    this.avgScore,
  });
}

class PerformanceAnalyticsController extends GetxController {
  final EmployeeService _empService = EmployeeService();
  final MonthlyScorecardService _scorecardService = MonthlyScorecardService();
  final pr.PerformanceReviewService _reviewService =
      pr.PerformanceReviewService();
  final _storage = const FlutterSecureStorage();

  var employees = <Employee>[].obs;
  var perfData = <EmployeePerfData>[].obs;
  var aggregateAvgScore = 0.0.obs;
  var totalEmployees = 0.obs;
  var totalReviews = 0.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  int? scopedRoleId;

  Future<String?> _getToken() async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith('Bearer ')) token = token.substring(7);
    return token.replaceAll('"', '').trim();
  }

  Future<void> fetchAnalytics({int? roleId}) async {
    isLoading.value = true;
    try {
      final token = await _getToken();
      if (token == null) return;

      final role = roleId ?? scopedRoleId;
      if (role == null) return;

      final empResult = await _empService.getEmployees(token, limit: 500);
      final roleEmployees =
          empResult.list.where((e) => e.roleId == role).toList();
      employees.assignAll(roleEmployees);

      final dataList = <EmployeePerfData>[];
      double totalScore = 0;
      int scoreCount = 0;
      int reviewCount = 0;

      for (final emp in roleEmployees) {
        MonthlyScorecard? scorecard;
        PerformanceReview? review;

        final now = DateTime.now();
        try {
          scorecard = await _scorecardService.getEmployeeScorecard(
            token,
            employeeId: emp.id,
            month: now.month,
            year: now.year,
          );
        } catch (_) {}

        try {
          final reviews = await _reviewService.getPerformanceReviews(
            token,
            employeeId: emp.id,
            limit: 1,
          );
          if (reviews.isNotEmpty) {
            review = reviews.first;
            reviewCount++;
          }
        } catch (_) {}

        final avgScore = scorecard?.overallScore;
        if (avgScore != null) {
          totalScore += avgScore;
          scoreCount++;
        }

        dataList.add(EmployeePerfData(
          employee: emp,
          latestScorecard: scorecard,
          latestReview: review,
          avgScore: avgScore,
        ));
      }

      aggregateAvgScore.value =
          scoreCount > 0 ? totalScore / scoreCount : 0;
      totalEmployees.value = roleEmployees.length;
      totalReviews.value = reviewCount;
      perfData.assignAll(dataList);
    } catch (e) {
      log('PerformanceAnalyticsController.fetchAnalytics error: $e');
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
