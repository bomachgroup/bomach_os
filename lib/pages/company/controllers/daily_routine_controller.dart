import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../../../src/model/role_daily_routine_model.dart';
import '../../../src/services/role_daily_routine_service.dart';

class DailyRoutineController extends GetxController {
  final RoleDailyRoutineService _service;
  final Future<String?> Function() _tokenReader;

  DailyRoutineController({
    RoleDailyRoutineService? service,
    Future<String?> Function()? tokenReader,
  })  : _service = service ?? RoleDailyRoutineService(),
        _tokenReader = tokenReader ?? _readStoredToken;

  static Future<String?> _readStoredToken() async {
    var token = await const FlutterSecureStorage().read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith('Bearer ')) token = token.substring(7);
    return token.replaceAll('"', '').trim();
  }

  final items = <RoleDailyRoutineItem>[].obs;
  final count = 0.obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final errorMessage = ''.obs;

  int? scopedRoleId;

  Future<void> fetchData({int? roleId, String? search}) async {
    final resolvedRoleId = roleId ?? scopedRoleId;
    if (resolvedRoleId == null) return;

    scopedRoleId = resolvedRoleId;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final token = await _tokenReader();
      if (token == null || token.isEmpty) {
        throw Exception(
            'Authentication is required to load the daily routine.');
      }
      final result = await _service.listRoutine(
        token,
        roleId: resolvedRoleId,
        search: search,
        limit: 100,
      );
      items.assignAll(result.list);
      count.value = result.count;
    } catch (error) {
      log('DailyRoutineController.fetchData error: $error');
      items.clear();
      count.value = 0;
      errorMessage.value = error.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createRoutine(
    BuildContext context, {
    required int roleId,
    required String title,
    String description = '',
    int? sequence,
    String? timeOfDay,
    int? estimatedMinutes,
    bool isActive = true,
  }) async {
    return _save(
      context,
      action: () async {
        final token = await _tokenReader();
        if (token == null || token.isEmpty) return false;
        await _service.createRoutine(token, roleId, {
          'title': title,
          'description': description,
          if (sequence != null) 'sequence': sequence,
          if (timeOfDay != null && timeOfDay.isNotEmpty)
            'time_of_day': timeOfDay,
          if (estimatedMinutes != null) 'estimated_minutes': estimatedMinutes,
          'is_active': isActive,
        });
        await fetchData(roleId: roleId);
        return true;
      },
      successMessage: 'Daily routine item created',
    );
  }

  Future<bool> updateRoutine(
    BuildContext context, {
    required int id,
    String? title,
    String? description,
    int? sequence,
    String? timeOfDay,
    int? estimatedMinutes,
    bool? isActive,
  }) async {
    final roleId = scopedRoleId;
    if (roleId == null) return false;
    return _save(
      context,
      action: () async {
        final token = await _tokenReader();
        if (token == null || token.isEmpty) return false;
        await _service.updateRoutine(token, roleId, id, {
          if (title != null) 'title': title,
          if (description != null) 'description': description,
          if (sequence != null) 'sequence': sequence,
          if (timeOfDay != null) 'time_of_day': timeOfDay,
          if (estimatedMinutes != null) 'estimated_minutes': estimatedMinutes,
          if (isActive != null) 'is_active': isActive,
        });
        await fetchData(roleId: roleId);
        return true;
      },
      successMessage: 'Daily routine item updated',
    );
  }

  Future<bool> deleteRoutine(BuildContext context, int id) async {
    final roleId = scopedRoleId;
    if (roleId == null) return false;
    return _save(
      context,
      action: () async {
        final token = await _tokenReader();
        if (token == null || token.isEmpty) return false;
        await _service.deleteRoutine(token, roleId, id);
        await fetchData(roleId: roleId);
        return true;
      },
      successMessage: 'Daily routine item deleted',
    );
  }

  Future<bool> _save(
    BuildContext context, {
    required Future<bool> Function() action,
    required String successMessage,
  }) async {
    isSaving.value = true;
    try {
      final succeeded = await action();
      if (succeeded && context.mounted) {
        Get.snackbar('Success', successMessage,
            snackPosition: SnackPosition.BOTTOM);
      }
      return succeeded;
    } catch (error) {
      errorMessage.value = error.toString();
      if (context.mounted) {
        Get.snackbar('Error', 'Failed to save daily routine item: $error',
            snackPosition: SnackPosition.BOTTOM);
      }
      return false;
    } finally {
      isSaving.value = false;
    }
  }
}
