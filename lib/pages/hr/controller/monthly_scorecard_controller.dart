import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'
    show FlutterSecureStorage;
import 'package:get/get.dart';

import '../../../src/services/hr/monthly_scorecard_service.dart';
import '../models/monthly_scorecard_models.dart';

class MonthlyScorecardController extends GetxController {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final MonthlyScorecardService _service = MonthlyScorecardService();

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var scorecard = Rxn<MonthlyScorecard>();

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

  Future<String?> _getEmployeeId() async {
    // Scorecard endpoints key on the employee-record PK (user_employee.id),
    // NOT the auth account id stored under 'user_id'.
    final recordId = await _storage.read(key: 'employee_record_id');
    if (recordId != null && recordId.isNotEmpty) return recordId;
    return await _storage.read(key: 'user_id');
  }

  @override
  void onInit() {
    super.onInit();
    fetchScorecard();
  }

  Future<void> fetchScorecard() async {
    try {
      isLoading(true);
      errorMessage('');
      scorecard.value = null;

      final token = await _getToken();
      if (token == null) {
        errorMessage('Authentication token not found');
        return;
      }

      final employeeId = await _getEmployeeId();
      if (employeeId == null) {
        errorMessage('Employee ID not found');
        return;
      }

      final result = await _service.getEmployeeScorecard(
        token,
        employeeId: employeeId,
        month: selectedMonth.value,
        year: selectedYear.value,
      );
      scorecard.value = result;
    } catch (e) {
      final errStr = e.toString();
      if (errStr.contains('404')) {
        scorecard.value = null;
        errorMessage('');
      } else {
        errorMessage('Failed to load scorecard: $e');
        debugPrint('MonthlyScorecardController error: $e');
      }
    } finally {
      isLoading(false);
    }
  }

  void changeMonth(int month) {
    selectedMonth.value = month;
    fetchScorecard();
  }

  void changeYear(int year) {
    selectedYear.value = year;
    fetchScorecard();
  }
}
