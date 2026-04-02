import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../src/services/hr/work_report_service.dart';
import '../models/work_report_model.dart';

class WorkReportController extends GetxController {
  final WorkReportService _service = WorkReportService();

  var isLoading = false.obs;
  var isSaving = false.obs;
  var workReports = <WorkReport>[].obs;
  var errorMessage = ''.obs;

  int limit = 100;
  int offset = 0;

  Future<void> fetchReports(String token) async {
    try {
      isLoading(true);
      errorMessage('');
      final result = await _service.getWorkReports(
        token,
        limit: limit,
        offset: offset,
      );
      workReports.assignAll(result);
    } catch (e) {
      errorMessage('Failed to load reports: $e');
      debugPrint("Fetch Error: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<bool> createReport(String token, WorkReport report) async {
    try {
      isSaving(true);
      await _service.createWorkReport(token, report);
      await fetchReports(token);
      return true;
    } catch (e) {
      debugPrint("Create Error: $e");
      return false;
    } finally {
      isSaving(false);
    }
  }

  Future<bool> updateReport(String token, String id, WorkReport report) async {
    try {
      isSaving(true);
      await _service.updateWorkReport(token, id, report);
      await fetchReports(token);
      return true;
    } catch (e) {
      debugPrint("Update Error: $e");
      return false;
    } finally {
      isSaving(false);
    }
  }

  Future<bool> deleteReport(String token, String id) async {
    try {
      await _service.deleteWorkReport(token, id);
      workReports.removeWhere((r) => r.id == id);
      return true;
    } catch (e) {
      debugPrint("Delete Error: $e");
      fetchReports(token);
      return false;
    }
  }
}
