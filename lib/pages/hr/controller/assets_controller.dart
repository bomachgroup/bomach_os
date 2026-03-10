import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../src/services/hr/asset_services.dart';
import '../../../src/services/employees_services.dart'; 
import '../models/assets_model.dart';

class AssetController extends GetxController {
  final AssetService _service = AssetService();
  final EmployeeService _employeeService = EmployeeService();
  final _storage = const FlutterSecureStorage();

  var isLoading = false.obs;
  var isSaving = false.obs;
  var assetList = <Asset>[].obs;
  var errorMessage = ''.obs;

  // --- FILTERS ---
  var searchString = ''.obs;
  var selectedBranch = 'All'.obs;
  var selectedDepartmentId = 'All'.obs;
  var selectedStatus = 'All'.obs;

  // --- DROPDOWN DATA ---
  var departments = <Map<String, String>>[
    {'id': 'All', 'name': 'All Departments'}
  ].obs;
  // Hardcoded based on AddAssetDialog usage, or could be fetched
  final branches = ['All', 'Enugu Branch', 'Lagos Branch', 'Abuja Branch'];
  final statuses = ['All', 'active', 'in-use', 'maintenance', 'retired'];

  // --- PAGINATION ---
  var currentPage = 1.obs;
  var limit = 10.obs;
  // We assume the API doesn't return total count in the simple list, 
  // so we'll handle "Next" availability based on if we got full limit items.
  var hasMore = true.obs; 

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final token = await _getToken();
    if (token != null) {
      await fetchDepartments(token);
      await fetchAssets();
    }
  }

  // --- ACTIONS ---

  void onSearchChanged(String val) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      searchString.value = val;
      currentPage.value = 1; // Reset to page 1 on search
      fetchAssets();
    });
  }

  void onFilterChanged() {
    currentPage.value = 1;
    fetchAssets();
  }

  void nextPage() {
    if (hasMore.value) {
      currentPage.value++;
      fetchAssets();
    }
  }

  void prevPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      fetchAssets();
    }
  }

  // --- FETCHING ---

  Future<void> fetchDepartments(String token) async {
    try {
      final deptList = await _employeeService.getDepartments(token, limit: 100);
      departments.assignAll([
        {'id': 'All', 'name': 'All Departments'},
        ...deptList.map((d) => {'id': d.id, 'name': d.name}),
      ]);
    } catch (e) {
      debugPrint("Error fetching departments: $e");
    }
  }

  Future<void> fetchAssets() async {
    try {
      isLoading(true);
      errorMessage('');
      
      final token = await _getToken();
      if (token == null) return;

      int offset = (currentPage.value - 1) * limit.value;

      final result = await _service.getAssets(
        token,
        search: searchString.value,
        branch: selectedBranch.value,
        departmentId: selectedDepartmentId.value,
        status: selectedStatus.value,
        limit: limit.value,
        offset: offset,
      );

      if (result.length < limit.value) {
        hasMore.value = false;
      } else {
        hasMore.value = true;
      }

      assetList.assignAll(result);
    } catch (e) {
      errorMessage('Failed to load assets: $e');
      debugPrint("Fetch Error: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<bool> createAsset(String token, Asset asset) async {
    try {
      isSaving(true);
      await _service.createAsset(token, asset);
      await fetchAssets();
      return true;
    } catch (e) {
      debugPrint("Create Error: $e");
      return false;
    } finally {
      isSaving(false);
    }
  }

  Future<bool> updateAsset(String token, String id, Asset asset) async {
    try {
      isSaving(true);
      await _service.updateAsset(token, id, asset);
      await fetchAssets(); 
      return true;
    } catch (e) {
      debugPrint("Update Error: $e");
      return false;
    } finally {
      isSaving(false);
    }
  }

  Future<bool> deleteAsset(String token, String id) async {
    try {
      await _service.deleteAsset(token, id);
      assetList.removeWhere((a) => a.id == id);
      // Optional: Refetch to maintain page size
      fetchAssets();
      return true;
    } catch (e) {
      debugPrint("Delete Error: $e");
      return false;
    }
  }

  Future<String?> _getToken() async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith("Bearer ")) token = token.replaceFirst("Bearer ", "");
    return token.replaceAll('"', '').trim();
  }
}