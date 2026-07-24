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
    required String title,
    String? description,
    int? sequence,
    String defaultPriority = 'medium',
    int? estimatedMinutes,
    bool isActive = true,
  }) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return false;

      final seq = sequence ?? (templates.length + 1);

      final payload = <String, dynamic>{
        'title': title,
        if (description != null && description.isNotEmpty)
          'description': description,
        'sequence': seq,
        'default_priority': defaultPriority,
        if (estimatedMinutes != null) 'estimated_minutes': estimatedMinutes,
        'is_active': isActive,
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
    String? title,
    String? description,
    int? sequence,
    String? defaultPriority,
    int? estimatedMinutes,
    bool? isActive,
  }) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return false;

      final payload = <String, dynamic>{};
      if (title != null) payload['title'] = title;
      if (description != null) payload['description'] = description;
      if (sequence != null) payload['sequence'] = sequence;
      if (defaultPriority != null) payload['default_priority'] = defaultPriority;
      if (estimatedMinutes != null)
        payload['estimated_minutes'] = estimatedMinutes;
      if (isActive != null) payload['is_active'] = isActive;

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
