import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:bomach_os/src/model/role_model.dart';
import 'package:bomach_os/src/model/branch_model.dart';
import 'package:bomach_os/src/services/role_service.dart';
import 'package:bomach_os/src/services/branch_service.dart';

final Set<int> _requestedRoleDescriptions = <int>{};
final _roleDescriptionCache = <int, Map<String, dynamic>>{}.obs;

class _PendingRoleDescriptionSave {
  final int roleId;
  final String purpose;
  final String jobDescription;
  final String responsibilities;

  const _PendingRoleDescriptionSave({
    required this.roleId,
    required this.purpose,
    required this.jobDescription,
    required this.responsibilities,
  });
}

class RolesController extends GetxController {
  final RoleService _roleService = RoleService();
  final BranchService _branchService = BranchService();
  final _storage = const FlutterSecureStorage();

  // ─── Observable state ─────────────────────────────────────────────

  var roles = <Role>[].obs;
  var selectedRole = Rxn<Role>();
  var detailErrorMessage = ''.obs;
  var isDetailLoading = false.obs;
  final Set<int> _requestedRoleDetails = <int>{};
  var rolesCount = 0.obs;
  var isLoading = false.obs;
  var isSaving = false.obs;
  final _pendingDescriptionSave = Rxn<_PendingRoleDescriptionSave>();

  bool get hasPendingDescriptionSave => _pendingDescriptionSave.value != null;

  RxMap<int, Map<String, dynamic>> get roleDescriptions =>
      _roleDescriptionCache;

  int? get pendingDescriptionRoleId => _pendingDescriptionSave.value?.roleId;

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

  Future<void> fetchRoleById(int roleId) async {
    if (isDetailLoading.value) return;
    try {
      isDetailLoading.value = true;
      detailErrorMessage.value = '';
      final token = await _getToken();
      if (token == null) throw Exception('Authentication required');
      final role = await _roleService.getRoleById(token, roleId);
      selectedRole.value = role;
      final index = roles.indexWhere((item) => item.id == roleId);
      if (index == -1) {
        roles.add(role);
      } else {
        roles[index] = role;
      }
    } catch (e) {
      detailErrorMessage.value = _extractErrorMessage(e);
    } finally {
      isDetailLoading.value = false;
    }
  }

  Future<Map<String, dynamic>?> fetchRoleDescription(int roleId) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Authentication required');
      return await _roleService.getRoleDescription(token, roleId);
    } catch (e) {
      log('Error fetching role description: $e');
      if (e.toString().contains('API Error: 404')) return null;
      rethrow;
    }
  }

  void requestRoleDescription(int roleId) {
    if (_requestedRoleDescriptions.add(roleId)) {
      _loadRoleDescription(roleId);
    }
  }

  Future<void> _loadRoleDescription(int roleId) async {
    try {
      final description = await fetchRoleDescription(roleId);
      if (description != null && !roleDescriptions.containsKey(roleId)) {
        roleDescriptions[roleId] = description;
      }
    } catch (e) {
      log('Could not cache role description for role $roleId: $e');
    }
  }

  void _storeRoleDescription(int roleId, Map<String, dynamic> description) {
    roleDescriptions[roleId] = description;
    _requestedRoleDescriptions.add(roleId);
  }

  void requestRoleDetails(int roleId) {
    if (_requestedRoleDetails.add(roleId)) {
      fetchRoleById(roleId);
    }
  }

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
    String? mission,
    String? jobDescription,
    String? responsibilities,
    required List<int> branchIds,
    required Map<String, List<String>> permissions,
    int? reportsToRoleId,
  }) async {
    try {
      isSaving.value = true;
      _pendingDescriptionSave.value = null;
      final token = await _getToken();
      if (token == null) return false;

      final role = await _roleService.createRole(token, {
        'name': name,
        'branch_ids': branchIds,
        'permissions': permissions,
      });

      await fetchRoles();

      if (mission != null &&
          jobDescription != null &&
          responsibilities != null) {
        try {
          final description = await _roleService.createRoleDescription(
            token,
            role.id,
            purpose: mission,
            jobDescription: jobDescription,
            responsibilities: responsibilities,
          );
          _storeRoleDescription(role.id, description);
        } catch (e) {
          _pendingDescriptionSave.value = _PendingRoleDescriptionSave(
            roleId: role.id,
            purpose: mission,
            jobDescription: jobDescription,
            responsibilities: responsibilities,
          );
          _showError(context,
              'Role created, but its description could not be saved. Retry the description save.');
          return false;
        }
      }

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
    String? mission,
    String? jobDescription,
    String? responsibilities,
    List<int>? branchIds,
    Map<String, List<String>>? permissions,
    int? reportsToRoleId,
  }) async {
    try {
      isSaving.value = true;
      _pendingDescriptionSave.value = null;
      final token = await _getToken();
      if (token == null) return false;

      await _roleService.updateRole(token, roleId, {
        if (name != null) 'name': name,
        if (branchIds != null) 'branch_ids': branchIds,
        if (permissions != null) 'permissions': permissions,
      });

      await fetchRoles();

      if (mission != null &&
          jobDescription != null &&
          responsibilities != null) {
        try {
          final description = await _roleService.saveRoleDescription(
            token,
            roleId,
            purpose: mission,
            jobDescription: jobDescription,
            responsibilities: responsibilities,
          );
          _storeRoleDescription(roleId, description);
        } catch (e) {
          _pendingDescriptionSave.value = _PendingRoleDescriptionSave(
            roleId: roleId,
            purpose: mission,
            jobDescription: jobDescription,
            responsibilities: responsibilities,
          );
          _showError(context,
              'Role updated, but its description could not be saved. Retry the description save.');
          return false;
        }
      }

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

  Future<bool> retryPendingRoleDescription(BuildContext context) async {
    final pending = _pendingDescriptionSave.value;
    if (pending == null) return false;

    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return false;

      final description = await _roleService.saveRoleDescription(
        token,
        pending.roleId,
        purpose: pending.purpose,
        jobDescription: pending.jobDescription,
        responsibilities: pending.responsibilities,
      );
      _storeRoleDescription(pending.roleId, description);
      _pendingDescriptionSave.value = null;
      await fetchRoles();

      if (context.mounted) {
        Get.snackbar('Success', 'Role description saved successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade50,
            colorText: Colors.green.shade800);
      }
      return true;
    } catch (e) {
      log('Error retrying role description: $e');
      if (context.mounted) {
        _showError(context,
            'The role description could not be saved. Please try again.');
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

  void _showError(BuildContext context, String message) {
    if (!context.mounted) return;
    Get.snackbar('Error', message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade800);
  }
}
