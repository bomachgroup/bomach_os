import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../../../pages/operations/models/models.dart';
import '../../../src/services/operations/operations_services.dart';

class ProjectController extends GetxController {
  final DashboardService _service =
      DashboardService(baseUrl: 'https://bomachoperations.bgbot.app');
  final _storage = const FlutterSecureStorage();

  var projects = <Project>[].obs;
  var isLoading = false.obs;
  var isActionLoading = false.obs;
  var errorMessage = ''.obs;

  var currentLimit = 10.obs;
  var currentOffset = 0.obs;

  Future<String?> _getToken(BuildContext context) async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith("Bearer ")) token = token.replaceFirst("Bearer ", "");
    return token.replaceAll('"', '').trim();
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> fetchProjects(BuildContext context,
      {String? search, String? status}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final token = await _getToken(context);
      if (token == null) throw Exception("Authentication token not found");

      final result = await _service.getProjects(
        accessToken: token,
        limit: currentLimit.value,
        offset: currentOffset.value,
        search: search,
        status: status,
      );

      projects.assignAll(result);
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
