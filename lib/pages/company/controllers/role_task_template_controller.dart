import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../../../src/model/role_task_template_model.dart';
import '../../../src/services/role_task_template_service.dart';

class RoleTaskTemplateController extends GetxController {
  final RoleTaskTemplateService _service = RoleTaskTemplateService();
  final _storage = const FlutterSecureStorage();

  var templates = <RoleTaskTemplate>[].obs;
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

  Future<void> fetchTemplates({int? roleId}) async {
    isLoading.value = true;
    try {
      final token = await _getToken();
      if (token == null) return;
      final rId = roleId ?? scopedRoleId;
      if (rId == null) return;

      final result = await _service.listTaskTemplates(
        token,
        roleId: rId,
        limit: 100,
      );

      templates.assignAll(result.list);
    } catch (e) {
      log('RoleTaskTemplateController.fetchTemplates error: $e');
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createTemplate(
    BuildContext context, {
    required int roleId,
    required String taskName,
    String? description,
    int estimatedDuration = 30,
    String frequency = 'weekly',
    String priority = 'medium',
    String? category,
  }) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return false;

      final payload = <String, dynamic>{
        'role_id': roleId,
        'task_name': taskName,
        'estimated_duration': estimatedDuration,
        'frequency': frequency,
        'priority': priority,
        if (description != null && description.isNotEmpty)
          'description': description,
        if (category != null && category.isNotEmpty) 'category': category,
      };

      await _service.createTaskTemplate(token, roleId, payload);
      await fetchTemplates(roleId: scopedRoleId);

      if (context.mounted) {
        Get.snackbar('Success', 'Task template created',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade50,
            colorText: Colors.green.shade800);
      }
      return true;
    } catch (e) {
      log('RoleTaskTemplateController.createTemplate error: $e');
      if (context.mounted) {
        Get.snackbar('Error', 'Failed to create task template: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade50,
            colorText: Colors.red.shade800);
      }
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> updateTemplate(
    BuildContext context, {
    required int id,
    String? taskName,
    String? description,
    int? estimatedDuration,
    String? frequency,
    String? priority,
    String? category,
  }) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return false;

      final payload = <String, dynamic>{};
      if (taskName != null) payload['task_name'] = taskName;
      if (description != null) payload['description'] = description;
      if (estimatedDuration != null)
        payload['estimated_duration'] = estimatedDuration;
      if (frequency != null) payload['frequency'] = frequency;
      if (priority != null) payload['priority'] = priority;
      if (category != null) payload['category'] = category;

      final rId = scopedRoleId;
      if (rId == null) return false;
      await _service.updateTaskTemplate(token, rId, id, payload);
      await fetchTemplates(roleId: scopedRoleId);

      if (context.mounted) {
        Get.snackbar('Success', 'Task template updated',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade50,
            colorText: Colors.green.shade800);
      }
      return true;
    } catch (e) {
      log('RoleTaskTemplateController.updateTemplate error: $e');
      if (context.mounted) {
        Get.snackbar('Error', 'Failed to update task template: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade50,
            colorText: Colors.red.shade800);
      }
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deleteTemplate(BuildContext context, int id) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      final rId = scopedRoleId;
      if (rId == null) return false;
      await _service.deleteTaskTemplate(token, rId, id);
      await fetchTemplates(roleId: scopedRoleId);

      if (context.mounted) {
        Get.snackbar('Success', 'Task template deleted',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade50,
            colorText: Colors.green.shade800);
      }
      return true;
    } catch (e) {
      log('RoleTaskTemplateController.deleteTemplate error: $e');
      if (context.mounted) {
        Get.snackbar('Error', 'Failed to delete task template: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade50,
            colorText: Colors.red.shade800);
      }
      return false;
    }
  }
}
