import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../../../src/model/authority_limit_model.dart';
import '../../../src/model/role_model.dart';
import '../../../src/services/authority_limit_service.dart';
import '../../../src/services/role_service.dart';

class AuthorityLimitController extends GetxController {
  final AuthorityLimitService _service = AuthorityLimitService();
  final RoleService _roleService = RoleService();
  final _storage = const FlutterSecureStorage();

  var authorityLimits = <AuthorityLimit>[].obs;
  var isLoading = false.obs;
  var isSaving = false.obs;
  var errorMessage = ''.obs;

  var roles = <Role>[].obs;

  int limit = 50;
  int offset = 0;
  int totalCount = 0;

  String searchRoleId = '';
  String searchResource = '';
  String searchAction = '';

  @override
  void onInit() {
    super.onInit();
    fetchAuthorityLimits();
    fetchRoles();
  }

  Future<String?> _getToken() async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith('Bearer ')) token = token.substring(7);
    return token.replaceAll('"', '').trim();
  }

  Future<void> fetchRoles() async {
    try {
      final token = await _getToken();
      if (token == null) return;

      final result = await _roleService.listRoles(
        token,
        limit: 500,
      );
      roles.assignAll(result.list);
    } catch (e) {
      log('Error fetching roles: $e');
    }
  }

  Future<void> fetchAuthorityLimits({bool refresh = false}) async {
    if (refresh) {
      offset = 0;
    }
    if (!refresh) {
      isLoading.value = true;
    }
    errorMessage.value = '';

    try {
      final token = await _getToken();
      if (token == null) return;

      final result = await _service.listAuthorityLimits(
        token,
        roleId: searchRoleId.isNotEmpty ? searchRoleId : null,
        resource: searchResource.isNotEmpty ? searchResource : null,
        action: searchAction.isNotEmpty ? searchAction : null,
        limit: limit,
        offset: offset,
      );

      if (refresh || offset == 0) {
        authorityLimits.assignAll(result.list);
      } else {
        authorityLimits.addAll(result.list);
      }
      totalCount = result.count;
    } catch (e) {
      errorMessage.value = 'Failed to load authority limits: $e';
      log('Error fetching authority limits: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void onSearchChanged({
    String? roleId,
    String? resource,
    String? action,
  }) {
    if (roleId != null) searchRoleId = roleId;
    if (resource != null) searchResource = resource;
    if (action != null) searchAction = action;
    offset = 0;
    fetchAuthorityLimits(refresh: true);
  }

  Future<bool> createAuthorityLimit(
    BuildContext context, {
    required String roleId,
    required String resource,
    required String action,
    double? maxAmount,
    String? currency,
    int? maxQuantity,
    String? conditions,
    String? approvalLevel,
    List<int>? requiredApproverRoleIds,
    bool requiresSequentialApproval = false,
  }) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return false;

      final payload = <String, dynamic>{
        'role_id': roleId,
        'resource': resource,
        'action': action,
        if (maxAmount != null) 'max_amount': maxAmount,
        if (currency != null && currency.isNotEmpty) 'currency': currency,
        if (maxQuantity != null) 'max_quantity': maxQuantity,
        if (conditions != null && conditions.isNotEmpty) 'conditions': conditions,
        if (approvalLevel != null && approvalLevel.isNotEmpty)
          'approval_level': approvalLevel,
        if (requiredApproverRoleIds != null &&
            requiredApproverRoleIds.isNotEmpty)
          'required_approver_role_ids': requiredApproverRoleIds,
        'requires_sequential_approval': requiresSequentialApproval,
      };

      await _service.createAuthorityLimit(token, payload);

      await fetchAuthorityLimits(refresh: true);

      if (context.mounted) {
        Get.snackbar('Success', 'Authority limit created successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade50,
            colorText: Colors.green.shade800);
      }
      return true;
    } catch (e) {
      log('Error creating authority limit: $e');
      if (context.mounted) {
        Get.snackbar('Error', 'Failed to create authority limit: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade50,
            colorText: Colors.red.shade800);
      }
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> updateAuthorityLimit(
    BuildContext context, {
    required String id,
    String? resource,
    String? action,
    double? maxAmount,
    String? currency,
    int? maxQuantity,
    String? conditions,
    String? approvalLevel,
    List<int>? requiredApproverRoleIds,
    bool? requiresSequentialApproval,
  }) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return false;

      final payload = <String, dynamic>{};
      if (resource != null) payload['resource'] = resource;
      if (action != null) payload['action'] = action;
      if (maxAmount != null) payload['max_amount'] = maxAmount;
      if (currency != null && currency.isNotEmpty) {
        payload['currency'] = currency;
      }
      if (maxQuantity != null) payload['max_quantity'] = maxQuantity;
      if (conditions != null) payload['conditions'] = conditions;
      if (approvalLevel != null) payload['approval_level'] = approvalLevel;
      if (requiredApproverRoleIds != null) {
        payload['required_approver_role_ids'] = requiredApproverRoleIds;
      }
      if (requiresSequentialApproval != null) {
        payload['requires_sequential_approval'] = requiresSequentialApproval;
      }

      await _service.updateAuthorityLimit(token, id, payload);

      await fetchAuthorityLimits(refresh: true);

      if (context.mounted) {
        Get.snackbar('Success', 'Authority limit updated successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade50,
            colorText: Colors.green.shade800);
      }
      return true;
    } catch (e) {
      log('Error updating authority limit: $e');
      if (context.mounted) {
        Get.snackbar('Error', 'Failed to update authority limit: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade50,
            colorText: Colors.red.shade800);
      }
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deleteAuthorityLimit(BuildContext context, String id) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      await _service.deleteAuthorityLimit(token, id);

      await fetchAuthorityLimits(refresh: true);

      if (context.mounted) {
        Get.snackbar('Success', 'Authority limit deleted successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade50,
            colorText: Colors.green.shade800);
      }
      return true;
    } catch (e) {
      log('Error deleting authority limit: $e');
      if (context.mounted) {
        Get.snackbar('Error', 'Failed to delete authority limit: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade50,
            colorText: Colors.red.shade800);
      }
      return false;
    }
  }
}
