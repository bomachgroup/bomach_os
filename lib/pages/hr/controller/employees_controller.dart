import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../src/model/employees_model.dart';
import '../../../src/services/employees_services.dart';

class EmployeeController extends GetxController {
  final EmployeeService _service = EmployeeService();

  // Loading & Error State
  var isLoading = false.obs;
  var isSaving = false.obs;
  var errorMessage = ''.obs;

  // Data State
  var employeeList = <Employee>[].obs;
  
  // Filter State
  var currentIsActive = true.obs; // Default to Active

  // Pagination State
  var currentPage = 1.obs;
  var limit = 10.obs;     
  var totalItems = 0.obs; 

  // Search State
  var searchQuery = ''.obs;
  Timer? _debounce;

  Future<void> fetchEmployees(String token) async {
    try {
      isLoading(true);
      errorMessage('');
      
      // Calculate offset
      int offset = (currentPage.value - 1) * limit.value;

      // Pass currentIsActive.value to the service
      final result = await _service.getEmployees(
        token,
        limit: limit.value,
        offset: offset,
        isActive: currentIsActive.value, 
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
      );
      employeeList.assignAll(result.list);
      totalItems.value = result.count; 

    } catch (e) {
      errorMessage('Failed to load employees: $e');
      debugPrint("Fetch Error: $e");
    } finally {
      isLoading(false);
    }
  }

  // --- Actions ---

  void changePage(String token, int newPage) {
    currentPage.value = newPage;
    fetchEmployees(token);
  }

  void changeLimit(String token, int newLimit) {
    limit.value = newLimit;
    currentPage.value = 1; // Reset to page 1
    fetchEmployees(token);
  }

  void onSearchChanged(String token, String val) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      searchQuery.value = val;
      currentPage.value = 1; 
      fetchEmployees(token);
    });
  }

  // New Method for Tab Switching
  void filterByStatus(String token, bool isActive) {
    currentIsActive.value = isActive;
    currentPage.value = 1; // Reset pagination when switching tabs
    fetchEmployees(token);
  }

  Future<bool> createEmployee(String token, Employee employee, {String? password}) async {
    try {
      isSaving(true);
      await _service.createEmployee(token, employee, password: password);
      await fetchEmployees(token); 
      return true;
    } catch (e) {
      debugPrint("Create Error: $e");
      return false;
    } finally {
      isSaving(false);
    }
  }

  Future<bool> updateEmployee(String token, String id, Employee employee) async {
    try {
      isSaving(true);
      await _service.updateEmployee(token, id, employee);
      await fetchEmployees(token);
      return true;
    } catch (e) {
      debugPrint("Update Error: $e");
      return false;
    } finally {
      isSaving(false);
    }
  }  
  
  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}