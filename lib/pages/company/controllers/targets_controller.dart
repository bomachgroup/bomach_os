import 'dart:developer';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../../../src/model/role_target_template_model.dart';
import '../../../src/services/role_target_template_service.dart';

class TargetActionResult {
  final bool succeeded;
  final String message;

  const TargetActionResult.success(this.message) : succeeded = true;
  const TargetActionResult.failure(this.message) : succeeded = false;
}

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

  Future<TargetActionResult> createTarget({
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
      if (token == null || token.isEmpty) {
        return const TargetActionResult.failure(
            'Sign in again before saving this target.');
      }

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
      return const TargetActionResult.success('Target template created.');
    } catch (e) {
      log('TargetsController.createTarget error: $e');
      return TargetActionResult.failure(_friendlyError(e));
    } finally {
      isSaving.value = false;
    }
  }

  Future<TargetActionResult> updateTarget({
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
      if (token == null || token.isEmpty) {
        return const TargetActionResult.failure(
            'Sign in again before saving this target.');
      }

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
      return const TargetActionResult.success('Target template updated.');
    } catch (e) {
      log('TargetsController.updateTarget error: $e');
      return TargetActionResult.failure(_friendlyError(e));
    } finally {
      isSaving.value = false;
    }
  }

  Future<TargetActionResult> deleteTarget(int roleId, int templateId) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        return const TargetActionResult.failure(
            'Sign in again before removing this target.');
      }

      await _service.delete(token, roleId, templateId);
      await fetchTargets(roleId: roleId);
      return const TargetActionResult.success('Target template removed.');
    } catch (e) {
      log('TargetsController.deleteTarget error: $e');
      return TargetActionResult.failure(_friendlyError(e));
    } finally {
      isSaving.value = false;
    }
  }

  String _friendlyError(Object error) {
    var message = error
        .toString()
        .replaceFirst(RegExp(r'^(Exception: |Unexpected error: )'), '');
    message = message.replaceFirst(RegExp(r'^API Error: (?:\d+|null) - '), '');
    if (message.contains('DioException') ||
        message.contains('SocketException')) {
      return 'The server could not be reached. Check your connection and try again.';
    }
    return message;
  }
}
