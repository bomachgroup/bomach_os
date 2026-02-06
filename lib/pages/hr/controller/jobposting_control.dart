import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../src/services/hr/jobposting_service.dart';
import '../models/job_posting.dart';



class JobPostController extends GetxController {
  final JobPostingService _jobService = JobPostingService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  var isLoading = false.obs;
  var isSaving = false.obs;
  var jobList = <JobPosting>[].obs;
  var jobSummary = {}.obs;

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final departmentController = TextEditingController();
  final branchController = TextEditingController();
  final minSalaryController = TextEditingController();
  final maxSalaryController = TextEditingController();
  final requirementsController = TextEditingController();
  var selectedStatus = 'published'.obs;
  var selectedJobType = 'Full Time'.obs;



  Future<void> fetchJobPostings(BuildContext context, {bool refresh = false}) async {
    try {
      if (!refresh) isLoading.value = true;
      
      final token = await _getToken(context);
      if (token == null) return;

      final result = await _jobService.getJobPostings(token);
      jobList.assignAll(result);

    } catch (e) {
      log("Fetch Error: $e");
      if (context.mounted) {
        _showSnackBar(context, "Failed to load jobs: $e", isError: true);
      }
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> createJobPosting(BuildContext context, JobPosting posting) async {
    try {
      isSaving.value = true;
      
      final token = await _getToken(context);
      if (token == null) return;

      await _jobService.createJobPosting(token, posting);

      await fetchJobPostings(context, refresh: true);

      if (context.mounted) {
        Navigator.of(context).pop();
        _showSnackBar(context, "Job Posting created successfully");
      }
      
      clearForm(); 

    } catch (e) {
      log("Create Error: $e");
      if (context.mounted) {
        _showDialog(context, "Creation Failed", e.toString());
      }
    } finally {
      isSaving.value = false;
    }
  }


  Future<JobPosting?> getJobPostingById(BuildContext context, String id) async {
    try {
      isLoading.value = true;

      final token = await _getToken(context);
      if (token == null) return null;

      return await _jobService.getJobPostingById(token, id);

    } catch (e) {
      log("Get ID Error: $e");
      if (context.mounted) {
        _showSnackBar(context, "Failed to fetch details: $e", isError: true);
      }
      return null;
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> updateJobPosting(BuildContext context, String id, JobPosting posting) async {
    try {
      isSaving.value = true;

      final token = await _getToken(context);
      if (token == null) return;

      await _jobService.updateJobPosting(token, id, posting);

      await fetchJobPostings(context, refresh: true);

      if (context.mounted) {
        Navigator.of(context).pop();
        _showSnackBar(context, "Job Posting updated successfully");
      }
      
      clearForm();

    } catch (e) {
      log("Update Error: $e");
      if (context.mounted) {
        _showDialog(context, "Update Failed", e.toString());
      }
    } finally {
      isSaving.value = false;
    }
  }


  Future<void> deleteJobPosting(BuildContext context, String id) async {
    try {
      if (context.mounted) Navigator.of(context).pop();
      
      isLoading.value = true; 

      final token = await _getToken(context);
      if (token == null) return;

      await _jobService.deleteJobPosting(token, id);

      jobList.removeWhere((job) => job.id == id);
      
      if (context.mounted) {
        _showSnackBar(context, "Job Posting deleted successfully");
      }

    } catch (e) {
      log("Delete Error: $e");
      if (context.mounted) {
        _showSnackBar(context, "Failed to delete: $e", isError: true);
      }
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> updateJobStatus(BuildContext context, String id, String status) async {
    try {
      final token = await _getToken(context);
      if (token == null) return;

      await _jobService.updateJobPostingStatus(token, id, status);
      
      int index = jobList.indexWhere((j) => j.id == id);
      if (index != -1) {

        await fetchJobPostings(context, refresh: true);
      }

      if (context.mounted) {
        _showSnackBar(context, "Status updated to $status");
      }

    } catch (e) {
      log("Status Update Error: $e");
      if (context.mounted) {
        _showSnackBar(context, "Failed to update status: $e", isError: true);
      }
    }
  }


  Future<void> getSummary(BuildContext context) async {
    try {
      final token = await _getToken(context);
      if (token == null) return;

      final data = await _jobService.getJobPostingsSummary(token);
      if (data is Map) {
         jobSummary.assignAll(Map<String, dynamic>.from(data));
      }

    } catch (e) {
      log("Summary Error: $e");
    }
  }


  /// Retrieves token and handles UI error if missing
  Future<String?> _getToken(BuildContext context) async {
    final token = await _storage.read(key: 'access_token');
    if (token == null) {
      if (context.mounted) {
        _showSnackBar(context, "Authentication Error: Please login again", isError: true);
      }
      return null;
    }
    return token;
  }

  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    departmentController.clear();
    branchController.clear();
    minSalaryController.clear();
    maxSalaryController.clear();
    requirementsController.clear();
    selectedStatus.value = 'published';
    selectedJobType.value = 'Full Time';
  }

  void populateForm(JobPosting job) {
    titleController.text = job.title;
    descriptionController.text = job.description;
    departmentController.text = job.departmentId;
    branchController.text = job.branchId;
    minSalaryController.text = job.salaryRangeMin?.toString() ?? '';
    maxSalaryController.text = job.salaryRangeMax?.toString() ?? '';
    requirementsController.text = job.requirements ?? '';
    selectedStatus.value = job.status;
    selectedJobType.value = job.jobType;
  }
}