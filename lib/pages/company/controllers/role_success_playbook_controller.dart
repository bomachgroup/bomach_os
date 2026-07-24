import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../../../src/model/role_success_playbook_model.dart';
import '../../../src/services/role_success_playbook_service.dart';

class RoleSuccessPlaybookController extends GetxController {
  final RoleSuccessPlaybookService _service = RoleSuccessPlaybookService();
  final _storage = const FlutterSecureStorage();

  var playbooks = <RoleSuccessPlaybook>[].obs;
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

  Future<void> fetchPlaybooks({int? roleId}) async {
    isLoading.value = true;
    try {
      final token = await _getToken();
      if (token == null) return;
      final rId = roleId ?? scopedRoleId;
      if (rId == null) return;

      final result = await _service.listPlaybooks(
        token,
        roleId: rId,
        limit: 100,
      );

      playbooks.assignAll(result.list);
    } catch (e) {
      log('RoleSuccessPlaybookController.fetchPlaybooks error: $e');
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createPlaybook(
    BuildContext context, {
    required int roleId,
    required String title,
    required String kind,
    String? description,
    int? sequence,
    bool isActive = true,
  }) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return false;

      final seq = sequence ?? (playbooks.length + 1);

      final payload = <String, dynamic>{
        'title': title,
        'kind': kind,
        if (description != null && description.isNotEmpty)
          'description': description,
        'sequence': seq,
        'is_active': isActive,
      };

      await _service.createPlaybook(token, roleId, payload);
      await fetchPlaybooks(roleId: scopedRoleId);

      if (context.mounted) {
        Get.snackbar('Success', 'Playbook item added',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade50,
            colorText: Colors.green.shade800);
      }
      return true;
    } catch (e) {
      log('RoleSuccessPlaybookController.createPlaybook error: $e');
      if (context.mounted) {
        Get.snackbar('Error', 'Failed to create playbook item: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade50,
            colorText: Colors.red.shade800);
      }
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> updatePlaybook(
    BuildContext context, {
    required int id,
    String? title,
    String? kind,
    String? description,
    int? sequence,
    bool? isActive,
  }) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return false;

      final payload = <String, dynamic>{};
      if (title != null) payload['title'] = title;
      if (kind != null) payload['kind'] = kind;
      if (description != null) payload['description'] = description;
      if (sequence != null) payload['sequence'] = sequence;
      if (isActive != null) payload['is_active'] = isActive;

      final rId = scopedRoleId;
      if (rId == null) return false;
      await _service.updatePlaybook(token, rId, id, payload);
      await fetchPlaybooks(roleId: scopedRoleId);

      if (context.mounted) {
        Get.snackbar('Success', 'Playbook item updated',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade50,
            colorText: Colors.green.shade800);
      }
      return true;
    } catch (e) {
      log('RoleSuccessPlaybookController.updatePlaybook error: $e');
      if (context.mounted) {
        Get.snackbar('Error', 'Failed to update playbook item: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade50,
            colorText: Colors.red.shade800);
      }
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deletePlaybook(BuildContext context, int id) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      final rId = scopedRoleId;
      if (rId == null) return false;
      await _service.deletePlaybook(token, rId, id);
      await fetchPlaybooks(roleId: scopedRoleId);

      if (context.mounted) {
        Get.snackbar('Success', 'Playbook item deleted',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade50,
            colorText: Colors.green.shade800);
      }
      return true;
    } catch (e) {
      log('RoleSuccessPlaybookController.deletePlaybook error: $e');
      if (context.mounted) {
        Get.snackbar('Error', 'Failed to delete playbook item: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade50,
            colorText: Colors.red.shade800);
      }
      return false;
    }
  }
}
