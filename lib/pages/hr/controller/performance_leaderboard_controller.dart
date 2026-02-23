import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'
    show FlutterSecureStorage;
import 'package:get/get.dart';

import '../../../src/services/hr/monthly_scorecard_service.dart';
import '../models/performance_leaderboard_models.dart';

class PerformanceLeaderboardController extends GetxController {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final MonthlyScorecardService _service = MonthlyScorecardService();

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var leaderboard = Rxn<LeaderboardResponse>();

  var selectedMonth = DateTime.now().month.obs;
  var selectedYear = DateTime.now().year.obs;

  Future<String?> _getToken() async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith("Bearer ")) {
      token = token.replaceFirst("Bearer ", "");
    }
    return token.replaceAll('"', '').trim();
  }

  @override
  void onInit() {
    super.onInit();
    fetchLeaderboard();
  }

  Future<void> fetchLeaderboard() async {
    try {
      isLoading(true);
      errorMessage('');
      leaderboard.value = null;

      final token = await _getToken();
      if (token == null) {
        errorMessage('Authentication token not found');
        return;
      }

      final result = await _service.getLeaderboard(
        token,
        month: selectedMonth.value,
        year: selectedYear.value,
      );
      leaderboard.value = result;
    } catch (e) {
      errorMessage('Failed to load leaderboard: $e');
      debugPrint('PerformanceLeaderboardController error: $e');
    } finally {
      isLoading(false);
    }
  }

  void changeMonth(int month) {
    selectedMonth.value = month;
    fetchLeaderboard();
  }

  void changeYear(int year) {
    selectedYear.value = year;
    fetchLeaderboard();
  }
}
