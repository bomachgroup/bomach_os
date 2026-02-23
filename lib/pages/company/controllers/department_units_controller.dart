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
  static const int itemsPerPage = 10;

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
      print("Error fetching data: $e");
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
    final startIdx = currentPage.value * itemsPerPage;
    if (startIdx >= filtered.length) return [];
    final endIdx = (startIdx + itemsPerPage).clamp(0, filtered.length);
    return filtered.sublist(startIdx, endIdx);
  }

  List<DepartmentUnit> get paginatedUnits {
    final filtered = _allFilteredUnits;
    final startIdx = currentPage.value * itemsPerPage;
    if (startIdx >= filtered.length) return [];
    final endIdx = (startIdx + itemsPerPage).clamp(0, filtered.length);
    return filtered.sublist(startIdx, endIdx);
  }

  int get totalDepartmentsFiltered => _allFilteredDepartments.length;
  int get totalUnitsFiltered => _allFilteredUnits.length;
  int get totalPages {
    final total = currentTab.value == 'Departments'
        ? totalDepartmentsFiltered
        : totalUnitsFiltered;
    return total == 0 ? 1 : (total / itemsPerPage).ceil();
  }

  // --- CRUD OPERATIONS ---

  Future<bool> createDepartment({
    required String name,
    required String description,
    String? company,
    String? branch,
    String? hod,
    String? status,
  }) async {
    isSaving.value = true;
    try {
      final token = await _getToken();
      if (token == null) return false;

      await _service.createDepartment(token, name, description);
      await fetchData(); // Refresh to show new item
      return true;
    } catch (e) {
      print('Failed to create department: $e');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> createUnit({
    required String name,
    required String description,
    required String departmentId,
    String? hod,
    String? status,
  }) async {
    isSaving.value = true;
    try {
      final token = await _getToken();
      if (token == null) return false;

      final unit = DepartmentUnit(
          name: name, description: description, departmentId: departmentId);
      await _service.createDepartmentUnit(token, unit);
      await fetchData();
      return true;
    } catch (e) {
      print('Failed to create unit: $e');
      return false;
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
    if (status?.toLowerCase() == 'inactive') return const Color(0xFFEF4444);
    return const Color(0xFF22C55E); // Default Active Green
  }

  Color getStatusBg(String? status) {
    if (status?.toLowerCase() == 'inactive') return const Color(0xFFFEE2E2);
    return const Color(0xFFDCFCE7);
  }

  // Check if can navigate
  bool get canGoPrevious => currentPage.value > 0;
  bool get canGoNext => currentPage.value < totalPages - 1;
}
