import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../../../src/model/role_report_model.dart';
import '../../../src/services/role_report_service.dart';

class RoleReportController extends GetxController {
  final RoleReportService _service = RoleReportService();
  final _storage = const FlutterSecureStorage();

  var reports = <RoleReport>[].obs;
  var isLoading = false.obs;
  var isSaving = false.obs;
  var errorMessage = ''.obs;

  int? scopedRoleId;

  Future<String?> _getToken() async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith('Bearer ')) token = token.substring(7);
    return token.replaceAll('"', '').trim();
  }

  Future<void> fetchReports({int? roleId}) async {
    isLoading.value = true;
    try {
      final token = await _getToken();
      if (token == null) return;

      final result = await _service.listReports(
        token,
        roleId: roleId ?? scopedRoleId,
        limit: 100,
      );

      reports.assignAll(result.list);
    } catch (e) {
      log('RoleReportController.fetchReports error: $e');
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createReport(
    BuildContext context, {
    required int roleId,
    required String reportName,
    String? description,
    String reportType = 'monthly',
    String format = 'pdf',
    String frequency = 'monthly',
    List<String> recipients = const [],
  }) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return false;

      final payload = <String, dynamic>{
        'role_id': roleId,
        'report_name': reportName,
        'report_type': reportType,
        'format': format,
        'frequency': frequency,
        'recipients': recipients,
        if (description != null && description.isNotEmpty)
          'description': description,
      };

      await _service.createReport(token, payload);
      await fetchReports(roleId: scopedRoleId);

      if (context.mounted) {
        Get.snackbar('Success', 'Report created',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade50,
            colorText: Colors.green.shade800);
      }
      return true;
    } catch (e) {
      log('RoleReportController.createReport error: $e');
      if (context.mounted) {
        Get.snackbar('Error', 'Failed to create report: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade50,
            colorText: Colors.red.shade800);
      }
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> updateReport(
    BuildContext context, {
    required int id,
    String? reportName,
    String? description,
    String? reportType,
    String? format,
    String? frequency,
    List<String>? recipients,
  }) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return false;

      final payload = <String, dynamic>{};
      if (reportName != null) payload['report_name'] = reportName;
      if (description != null) payload['description'] = description;
      if (reportType != null) payload['report_type'] = reportType;
      if (format != null) payload['format'] = format;
      if (frequency != null) payload['frequency'] = frequency;
      if (recipients != null) payload['recipients'] = recipients;

      await _service.updateReport(token, id, payload);
      await fetchReports(roleId: scopedRoleId);

      if (context.mounted) {
        Get.snackbar('Success', 'Report updated',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade50,
            colorText: Colors.green.shade800);
      }
      return true;
    } catch (e) {
      log('RoleReportController.updateReport error: $e');
      if (context.mounted) {
        Get.snackbar('Error', 'Failed to update report: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade50,
            colorText: Colors.red.shade800);
      }
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deleteReport(BuildContext context, int id) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      await _service.deleteReport(token, id);
      await fetchReports(roleId: scopedRoleId);

      if (context.mounted) {
        Get.snackbar('Success', 'Report deleted',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade50,
            colorText: Colors.green.shade800);
      }
      return true;
    } catch (e) {
      log('RoleReportController.deleteReport error: $e');
      if (context.mounted) {
        Get.snackbar('Error', 'Failed to delete report: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade50,
            colorText: Colors.red.shade800);
      }
      return false;
    }
  }
}
