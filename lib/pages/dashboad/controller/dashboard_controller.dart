import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../../../src/services/dashboard_service.dart';
import '../models/dashboard_models.dart';

class DashboardController extends GetxController {
  final DashboardService _service = DashboardService();
  final _storage = const FlutterSecureStorage();

  var isLoading = true.obs;
  var errorMessage = ''.obs;

  Rxn<DashboardSummary> summary = Rxn<DashboardSummary>();
  Rxn<PerformanceCard> performanceCard = Rxn<PerformanceCard>();
  Rxn<DashboardOverview> overview = Rxn<DashboardOverview>();
  Rxn<EmployeeDashboardStats> stats = Rxn<EmployeeDashboardStats>();

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<String?> _getToken() async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith("Bearer ")) {
      token = token.replaceFirst("Bearer ", "");
    }
    return token.replaceAll('"', '').trim();
  }

  Future<void> fetchAll() async {
    try {
      isLoading(true);
      errorMessage('');

      final token = await _getToken();
      if (token == null) {
        errorMessage('Authentication token not found');
        return;
      }

      final results = await Future.wait([
        _service.getSummary(token).catchError((_) => DashboardSummary(
              fullName: '',
              jobTitle: '',
              departmentName: '',
              scorecard: Scorecard(
                  overallScore: 0,
                  workReportsScore: 0,
                  punctualityScore: 0,
                  rankText: ''),
              ranking: Ranking(rank: 0, totalMembers: 0),
            )),
        _service.getPerformanceCard(token).catchError((_) => PerformanceCard(
              fullName: '',
              jobTitle: '',
              departmentName: '',
              overallScore: 0,
              rankText: '',
              workReport: WorkReportStats(
                  score: 0, reportsSubmitted: 0, approved: 0, averageRating: 0),
              punctualityReport: PunctualityReport(
                  score: 0,
                  totalDays: 0,
                  onTimeDays: 0,
                  lateDays: 0,
                  absentDays: 0),
            )),
        _service.getOverview(token).catchError((_) => DashboardOverview(
              totalEmployees: 0,
              newHires30Days: 0,
              newHiresToday: 0,
              openRoles: 0,
              headcountByDepartment: [],
            )),
        _service.getStats(token).catchError((_) => EmployeeDashboardStats(
              totalProjects: 0,
              totalBudget: 0,
              budgetUtilization: 0,
              totalWorksites: 0,
              totalContracts: 0,
              totalTimelines: 0,
            )),
      ]);

      summary.value = results[0] as DashboardSummary;
      performanceCard.value = results[1] as PerformanceCard;
      overview.value = results[2] as DashboardOverview;
      stats.value = results[3] as EmployeeDashboardStats;
    } catch (e) {
      errorMessage('Failed to load dashboard: $e');
      debugPrint("Dashboard fetch error: $e");
    } finally {
      isLoading(false);
    }
  }
}
