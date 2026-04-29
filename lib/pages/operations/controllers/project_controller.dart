import 'dart:developer';
import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../../../pages/operations/models/models.dart';
import '../../../src/model/departments_units_model.dart';
import '../../../src/services/employees_services.dart';
import '../../../src/services/operations/operations_services.dart';

class ProjectController extends GetxController {
  final DashboardService _service =
      DashboardService(baseUrl: ApiConstants.operationsBaseUrl);
  final EmployeeService _employeeService = EmployeeService();
  final _storage = const FlutterSecureStorage();

  var projects = <Project>[].obs;
  var projectEmployees = <ProjectEmployee>[].obs;
  var departments = <Department>[].obs;
  var isLoading = false.obs;
  var isActionLoading = false.obs;
  var isLoadingEmployees = false.obs;
  var errorMessage = ''.obs;
  var totalCount = 0.obs;
  var currentSearch = ''.obs;

  var currentLimit = 10.obs;
  var currentOffset = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchDepartments();
  }

  Future<void> _fetchDepartments() async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) return;
      final t = token.startsWith("Bearer ")
          ? token.replaceFirst("Bearer ", "")
          : token;
      final result = await _employeeService
          .getDepartments(t.replaceAll('"', '').trim(), limit: 200);
      departments.assignAll(result);
    } catch (e) {
      log("Error fetching departments: $e");
    }
  }

  Future<String?> _getToken(BuildContext context) async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith("Bearer ")) token = token.replaceFirst("Bearer ", "");
    return token.replaceAll('"', '').trim();
  }

  void _showError(BuildContext context, String message) {
    AppToast.error(context, message);
  }

  void _showSuccess(BuildContext context, String message) {
    AppToast.success(context, message);
  }

  Future<void> fetchProjects(BuildContext context,
      {String? search, String? status}) async {
    try {
      if (search != null) {
        currentSearch.value = search;
        currentOffset.value = 0;
      }
      isLoading.value = true;
      errorMessage.value = '';

      final token = await _getToken(context);
      if (token == null) throw Exception("Authentication token not found");

      final result = await _service.getProjects(
        accessToken: token,
        limit: currentLimit.value,
        offset: currentOffset.value,
        search: currentSearch.value.isEmpty ? null : currentSearch.value,
        status: status,
      );

      projects.assignAll(result.items);
      totalCount.value = result.count;
    } catch (e) {
      errorMessage.value = e.toString();
      _showError(context, "Failed to load projects: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createProject(BuildContext context, Project project) async {
    try {
      isActionLoading.value = true;
      final token = await _getToken(context);
      if (token == null) throw Exception("Authentication token not found");

      await _service.createProject(accessToken: token, project: project);

      _showSuccess(context, "Project created successfully");
      Navigator.of(context).pop();
      fetchProjects(context);
    } catch (e) {
      _showError(context, "Failed to create project: ${e.toString()}");
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> updateProject(
      BuildContext context, int id, Project project) async {
    try {
      isActionLoading.value = true;
      final token = await _getToken(context);
      if (token == null) throw Exception("Authentication token not found");

      await _service.updateProject(
          accessToken: token, projectId: id, project: project);

      _showSuccess(context, "Project updated successfully");
      Navigator.of(context).pop();
      fetchProjects(context);
    } catch (e) {
      _showError(context, "Failed to update project: ${e.toString()}");
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> fetchProjectEmployees(
      BuildContext context, int projectId) async {
    try {
      isLoadingEmployees.value = true;
      final token = await _getToken(context);
      if (token == null) throw Exception("Authentication token not found");

      final result = await _service.getProjectEmployees(
        accessToken: token,
        projectId: projectId,
      );

      projectEmployees.assignAll(result);
    } catch (e) {
      _showError(context, "Failed to load project members: ${e.toString()}");
    } finally {
      isLoadingEmployees.value = false;
    }
  }

  Future<void> deleteProject(BuildContext context, int id) async {
    try {
      isActionLoading.value = true;
      final token = await _getToken(context);
      if (token == null) throw Exception("Authentication token not found");

      await _service.deleteProject(accessToken: token, projectId: id);

      _showSuccess(context, "Project deleted successfully");
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      fetchProjects(context);
    } catch (e) {
      _showError(context, "Failed to delete project: ${e.toString()}");
    } finally {
      isActionLoading.value = false;
    }
  }
}
