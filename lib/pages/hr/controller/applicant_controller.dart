import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../src/services/hr/applicants_service.dart';
import '../models/applicant_model.dart';

class ApplicantController extends GetxController {
  final ApplicantService _applicantService = ApplicantService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  var isLoading = false.obs;
  var isSaving = false.obs;
  var applicantList = <Applicant>[].obs;

  var selectedStageFilter = RxnString();
  var selectedStatusFilter = RxnString();

  final jobIdController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final linkedinController = TextEditingController();
  final portfolioController = TextEditingController();
  final coverLetterController = TextEditingController();
  final notesController = TextEditingController();

  var selectedStage = 'Applied'.obs;
  var selectedStatus = 'New'.obs;

  var formStage = 'Applied'.obs;
  var formStatus = 'New'.obs;

  Future<void> fetchApplicants(BuildContext context,
      {bool refresh = false}) async {
    try {
      if (!refresh) isLoading.value = true;

      final token = await _getToken(context);
      if (token == null) return;

      final stage = selectedStageFilter.value == 'All Stages'
          ? null
          : selectedStageFilter.value;
      final status = selectedStatusFilter.value == 'All Status'
          ? null
          : selectedStatusFilter.value;

      final result = await _applicantService.getApplicants(
        token,
        stage: stage,
        status: status,
      );

      applicantList.assignAll(result.items);
    } catch (e) {
      log("Fetch Applicants Error: $e");
      if (context.mounted) {
        if (e.toString().contains('404')) {
          _showDialog(context, "Not Found (404)",
              "The request returned 404. Check the API endpoint/path and request parameters (stage/status). If you're filtering, try removing filters to verify.");
        } else {
          _showSnackBar(context, "Failed to load applicants: $e",
              isError: true);
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createApplicant(BuildContext context) async {
    try {
      // Basic client-side validation to prevent malformed requests
      if (jobIdController.text.trim().isEmpty) {
        if (context.mounted) {
          _showDialog(
              context, "Validation Failed", "Job Posting ID is required.");
        }
        return;
      }

      isSaving.value = true;

      final token = await _getToken(context);
      if (token == null) return;

      final newApplicant = Applicant(
        id: '', // Backend generates this
        jobPostingId: jobIdController.text,
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        email: emailController.text,
        phone: phoneController.text,
        linkedinUrl: linkedinController.text,
        portfolioUrl: portfolioController.text,
        coverLetter: notesController.text,
        stage: selectedStage.value,
        status: selectedStatus.value,
        rating: 0,
      );

      await _applicantService.createApplicant(token, newApplicant);

      await fetchApplicants(context, refresh: true);

      if (context.mounted) {
        Navigator.of(context).pop();
        _showSnackBar(context, "Applicant added successfully");
      }
      clearForm();
    } catch (e) {
      log("Create Applicant Error: $e");
      if (context.mounted) {
        if (e.toString().contains('404')) {
          _showDialog(context, "Not Found (404)",
              "Creation returned 404. Verify the API create endpoint and that the jobPostingId exists on the server. Check request payload and server routes.");
        } else {
          _showDialog(context, "Creation Failed", e.toString());
        }
      }
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> updateApplicant(BuildContext context, String id) async {
    try {
      if (jobIdController.text.trim().isEmpty) {
        if (context.mounted) {
          _showDialog(
              context, "Validation Failed", "Job Posting ID is required.");
        }
        return;
      }

      isSaving.value = true;

      final token = await _getToken(context);
      if (token == null) return;

      final updatedApplicant = Applicant(
        id: id,
        jobPostingId: jobIdController.text,
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        email: emailController.text,
        phone: phoneController.text,
        linkedinUrl: linkedinController.text,
        portfolioUrl: portfolioController.text,
        coverLetter: notesController.text,
        stage: selectedStage.value,
        status: selectedStatus.value,
        rating: 0,
      );

      await _applicantService.updateApplicant(token, id, updatedApplicant);

      await fetchApplicants(context, refresh: true);

      if (context.mounted) {
        Navigator.of(context).pop();
        _showSnackBar(context, "Applicant updated successfully");
      }
      clearForm();
    } catch (e) {
      log("Update Applicant Error: $e");
      if (context.mounted) {
        if (e.toString().contains('404')) {
          _showDialog(context, "Not Found (404)",
              "Update returned 404. Confirm the applicant id exists and the update endpoint path is correct on the server.");
        } else {
          _showDialog(context, "Update Failed", e.toString());
        }
      }
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteApplicant(BuildContext context, String id) async {
    try {
      if (context.mounted) Navigator.of(context).pop();

      isLoading.value = true;

      final token = await _getToken(context);
      if (token == null) return;

      await _applicantService.deleteApplicant(token, id);

      applicantList.removeWhere((app) => app.id == id);

      if (context.mounted) {
        _showSnackBar(context, "Applicant deleted successfully");
      }
    } catch (e) {
      log("Delete Applicant Error: $e");
      if (context.mounted) {
        _showSnackBar(context, "Failed to delete: $e", isError: true);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> _getToken(BuildContext context) async {
    String? token = await _storage.read(key: 'access_token');

    if (token == null) {
      if (context.mounted) {
        _showSnackBar(context, "Authentication Error: Please login again",
            isError: true);
      }
      return null;
    }

    if (token.startsWith("Bearer ")) {
      token = token.replaceFirst("Bearer ", "");
    }
    token = token.replaceAll('"', '').trim();

    return token;
  }

  void _showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
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
    jobIdController.clear();
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    phoneController.clear();
    linkedinController.clear();
    portfolioController.clear();
    coverLetterController.clear();
    notesController.clear();
    formStage.value = 'Applied';
    formStatus.value = 'New';
    selectedStage.value = 'Applied';
    selectedStatus.value = 'New';
  }

  void populateForm(Applicant applicant) {
    jobIdController.text = applicant.jobPostingId;
    firstNameController.text = applicant.firstName;
    lastNameController.text = applicant.lastName;
    emailController.text = applicant.email;
    phoneController.text = applicant.phone;
    linkedinController.text = applicant.linkedinUrl ?? '';
    portfolioController.text = applicant.portfolioUrl ?? '';
    coverLetterController.text = applicant.coverLetter ?? '';
    notesController.text = applicant.coverLetter ?? '';
    formStage.value = applicant.stage;
    formStatus.value = applicant.status;
    selectedStage.value = applicant.stage;
    selectedStatus.value = applicant.status;
  }

  Future<void> saveApplicant(BuildContext context, {String? id}) async {
    if (id == null) {
      await createApplicant(context);
    } else {
      await updateApplicant(context, id);
    }
  }
}
