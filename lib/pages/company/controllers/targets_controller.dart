import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../../../src/model/role_target_template_model.dart';
import '../../../src/services/role_target_template_service.dart';

class TargetsController extends GetxController {
  final RoleTargetTemplateService _service = RoleTargetTemplateService();
  final _storage = const FlutterSecureStorage();

  var targets = <RoleTargetTemplate>[].obs;
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

  Future<void> fetchTargets({int? roleId}) async {
    final role = roleId ?? scopedRoleId;
    if (role == null) return;

    isLoading.value = true;
    errorMessage.value = '';
    try {
      final token = await _getToken();
      if (token == null) return;

      final result = await _service.list(token, role);
      targets.assignAll(result.list);
    } catch (e) {
      log('TargetsController.fetchTargets error: $e');
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createTarget(
    BuildContext context, {
    required int roleId,
    required String title,
    required dynamic targetValue,
    required String period,
    String description = '',
    String unit = '',
    int? sequence,
    bool isActive = true,
  }) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return false;

      final payload = <String, dynamic>{
        'title': title,
        'target_value': targetValue,
        'period': period,
        if (description.isNotEmpty) 'description': description,
        if (unit.isNotEmpty) 'unit': unit,
        if (sequence != null) 'sequence': sequence,
        'is_active': isActive,
      };

      await _service.create(token, roleId, payload);
      await fetchTargets(roleId: roleId);

      if (context.mounted) {
        Get.snackbar('Success', 'Target template created.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade50,
            colorText: Colors.green.shade800);
      }
      return true;
    } catch (e) {
      log('TargetsController.createTarget error: $e');
      if (context.mounted) {
        Get.snackbar('Error', 'Failed to create target: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade50,
            colorText: Colors.red.shade800);
      }
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> updateTarget(
    BuildContext context, {
    required int roleId,
    required int templateId,
    String? title,
    dynamic targetValue,
    String? period,
    String? description,
    String? unit,
    int? sequence,
    bool? isActive,
  }) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return false;

      final payload = <String, dynamic>{};
      if (title != null) payload['title'] = title;
      if (targetValue != null) payload['target_value'] = targetValue;
      if (period != null) payload['period'] = period;
      if (description != null) payload['description'] = description;
      if (unit != null) payload['unit'] = unit;
      if (sequence != null) payload['sequence'] = sequence;
      if (isActive != null) payload['is_active'] = isActive;

      await _service.update(token, roleId, templateId, payload);
      await fetchTargets(roleId: roleId);

      if (context.mounted) {
        Get.snackbar('Success', 'Target template updated.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade50,
            colorText: Colors.green.shade800);
      }
      return true;
    } catch (e) {
      log('TargetsController.updateTarget error: $e');
      if (context.mounted) {
        Get.snackbar('Error', 'Failed to update target: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade50,
            colorText: Colors.red.shade800);
      }
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deleteTarget(BuildContext context, int roleId, int templateId) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      await _service.delete(token, roleId, templateId);
      await fetchTargets(roleId: roleId);

      if (context.mounted) {
        Get.snackbar('Deleted', 'Target template removed.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade50,
            colorText: Colors.green.shade800);
      }
      return true;
    } catch (e) {
      log('TargetsController.deleteTarget error: $e');
      if (context.mounted) {
        Get.snackbar('Error', 'Failed to delete target: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade50,
            colorText: Colors.red.shade800);
      }
      return false;
    }
  }
}
