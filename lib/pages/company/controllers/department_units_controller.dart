import 'dart:developer';
import 'package:bms_front_end/components/feedback/app_toast.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../src/model/departments_units_model.dart';
import '../../../src/services/employees_services.dart';

class DepartmentsUnitsController extends GetxController {
  final EmployeeService _service = EmployeeService();
  final _storage = const FlutterSecureStorage();

  // ONLY reactive properties that need observation
  final currentTab = RxString('Departments');
  final isLoading = RxBool(false);
  final isSaving = RxBool(false);

  // --- FILTERING STATE (use Rx for reactive updates) ---
  final searchString = RxString('');
  final statusFilter = RxString('All');
  final currentPage = RxInt(0);

  // --- DATA STORAGE (use Rx for reactive updates) ---
  final departmentsList = RxList<Department>();
  final unitsList = RxList<DepartmentUnit>();
  final departmentOptions = RxList<Map<String, String>>();

  // Pagination config
  final itemsPerPage = RxInt(10);

  @override
  void onInit() {
    super.onInit();
    fetchData();

    // Listen to search/status changes to reset pagination
    searchString.listen((_) => resetPagination());
    statusFilter.listen((_) => resetPagination());
  }

  // --- DATA FETCHING ---
  Future<void> fetchData() async {
    isLoading.value = true;
    try {
      final token = await _getToken();
      if (token == null) {
        isLoading.value = false;
        return;
      }

      // Fetch ALL data initially
      final results = await Future.wait([
        _service.getDepartments(token, limit: 1000),
        _service.getDepartmentUnits(token, limit: 1000),
      ]);

      departmentsList.assignAll(results[0] as List<Department>);
      unitsList.assignAll(results[1] as List<DepartmentUnit>);

      // Populate dropdown options
      departmentOptions.assignAll(
          departmentsList.map((d) => {"id": d.id, "name": d.name}).toList());

      resetPagination();
    } catch (e) {
      log("Error fetching data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // --- FILTER LOGIC (Client-Side + Pagination) ---

  List<Department> get _allFilteredDepartments {
    return departmentsList.where((d) {
      // 1. Search Filter
      final matchesSearch = searchString.value.isEmpty ||
          d.name.toLowerCase().contains(searchString.value.toLowerCase());

      return matchesSearch;
    }).toList();
  }

  List<DepartmentUnit> get _allFilteredUnits {
    return unitsList.where((u) {
      // 1. Search Filter
      final matchesSearch = searchString.value.isEmpty ||
          u.name.toLowerCase().contains(searchString.value.toLowerCase()) ||
          (u.hod?.toLowerCase().contains(searchString.value.toLowerCase()) ??
              false);

      // 2. Status Filter
      final status = u.status ?? "Active";
      final matchesStatus = statusFilter.value == 'All' ||
          status.toLowerCase() == statusFilter.value.toLowerCase();

      return matchesSearch && matchesStatus;
    }).toList();
  }

  // Paginated results with calculated total pages
  List<Department> get paginatedDepartments {
    final filtered = _allFilteredDepartments;
    final startIdx = currentPage.value * itemsPerPage.value;
    if (startIdx >= filtered.length) return [];
    final endIdx = (startIdx + itemsPerPage.value).clamp(0, filtered.length);
    return filtered.sublist(startIdx, endIdx);
  }

  List<DepartmentUnit> get paginatedUnits {
    final filtered = _allFilteredUnits;
    final startIdx = currentPage.value * itemsPerPage.value;
    if (startIdx >= filtered.length) return [];
    final endIdx = (startIdx + itemsPerPage.value).clamp(0, filtered.length);
    return filtered.sublist(startIdx, endIdx);
  }

  int get totalDepartmentsFiltered => _allFilteredDepartments.length;
  int get totalUnitsFiltered => _allFilteredUnits.length;
  int get totalPages {
    final total = currentTab.value == 'Departments'
        ? totalDepartmentsFiltered
        : totalUnitsFiltered;
    return total == 0 ? 1 : (total / itemsPerPage.value).ceil();
  }

  // --- CRUD OPERATIONS ---

  Future<void> createDepartment(
    BuildContext context, {
    required String name,
    required String description,
  }) async {
    isSaving.value = true;
    try {
      final token = await _getToken();
      if (token == null) return;

      await _service.createDepartment(token, name, description);

      if (context.mounted) {
        Navigator.pop(context);
        fetchData();
        AppToast.success(context, 'Department created successfully');
      }
    } catch (e) {
      log('Failed to create department: $e');
      if (context.mounted) {
        AppToast.error(context, 'Failed to create department: $e');
      }
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> updateDepartment(
    BuildContext context, {
    required String departmentId,
    required String name,
    required String description,
  }) async {
    isSaving.value = true;
    try {
      final token = await _getToken();
      if (token == null) return;

      await _service.updateDepartment(token, departmentId, name, description);

      if (context.mounted) {
        Navigator.pop(context);
        fetchData();
        AppToast.success(context, 'Department updated successfully');
      }
    } catch (e) {
      log('Failed to update department: $e');
      if (context.mounted) {
        AppToast.error(context, 'Failed to update department: $e');
      }
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> createUnit(
    BuildContext context, {
    required String name,
    required String description,
    required String departmentId,
  }) async {
    isSaving.value = true;
    try {
      final token = await _getToken();
      if (token == null) return;

      final unit = DepartmentUnit(
          name: name, description: description, departmentId: departmentId);
      await _service.createDepartmentUnit(token, unit);

      if (context.mounted) {
        Navigator.pop(context);
        fetchData();
        AppToast.success(context, 'Unit created successfully');
      }
    } catch (e) {
      log('Failed to create unit: $e');
      if (context.mounted) {
        AppToast.error(context, 'Failed to create unit: $e');
      }
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> updateUnit(
    BuildContext context, {
    required String unitId,
    required String name,
    required String description,
    required String departmentId,
  }) async {
    isSaving.value = true;
    try {
      final token = await _getToken();
      if (token == null) return;

      final unit = DepartmentUnit(
          name: name, description: description, departmentId: departmentId);
      await _service.updateDepartmentUnit(token, unitId, unit);

      if (context.mounted) {
        Navigator.pop(context);
        fetchData();
        AppToast.success(context, 'Unit updated successfully');
      }
    } catch (e) {
      log('Failed to update unit: $e');
      if (context.mounted) {
        AppToast.error(context, 'Failed to update unit: $e');
      }
    } finally {
      isSaving.value = false;
    }
  }

  Future<String?> _getToken() async {
    return await _storage.read(key: 'access_token');
  }

  // --- HELPERS ---
  int get totalDepartments => departmentsList.length;
  int get totalUnits => unitsList.length;

  void setSearch(String value) {
    searchString.value = value;
  }

  void setStatusFilter(String value) {
    statusFilter.value = value;
  }

  void switchTab(String tab) {
    currentTab.value = tab;
    searchString.value = '';
    statusFilter.value = 'All';
    resetPagination();
  }

  void resetPagination() {
    currentPage.value = 0;
  }

  void setLimit(int newLimit) {
    itemsPerPage.value = newLimit;
    resetPagination();
  }

  void nextPage() {
    if (currentPage.value < totalPages - 1) {
      currentPage.value++;
    }
  }

  void previousPage() {
    if (currentPage.value > 0) {
      currentPage.value--;
    }
  }

  void goToPage(int page) {
    if (page >= 0 && page < totalPages) {
      currentPage.value = page;
    }
  }

  Color getStatusColor(String? status) {
    if (status?.toLowerCase() == 'inactive') return AppColors.danger;
    return AppColors.success; // Default Active Green
  }

  Color getStatusBg(String? status) {
    if (status?.toLowerCase() == 'inactive') return AppColors.dangerSubtle;
    return AppColors.successSubtle;
  }

  // Check if can navigate
  bool get canGoPrevious => currentPage.value > 0;
  bool get canGoNext => currentPage.value < totalPages - 1;
}
