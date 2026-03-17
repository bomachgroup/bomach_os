import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../src/services/hr/applicants_service.dart';
import '../models/applicant_model.dart';

class ApplicantController extends GetxController {
  final ApplicantService _applicantService = ApplicantService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Loading & State
  var isLoading = false.obs;
  var isSaving = false.obs;
  var applicantList = <Applicant>[].obs;

  // Pagination
  var currentPage = 1.obs;
  var limit = 100.obs; // Higher limit for Kanban board usually
  var totalItems = 0.obs;

  // Form Controllers
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

  // Filtered Getters for Kanban Columns
  List<Applicant> get appliedApplicants =>
      applicantList.where((a) => a.stage.toLowerCase() == 'applied').toList();

  List<Applicant> get shortlistedApplicants => applicantList
      .where((a) =>
          a.stage.toLowerCase() == 'shortlisted' ||
          a.stage.toLowerCase() == 'screening')
      .toList();

  List<Applicant> get interviewedApplicants => applicantList
      .where((a) =>
          a.stage.toLowerCase() == 'interview' ||
          a.stage.toLowerCase() == 'interviewed')
      .toList();

  List<Applicant> get hiredApplicants => applicantList
      .where((a) =>
          a.stage.toLowerCase() == 'hired' ||
          a.stage.toLowerCase() == 'offered')
      .toList();

  // --- Fetching ---

  Future<void> fetchApplicants(BuildContext context,
      {bool refresh = false}) async {
    try {
      if (!refresh) isLoading.value = true;

      final token = await _getToken(context);
      if (token == null) return;

      int offset = (currentPage.value - 1) * limit.value;

      final result = await _applicantService.getApplicants(
        token,
        limit: limit.value,
        offset: offset,
      );

      applicantList.assignAll(result.items);
      totalItems.value = result.count;
    } catch (e) {
      log("Fetch Applicants Error: $e");
      if (context.mounted) {
        _showSnackBar(context, "Failed to load applicants: $e", isError: true);
      }
    } finally {
      isLoading.value = false;
    }
  }

  // --- Pagination Actions ---

  void changePage(BuildContext context, int newPage) {
    currentPage.value = newPage;
    fetchApplicants(context);
  }

  void changeLimit(BuildContext context, int newLimit) {
    limit.value = newLimit;
    currentPage.value = 1;
    fetchApplicants(context);
  }

  // --- CRUD Actions ---

  Future<void> saveApplicant(BuildContext context, {String? id}) async {
    if (id == null) {
      await _createApplicant(context);
    } else {
      await _updateApplicant(context, id);
    }
  }

  Future<void> _createApplicant(BuildContext context) async {
    try {
      isSaving.value = true;
      final token = await _getToken(context);
      if (token == null) return;

      final newApplicant = Applicant(
        id: '',
        jobPostingId: jobIdController.text,
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        email: emailController.text,
        phone: phoneController.text,
        linkedinUrl: linkedinController.text,
        portfolioUrl: portfolioController.text,
        coverLetter:
            coverLetterController.text, // Fix: Use coverLetterController
        notes: notesController.text,
        stage: 'applied', // Default
        status: 'new',
      );

      await _applicantService.createApplicant(token, newApplicant);
      await fetchApplicants(context, refresh: true);

      if (context.mounted) {
        Navigator.of(context).pop();
        _showSnackBar(context, "Applicant added successfully");
      }
      clearForm();
    } catch (e) {
      _handleError(context, "Creation Failed", e);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> _updateApplicant(BuildContext context, String id) async {
    try {
      isSaving.value = true;
      final token = await _getToken(context);
      if (token == null) return;

      // Reconstruct applicant object
      final updatedApplicant = Applicant(
        id: id,
        jobPostingId: jobIdController.text,
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        email: emailController.text,
        phone: phoneController.text,
        linkedinUrl: linkedinController.text,
        portfolioUrl: portfolioController.text,
        coverLetter: coverLetterController.text,
        notes: notesController.text,
        stage: selectedStage.value, // Preserve or update stage
        status: selectedStatus.value,
      );

      await _applicantService.updateApplicant(token, id, updatedApplicant);
      await fetchApplicants(context, refresh: true);

      if (context.mounted) {
        Navigator.of(context).pop(); // Close Add Dialog
        _showSnackBar(context, "Applicant updated successfully");
      }
      clearForm();
    } catch (e) {
      _handleError(context, "Update Failed", e);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteApplicant(BuildContext context, String id) async {
    try {
      if (context.mounted) Navigator.of(context).pop(); // Close View Dialog
      isLoading.value = true;

      final token = await _getToken(context);
      if (token == null) return;

      await _applicantService.deleteApplicant(token, id);
      applicantList.removeWhere((app) => app.id == id);
      totalItems.value--;

      if (context.mounted) {
        _showSnackBar(context, "Applicant deleted successfully");
      }
    } catch (e) {
      _handleError(context, "Delete Failed", e);
    } finally {
      isLoading.value = false;
    }
  }

  // --- Stage Management ---

  Future<void> moveApplicantToStage(
      BuildContext context, String id, String newStage) async {
    try {
      isLoading.value = true; // Show global loading or handle locally
      final token = await _getToken(context);
      if (token == null) return;

      await _applicantService.updateApplicantStage(token, id, newStage);
      await fetchApplicants(context, refresh: true);

      if (context.mounted) {
        _showSnackBar(context, "Candidate moved to $newStage");
        Navigator.of(context).pop(); // Close View Dialog
      }
    } catch (e) {
      _handleError(context, "Action Failed", e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> rejectApplicant(BuildContext context, String id) async {
    try {
      isLoading.value = true;
      final token = await _getToken(context);
      if (token == null) return;

      await _applicantService.updateApplicantStage(token, id, 'rejected');
      await fetchApplicants(context, refresh: true);

      if (context.mounted) {
        _showSnackBar(context, "Candidate rejected", isError: true);
        Navigator.of(context).pop();
      }
    } catch (e) {
      _handleError(context, "Action Failed", e);
    } finally {
      isLoading.value = false;
    }
  }

  // --- Helpers ---

  Future<String?> _getToken(BuildContext context) async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) {
      if (context.mounted) {
        _showSnackBar(context, "Please login", isError: true);
      }
      return null;
    }
    return token.startsWith("Bearer ")
        ? token.replaceFirst("Bearer ", "")
        : token.replaceAll('"', '').trim();
  }

  void _showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _handleError(BuildContext context, String title, dynamic error) {
    log("$title: $error");
    if (context.mounted) {
      _showSnackBar(context, "$title: $error", isError: true);
    }
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
    selectedStage.value = 'Applied';
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
    notesController.text = applicant.notes ?? '';
    selectedStage.value =
        applicant.stage.isNotEmpty ? applicant.stage : 'Applied';
  }
}
