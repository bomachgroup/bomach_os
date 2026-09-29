import 'dart:developer';
import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../../../pages/operations/models/models.dart';
import '../../../src/model/departments_units_model.dart';
import '../../../src/services/employees_services.dart';
import '../../../src/model/employees_model.dart';
import '../../../src/services/crm/crm_service.dart';
import '../../../src/services/operations/operations_services.dart';

class ProjectController extends GetxController {
  final DashboardService _service = DashboardService(
    baseUrl: ApiConstants.operationsBaseUrl,
  );
  final EmployeeService _employeeService = EmployeeService();
  final CrmService _crmService = CrmService();
  final _storage = const FlutterSecureStorage();

  var projects = <Project>[].obs;
  var projectEmployees = <ProjectEmployee>[].obs;
  var departments = <Department>[].obs;
  var employees = <Employee>[].obs;
  var clients = <CrmClient>[].obs;
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
    _fetchProjectLookups();
  }

  Future<void> _fetchProjectLookups() async {
    try {
      final stored = await _storage.read(key: 'access_token');
      if (stored == null) return;
      final token = stored
          .replaceFirst('Bearer ', '')
          .replaceAll('"', '')
          .trim();
      final results = await Future.wait([
        _employeeService.getEmployees(token, isActive: true, limit: 200),
        _crmService.getClients(token, limit: 200),
      ]);
      employees.assignAll(
        (results[0] as ({List<Employee> list, int count})).list,
      );
      clients.assignAll(
        (results[1] as ({List<CrmClient> items, int total})).items,
      );
    } catch (e) {
      log('Unable to load project client and employee options: $e');
    }
  }

  Future<void> _fetchDepartments() async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) return;
      final t = token.startsWith("Bearer ")
          ? token.replaceFirst("Bearer ", "")
          : token;
      final result = await _employeeService.getDepartments(
        t.replaceAll('"', '').trim(),
        limit: 200,
      );
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

  Future<void> fetchProjects(
    BuildContext context, {
    String? search,
    String? status,
  }) async {
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
    BuildContext context,
    int id,
    Project project,
  ) async {
    try {
      isActionLoading.value = true;
      final token = await _getToken(context);
      if (token == null) throw Exception("Authentication token not found");

      await _service.updateProject(
        accessToken: token,
        projectId: id,
        project: project,
      );

      _showSuccess(context, "Project updated successfully");
      Navigator.of(context).pop();
      fetchProjects(context);
    } catch (e) {
      _showError(context, "Failed to update project: ${e.toString()}");
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> updateProjectStatus(
    BuildContext context,
    int id,
    String status,
  ) async {
    try {
      isActionLoading.value = true;
      final token = await _getToken(context);
      if (token == null) throw Exception("Authentication token not found");

      await _service.updateProjectStatus(
        accessToken: token,
        projectId: id,
        status: status,
      );

      _showSuccess(context, "Project status updated to $status");
      fetchProjects(context);
    } catch (e) {
      _showError(context, "Failed to update project status: ${e.toString()}");
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> fetchProjectEmployees(
    BuildContext context,
    int projectId,
  ) async {
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

  Future<void> addProjectEmployee(
    BuildContext context,
    int projectId,
    String employeeId,
    List<String> existingIds,
  ) async {
    try {
      isActionLoading.value = true;
      final token = await _getToken(context);
      if (token == null) throw Exception('Authentication token not found');
      final employeeIds = {...existingIds, employeeId}.toList();
      await _service.addProjectEmployees(
        accessToken: token,
        projectId: projectId,
        employeeIds: employeeIds,
      );
      await fetchProjectEmployees(context, projectId);
      _showSuccess(context, 'Project member added successfully');
      if (context.mounted) Navigator.of(context).pop();
    } catch (e) {
      _showError(context, 'Failed to add project member: ${e.toString()}');
    } finally {
      isActionLoading.value = false;
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
