import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../src/model/employees_model.dart';
import '../../../src/services/employees_services.dart';

class EmployeeController extends GetxController {
  final EmployeeService _service = EmployeeService();

  var isLoading = false.obs;
  var isSaving = false.obs;
  var employeeList = <Employee>[].obs;
  var errorMessage = ''.obs;
  
  int limit = 100;
  int offset = 0;

  Future<void> fetchEmployees(String token) async {
    try {
      isLoading(true);
      errorMessage('');
      final result = await _service.getEmployees(
        token,
        limit: limit,
        offset: offset,
      );
      employeeList.assignAll(result);
    } catch (e) {
      errorMessage('Failed to load employees: $e');
      debugPrint("Fetch Error: $e");
    } finally {
      isLoading(false);
    }
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
}