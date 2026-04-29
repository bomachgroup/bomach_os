import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:bomach_os/src/model/role_model.dart';
import 'package:bomach_os/src/model/branch_model.dart';
import 'package:bomach_os/src/services/role_service.dart';
import 'package:bomach_os/src/services/branch_service.dart';

class RolesController extends GetxController {
  final RoleService _roleService = RoleService();
  final BranchService _branchService = BranchService();
  final _storage = const FlutterSecureStorage();

  // ─── Observable state ─────────────────────────────────────────────

  var roles = <Role>[].obs;
  var rolesCount = 0.obs;
  var isLoading = false.obs;
  var isSaving = false.obs;

  // Dependencies for the create/edit dialog
  var permissionsMap = <String, List<String>>{}.obs;
  var branches = <Branch>[].obs;

  var isDepsLoading = false.obs;

  // Search & pagination
  var searchQuery = ''.obs;
  var currentPage = 1.obs;
  var limit = 10.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRoles();
    fetchDependencies();
  }

  Future<String?> _getToken() => _storage.read(key: 'access_token');

  // ─── Fetch roles ──────────────────────────────────────────────────

  Future<void> fetchRoles() async {
    try {
      isLoading.value = true;
      final token = await _getToken();
      if (token == null) return;

      final result = await _roleService.listRoles(
        token,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        limit: limit.value,
        offset: (currentPage.value - 1) * limit.value,
      );

      roles.assignAll(result.list);
      rolesCount.value = result.count;
    } catch (e) {
      log('Error fetching roles: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Fetch dropdown dependencies ──────────────────────────────────

  Future<void> fetchDependencies() async {
    try {
      isDepsLoading.value = true;
      final token = await _getToken();
      if (token == null) return;

      final results = await Future.wait([
        _roleService.getPermissionsMap(token),
        _branchService.getBranches(accessToken: token),
      ]);

      permissionsMap.assignAll(results[0] as Map<String, List<String>>);
      final branchResult = results[1] as ({List<Branch> items, int total});
      branches.assignAll(branchResult.items);
    } catch (e) {
      log('Error fetching dependencies: $e');
    } finally {
      isDepsLoading.value = false;
    }
  }

  // ─── CRUD operations ──────────────────────────────────────────────

  Future<bool> createRole(
    BuildContext context, {
    required String name,
    required List<int> branchIds,
    required Map<String, List<String>> permissions,
  }) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return false;

      await _roleService.createRole(token, {
        'name': name,
        'branch_ids': branchIds,
        'permissions': permissions,
      });

      await fetchRoles();

      if (context.mounted) {
        Get.snackbar('Success', 'Role created successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade50,
            colorText: Colors.green.shade800);
      }
      return true;
    } catch (e) {
      log('Error creating role: $e');
      if (context.mounted) {
        final msg = _extractErrorMessage(e);
        Get.snackbar('Error', msg,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade50,
            colorText: Colors.red.shade800);
      }
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> updateRole(
    BuildContext context, {
    required int roleId,
    String? name,
    List<int>? branchIds,
    Map<String, List<String>>? permissions,
  }) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return false;

      await _roleService.updateRole(token, roleId, {
        if (name != null) 'name': name,
        if (branchIds != null) 'branch_ids': branchIds,
        if (permissions != null) 'permissions': permissions,
      });

      await fetchRoles();

      if (context.mounted) {
        Get.snackbar('Success', 'Role updated successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade50,
            colorText: Colors.green.shade800);
      }
      return true;
    } catch (e) {
      log('Error updating role: $e');
      if (context.mounted) {
        Get.snackbar('Error', _extractErrorMessage(e),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade50,
            colorText: Colors.red.shade800);
      }
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deleteRole(BuildContext context, int roleId) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      await _roleService.deleteRole(token, roleId);
      await fetchRoles();

      if (context.mounted) {
        Get.snackbar('Success', 'Role deleted successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade50,
            colorText: Colors.green.shade800);
      }
      return true;
    } catch (e) {
      log('Error deleting role: $e');
      if (context.mounted) {
        Get.snackbar('Error', _extractErrorMessage(e),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade50,
            colorText: Colors.red.shade800);
      }
      return false;
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    currentPage.value = 1;
    fetchRoles();
  }

  void onPageChanged(int page) {
    currentPage.value = page;
    fetchRoles();
  }

  void onLimitChanged(int newLimit) {
    limit.value = newLimit;
    currentPage.value = 1;
    fetchRoles();
  }

  String _extractErrorMessage(dynamic error) {
    final str = error.toString();
    // Extract the message after the last " - " in "API Error: 400 - ..."
    final dashIndex = str.lastIndexOf(' - ');
    if (dashIndex != -1 && dashIndex + 3 < str.length) {
      return str.substring(dashIndex + 3);
    }
    return str.replaceFirst('Exception: ', '');
  }
}
