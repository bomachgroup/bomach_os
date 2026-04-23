import 'package:bms_front_end/pages/operations/models/models.dart';
import 'package:bms_front_end/components/feedback/app_toast.dart';
import 'package:bms_front_end/src/constants/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../../../src/services/operations/tasks_services.dart';

class TaskController extends GetxController {
  final TaskService _service = TaskService(baseUrl: ApiConstants.operationsBaseUrl);
  final _storage = const FlutterSecureStorage();

  var tasks = <Task>[].obs;
  var isLoading = false.obs;
  var isActionLoading = false.obs;
  var errorMessage = ''.obs;
  var totalCount = 0.obs;
  var currentSearch = ''.obs;

  var currentLimit = 10.obs;
  var currentOffset = 0.obs;

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

  Future<void> fetchTasks(BuildContext context,
      {int? projectId, String? search}) async {
    try {
      if (search != null) {
        currentSearch.value = search;
        currentOffset.value = 0;
      }
      isLoading.value = true;
      errorMessage.value = '';

      final token = await _getToken(context);
      if (token == null) throw Exception("Authentication token not found");

      final result = await _service.getTasks(
        accessToken: token,
        projectId: projectId,
        search: currentSearch.value.isEmpty ? null : currentSearch.value,
        limit: currentLimit.value,
        offset: currentOffset.value,
      );

      tasks.assignAll(result.items);
      totalCount.value = result.count;
    } catch (e) {
      errorMessage.value = e.toString();
      _showError(context, "Error loading tasks: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createTask(BuildContext context, Task task) async {
    try {
      isActionLoading.value = true;
      final token = await _getToken(context);
      if (token == null) throw Exception("Authentication token not found");

      await _service.createTask(accessToken: token, task: task);

      _showSuccess(context, "Task created successfully");
      Navigator.of(context).pop();

      fetchTasks(context,
          projectId: task.projectId != 0 ? task.projectId : null);
    } catch (e) {
      _showError(context, "Failed to create task: ${e.toString()}");
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> updateTask(BuildContext context, int id, Task task) async {
    try {
      isActionLoading.value = true;
      final token = await _getToken(context);
      if (token == null) throw Exception("Authentication token not found");

      await _service.updateTask(accessToken: token, taskId: id, task: task);

      _showSuccess(context, "Task updated successfully");
      Navigator.of(context).pop();

      fetchTasks(context,
          projectId: task.projectId != 0 ? task.projectId : null);
    } catch (e) {
      _showError(context, "Failed to update task: ${e.toString()}");
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> deleteTask(BuildContext context, int id, int? projectId) async {
    try {
      isActionLoading.value = true;
      final token = await _getToken(context);
      if (token == null) throw Exception("Authentication token not found");

      await _service.deleteTask(accessToken: token, taskId: id);

      _showSuccess(context, "Task deleted successfully");

      if (Navigator.canPop(context)) {}

      fetchTasks(context, projectId: projectId);
    } catch (e) {
      _showError(context, "Failed to delete task: ${e.toString()}");
    } finally {
      isActionLoading.value = false;
    }
  }
}
