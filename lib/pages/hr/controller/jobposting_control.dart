import 'dart:developer';
import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

import '../../../src/services/hr/jobposting_service.dart';
import '../models/job_posting.dart';

import 'package:bomach_os/src/utils/app_date_format.dart';
class JobPostController extends GetxController {
  final JobPostingService _jobService = JobPostingService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  var isLoading = false.obs;
  var isSaving = false.obs;
  var jobList = <JobPosting>[].obs;
  var totalCount = 0.obs;

  final titleController = TextEditingController();
  final departmentController = TextEditingController();
  final branchController = TextEditingController();
  final descriptionController = TextEditingController();
  final requirementsController = TextEditingController();

  final responsibilitiesController = TextEditingController();
  final deadlineController = TextEditingController();

  final minSalaryController = TextEditingController();
  final maxSalaryController = TextEditingController();

  DateTime? selectedDeadline;

  var selectedStatus = 'Draft'.obs;
  var selectedJobType = 'Full Time'.obs;

  Future<void> fetchJobPostings(BuildContext context,
      {bool refresh = false}) async {
    try {
      if (!refresh) isLoading.value = true;
      final token = await _getToken(context);
      if (token == null) return;

      final result = await _jobService.getJobPostings(token);
      jobList.assignAll(result.list);
      totalCount.value = result.count;
    } catch (e) {
      log("Fetch Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveJob(BuildContext context, {String? id}) async {
    try {
      isSaving.value = true;

      String salaryString = "Negotiable";
      if (minSalaryController.text.isNotEmpty ||
          maxSalaryController.text.isNotEmpty) {
        final min = minSalaryController.text.replaceAll(',', '').trim();
        final max = maxSalaryController.text.replaceAll(',', '').trim();
        salaryString = "$min - $max";
      }

      final DateTime deadlineDate =
          selectedDeadline ?? DateTime.now().add(const Duration(days: 30));

      final apiJobType =
          selectedJobType.value.toLowerCase().replaceAll(' ', '_');
      final apiStatus = selectedStatus.value.toLowerCase();

      final posting = JobPosting(
        id: id ?? '',
        title: titleController.text.trim(),
        departmentId: departmentController.text.trim(),
        branchId: branchController.text.trim(),
        jobType: apiJobType,
        status: apiStatus,
        description: descriptionController.text.trim(),
        requirements: requirementsController.text.trim(),
        responsibilities: responsibilitiesController.text.trim(),
        salaryRange: salaryString,
        deadline: deadlineDate,
        isActive: true,
      );

      final token = await _getToken(context);
      if (token == null) return;

      if (id == null) {
        await _jobService.createJobPosting(token, posting);
        if (context.mounted) {
          _showSnackBar(context, "Job Posted Successfully");
          Navigator.pop(context);
        }
      } else {
        await _jobService.updateJobPosting(token, id, posting);
        if (context.mounted) {
          _showSnackBar(context, "Job Updated Successfully");
          Navigator.pop(context);
        }
      }

      await fetchJobPostings(context, refresh: true);
      clearForm();
    } catch (e) {
      log("Save Job Error: $e");
      if (e is DioException && e.response?.data != null) {
        log("Server Response: ${e.response?.data}");
        if (context.mounted) {
          final msg = e.response?.data['detail'] ?? "Check your inputs.";
          _showDialog(context, "Submission Failed", "Server says: $msg");
        }
      }
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteJob(BuildContext context, String id) async {
    try {
      isSaving.value = true;
      final token = await _getToken(context);
      if (token == null) return;

      await _jobService.deleteJobPosting(token, id);
      if (context.mounted) {
        _showSnackBar(context, "Job Deleted Successfully");
        Navigator.pop(context);
      }
      await fetchJobPostings(context, refresh: true);
    } catch (e) {
      log("Delete Job Error: $e");
      if (e is DioException && e.response?.data != null) {
        if (context.mounted) {
          final msg = e.response?.data['detail'] ?? "Failed to delete job.";
          _showDialog(context, "Deletion Failed", "Server says: $msg");
        }
      }
    } finally {
      isSaving.value = false;
    }
  }

  void clearForm() {
    titleController.clear();
    departmentController.clear();
    branchController.clear();
    descriptionController.clear();
    requirementsController.clear();
    responsibilitiesController.clear();
    deadlineController.clear();
    minSalaryController.clear();
    maxSalaryController.clear();

    selectedDeadline = null;
    selectedStatus.value = 'Draft';
    selectedJobType.value = 'Full Time';
  }

  void populateForm(JobPosting job) {
    titleController.text = job.title;
    departmentController.text = job.departmentId;
    branchController.text = job.branchId;
    descriptionController.text = job.description;
    requirementsController.text = job.requirements;

    responsibilitiesController.text = job.responsibilities;

    if (job.salaryRange.contains('-')) {
      final parts = job.salaryRange.split('-');
      if (parts.length >= 2) {
        minSalaryController.text = parts[0].trim();
        maxSalaryController.text = parts[1].trim();
      }
    } else {
      minSalaryController.text = job.salaryRange;
    }

    selectedDeadline = job.deadline;
    if (job.deadline != null) {
      deadlineController.text = formatAppDate(job.deadline!);
    }

    selectedStatus.value = _capitalize(job.status);
    selectedJobType.value = _capitalize(job.jobType.replaceAll('_', ' '));
  }

  Future<String?> _getToken(BuildContext context) async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) {
      if (context.mounted) {
        _showSnackBar(context, "Session expired. Please login again.",
            isError: true);
      }
      return null;
    }
    if (token.startsWith("Bearer ")) token = token.replaceFirst("Bearer ", "");
    return token.replaceAll('"', '').trim();
  }

  void _showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    AppToast.info(context, message);
  }

  void _showDialog(BuildContext context, String title, String content) {
    DialogScaffold.show(
      context,
      title: title,
      size: DialogSize.sm,
      body: Text(content),
      actions: [TextButton(
              onPressed: () => Navigator.pop(context), child: const Text("OK"))],
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
