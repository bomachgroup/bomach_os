import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../src/model/employees_model.dart';
import '../../../src/services/employees_services.dart';

class AssociatesController extends GetxController {
  final EmployeeService _service = EmployeeService();

  var isLoading = false.obs;
  var isSaving = false.obs;
  var associateList = <Employee>[].obs;
  var errorMessage = ''.obs;

  int limit = 100;
  int offset = 0;

  final List<String> associateRoles = [
    'surveyor-associate',
    'lawyer-associate',
    'architect-associate',
    'engineer-associate'
  ];

  Future<void> fetchAssociates(String token) async {
    try {
      isLoading(true);
      errorMessage('');

      final result = await _service.getEmployees(token,
          limit: 1000, offset: offset, employmentType: '');

      final filtered = result.list.where((e) {
        final role = e.employmentType?.toLowerCase() ?? '';
        return associateRoles.contains(role);
      }).toList();

      associateList.assignAll(filtered);
    } catch (e) {
      errorMessage(
          'Failed to load associates: ${e.toString().replaceAll("Exception: ", "")}');
      debugPrint("Fetch Error: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<bool> createAssociate(String token, Employee employee,
      {String? password}) async {
    try {
      isSaving(true);
      await _service.createEmployee(token, employee, password: password);
      await fetchAssociates(token); 
      return true;
    } catch (e) {
      debugPrint("Create Error: $e");
      return false;
    } finally {
      isSaving(false);
    }
  }

  Future<bool> updateAssociate(
      String token, String id, Employee employee) async {
    try {
      isSaving(true);
      await _service.updateEmployee(token, id, employee);
      await fetchAssociates(token);
      return true;
    } catch (e) {
      debugPrint("Update Error: $e");
      return false;
    } finally {
      isSaving(false);
    }
  }
}
