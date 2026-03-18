import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:bms_front_end/src/model/role_model.dart';
import 'package:bms_front_end/src/model/departments_units_model.dart';
import 'package:bms_front_end/src/services/role_service.dart';
import 'package:bms_front_end/src/services/employees_services.dart';

class RolesController extends GetxController {
  final RoleService _roleService = RoleService();
  final EmployeeService _employeeService = EmployeeService();
  final _storage = const FlutterSecureStorage();

  // ─── Observable state ─────────────────────────────────────────────

  var roles = <Role>[].obs;
  var rolesCount = 0.obs;
  var isLoading = false.obs;
  var isSaving = false.obs;

  // Dependencies for the create/edit dialog
  var permissionsMap = <String, List<String>>{}.obs;
  var departments = <Department>[].obs;
  var departmentUnits = <DepartmentUnit>[].obs;
  var employeeLevels = <dynamic>[].obs;

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
        _employeeService.getDepartments(token),
        _employeeService.getEmployeeLevels(token),
      ]);

      permissionsMap.assignAll(results[0] as Map<String, List<String>>);
      departments.assignAll(results[1] as List<Department>);
      employeeLevels.assignAll(results[2] as List<dynamic>);
    } catch (e) {
      log('Error fetching dependencies: $e');
    } finally {
      isDepsLoading.value = false;
    }
  }

  Future<void> fetchUnitsForDepartment(int? departmentId) async {
    try {
      if (departmentId == null) {
        departmentUnits.clear();
        return;
      }
      final token = await _getToken();
      if (token == null) return;

      final units = await _employeeService.getDepartmentUnits(
        token,
        departmentId: departmentId.toString(),
      );
      departmentUnits.assignAll(units);
    } catch (e) {
      log('Error fetching units: $e');
      departmentUnits.clear();
    }
  }

  // ─── CRUD operations ──────────────────────────────────────────────

  Future<bool> createRole(
    BuildContext context, {
    required String name,
    int? levelId,
    int? departmentId,
    int? unitId,
    required Map<String, List<String>> permissions,
  }) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return false;

      await _roleService.createRole(token, {
        'name': name,
        if (levelId != null) 'level_id': levelId,
        if (departmentId != null) 'department_id': departmentId,
        if (unitId != null) 'unit_id': unitId,
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
        Get.snackbar('Error', 'Failed to create role: $e',
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
    int? levelId,
    int? departmentId,
    int? unitId,
    Map<String, List<String>>? permissions,
  }) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return false;

      await _roleService.updateRole(token, roleId, {
        if (name != null) 'name': name,
        'level_id': levelId,
        'department_id': departmentId,
        'unit_id': unitId,
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
        Get.snackbar('Error', 'Failed to update role: $e',
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
        Get.snackbar('Error', 'Failed to delete role: $e',
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
}
