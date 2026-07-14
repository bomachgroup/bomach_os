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
    String? description,
    List<PlaybookPhase> phases = const [],
    List<String> metrics = const [],
  }) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return false;

      final payload = <String, dynamic>{
        'role_id': roleId,
        'title': title,
        if (description != null && description.isNotEmpty) 'description': description,
        'phases': phases.map((p) => p.toJson()).toList(),
        'metrics': metrics,
      };

      await _service.createPlaybook(token, roleId, payload);
      await fetchPlaybooks(roleId: scopedRoleId);

      if (context.mounted) {
        Get.snackbar('Success', 'Success playbook created',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade50,
            colorText: Colors.green.shade800);
      }
      return true;
    } catch (e) {
      log('RoleSuccessPlaybookController.createPlaybook error: $e');
      if (context.mounted) {
        Get.snackbar('Error', 'Failed to create success playbook: $e',
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
    String? description,
    List<PlaybookPhase>? phases,
    List<String>? metrics,
  }) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return false;

      final payload = <String, dynamic>{};
      if (title != null) payload['title'] = title;
      if (description != null) payload['description'] = description;
      if (phases != null) payload['phases'] = phases.map((p) => p.toJson()).toList();
      if (metrics != null) payload['metrics'] = metrics;

      final rId = scopedRoleId;
      if (rId == null) return false;
      await _service.updatePlaybook(token, rId, id, payload);
      await fetchPlaybooks(roleId: scopedRoleId);

      if (context.mounted) {
        Get.snackbar('Success', 'Success playbook updated',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade50,
            colorText: Colors.green.shade800);
      }
      return true;
    } catch (e) {
      log('RoleSuccessPlaybookController.updatePlaybook error: $e');
      if (context.mounted) {
        Get.snackbar('Error', 'Failed to update success playbook: $e',
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
        Get.snackbar('Success', 'Success playbook deleted',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade50,
            colorText: Colors.green.shade800);
      }
      return true;
    } catch (e) {
      log('RoleSuccessPlaybookController.deletePlaybook error: $e');
      if (context.mounted) {
        Get.snackbar('Error', 'Failed to delete success playbook: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade50,
            colorText: Colors.red.shade800);
      }
      return false;
    }
  }
}
