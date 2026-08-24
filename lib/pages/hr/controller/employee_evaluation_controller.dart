import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'
    show FlutterSecureStorage;
import 'package:get/get.dart';

import '../../../src/services/hr/employee_evaluation_service.dart';
import '../../../src/services/hr/monthly_scorecard_service.dart';
import '../models/monthly_scorecard_models.dart';

class EmployeeEvaluationController extends GetxController {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final MonthlyScorecardService _scorecardService = MonthlyScorecardService();
  final EmployeeEvaluationService _evaluationService =
      EmployeeEvaluationService();

  var isLoading = false.obs;
  var isSubmitting = false.obs;
  var errorMessage = ''.obs;
  var scorecard = Rxn<MonthlyScorecard>();

  var selectedMonth = DateTime.now().month.obs;
  var selectedYear = DateTime.now().year.obs;

  // Form state
  var managerComments = ''.obs;
  var promotionRequired = false.obs;
  var trainingRequired = false.obs;
  var salaryIncrease = false.obs;

  Future<String?> _getToken() async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith("Bearer ")) {
      token = token.replaceFirst("Bearer ", "");
    }
    return token.replaceAll('"', '').trim();
  }

  Future<String?> _getUserId() async {
    // Scorecard/evaluation endpoints key on the employee-record PK
    // (user_employee.id), NOT the auth account id stored under 'user_id'.
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

      final employeeId = await _getUserId();
      if (employeeId == null) {
        errorMessage('Employee ID not found');
        return;
      }

      final result = await _scorecardService.getEmployeeScorecard(
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
        errorMessage('Failed to load scorecard data: $e');
        debugPrint('EmployeeEvaluationController error: $e');
      }
    } finally {
      isLoading(false);
    }
  }

  Future<bool> submitEvaluation() async {
    final sc = scorecard.value;
    if (sc == null) return false;

    try {
      isSubmitting(true);

      final token = await _getToken();
      if (token == null) {
        Get.snackbar('Error', 'Authentication token not found',
            backgroundColor: Colors.red, colorText: Colors.white);
        return false;
      }

      final evaluatorId = await _getUserId();
      if (evaluatorId == null) {
        Get.snackbar('Error', 'User ID not found',
            backgroundColor: Colors.red, colorText: Colors.white);
        return false;
      }

      await _evaluationService.createEvaluation(
        token,
        employeeId: sc.employeeId,
        evaluatorId: evaluatorId,
        month: selectedMonth.value,
        year: selectedYear.value,
        managerComments: managerComments.value,
        promotionRequired: promotionRequired.value,
        trainingRequired: trainingRequired.value,
        salaryIncrease: salaryIncrease.value,
      );

      Get.snackbar('Success', 'Evaluation submitted successfully',
          backgroundColor: Colors.green, colorText: Colors.white);
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit evaluation: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
      debugPrint('SubmitEvaluation error: $e');
      return false;
    } finally {
      isSubmitting(false);
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
