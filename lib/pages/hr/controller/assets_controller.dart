import 'dart:developer';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../src/model/employees_model.dart';
import '../../../src/services/hr/asset_services.dart';
import '../../../src/services/employees_services.dart';
import '../models/assets_model.dart';

class AssetController extends GetxController {
  final AssetService _service = AssetService();
  final EmployeeService _employeeService = EmployeeService();
  final _storage = const FlutterSecureStorage();

  // ─── Loading state ────────────────────────────────────────────────
  var isLoading = true.obs;
  var isSaving = false.obs;

  // ─── Asset list ───────────────────────────────────────────────────
  var assetList = <Asset>[].obs;
  var searchQuery = ''.obs;
  var currentPage = 1.obs;
  var limit = 10.obs;
  var totalItems = 0.obs;

  // ─── Dropdown data ────────────────────────────────────────────────
  var departments = <Map<String, String>>[
    {'id': 'All', 'name': 'All Departments'}
  ].obs;
  var allEmployees = <Employee>[].obs;
  final branches = ['All', 'Enugu Branch', 'Lagos Branch', 'Abuja Branch'];
  final statuses = ['All', 'active', 'in-use', 'maintenance', 'retired'];

  // ─── Filters ──────────────────────────────────────────────────────
  var selectedBranch = 'All'.obs;
  var selectedDepartmentId = 'All'.obs;
  var selectedStatus = 'All'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final token = await _getToken();
    if (token != null) {
      await Future.wait([
        fetchDepartments(token),
        _fetchAllEmployees(token),
      ]);
    }
    await fetchAssets();
  }

  Future<void> _fetchAllEmployees(String token) async {
    try {
      final result = await _employeeService.getEmployees(token, limit: 500);
      allEmployees.assignAll(result.list);
    } catch (e) {
      log("Error fetching employees for dropdown: $e");
    }
  }

  // ─── FETCH ────────────────────────────────────────────────────────

  Future<void> fetchAssets({bool refresh = false}) async {
    try {
      if (!refresh) isLoading.value = true;

      final token = await _getToken();
      if (token == null) return;

      final offset = (currentPage.value - 1) * limit.value;

      final result = await _service.getAssets(
        token,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        branch: selectedBranch.value,
        departmentId: selectedDepartmentId.value,
        status: selectedStatus.value,
        limit: limit.value,
        offset: offset,
      );

      assetList.assignAll(result.items);
      totalItems.value = result.total;
    } catch (e) {
      log("Error fetching assets: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchDepartments(String token) async {
    try {
      final deptList = await _employeeService.getDepartments(token, limit: 100);
      departments.assignAll([
        {'id': 'All', 'name': 'All Departments'},
        ...deptList.map((d) => {'id': d.id, 'name': d.name}),
      ]);
    } catch (e) {
      log("Error fetching departments: $e");
    }
  }

  // ─── CREATE ───────────────────────────────────────────────────────

  Future<void> createAsset(
      BuildContext context, Map<String, dynamic> data) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return;

      log("Create Asset payload: $data");
      await _service.createAsset(token, data);

      if (context.mounted) {
        Navigator.pop(context);
        fetchAssets(refresh: true);
        _showSnackBar(context, "Asset created successfully");
      }
    } catch (e) {
      log("Create Asset Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to create asset: ${e.toString()}");
      }
    } finally {
      isSaving.value = false;
    }
  }

  // ─── UPDATE ───────────────────────────────────────────────────────

  Future<void> updateAsset(
      BuildContext context, String id, Map<String, dynamic> data) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return;

      log("Update Asset payload: $data");
      await _service.updateAsset(token, id, data);

      if (context.mounted) {
        Navigator.pop(context);
        fetchAssets(refresh: true);
        _showSnackBar(context, "Asset updated successfully");
      }
    } catch (e) {
      log("Update Asset Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to update asset");
      }
    } finally {
      isSaving.value = false;
    }
  }

  // ─── DELETE ───────────────────────────────────────────────────────

  Future<void> deleteAsset(BuildContext context, String id) async {
    try {
      final token = await _getToken();
      if (token == null) return;

      await _service.deleteAsset(token, id);

      if (context.mounted) {
        fetchAssets(refresh: true);
        _showSnackBar(context, "Asset deleted successfully");
      }
    } catch (e) {
      log("Delete Asset Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to delete asset");
      }
    }
  }

  // ─── SEARCH / FILTER ─────────────────────────────────────────────

  void onSearchChanged(String val) {
    searchQuery.value = val;
    currentPage.value = 1;
    fetchAssets();
  }

  void onFilterChanged() {
    currentPage.value = 1;
    fetchAssets();
  }

  // ─── PAGINATION ──────────────────────────────────────────────────

  void goToPage(int page) {
    currentPage.value = page;
    fetchAssets();
  }

  void setLimit(int newLimit) {
    limit.value = newLimit;
    currentPage.value = 1;
    fetchAssets();
  }

  // ─── HELPERS ─────────────────────────────────────────────────────

  Future<String?> _getToken() async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith("Bearer ")) {
      token = token.replaceFirst("Bearer ", "");
    }
    return token.replaceAll('"', '').trim();
  }

  void _showSnackBar(BuildContext context, String message) {
    AppToast.success(context, message);
  }

  void _showErrorDialog(BuildContext context, String message) {
    DialogScaffold.show(
      context,
      title: "Error",
      size: DialogSize.sm,
      body: Text(message),
      actions: [TextButton(
              onPressed: () => Navigator.pop(context), child: const Text("OK")),],
    );
  }
}
