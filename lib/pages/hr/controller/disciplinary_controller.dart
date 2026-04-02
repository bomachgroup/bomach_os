import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../src/services/hr/disciplinary_cases_services.dart';
import '../models/disciplinary_cases_model.dart';

class DisciplinaryController extends GetxController {
  final DisciplinaryCaseService _service = DisciplinaryCaseService();

  var isLoading = false.obs;
  var isSaving = false.obs;
  var caseList = <DisciplinaryCase>[].obs;
  var errorMessage = ''.obs;

  int limit = 100;
  int offset = 0;

  Future<void> fetchCases(String token) async {
    try {
      isLoading(true);
      errorMessage('');
      final result = await _service.getDisciplinaryCases(
        token,
        limit: limit,
        offset: offset,
      );
      caseList.assignAll(result);
    } catch (e) {
      errorMessage('Failed to load cases: $e');
      debugPrint("Fetch Error: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<bool> createCase(String token, DisciplinaryCase kase) async {
    try {
      isSaving(true);
      await _service.createDisciplinaryCase(token, kase);
      await fetchCases(token);
      return true;
    } catch (e) {
      debugPrint("Create Error: $e");
      return false;
    } finally {
      isSaving(false);
    }
  }

  Future<bool> updateCase(
      String token, String id, DisciplinaryCase kase) async {
    try {
      isSaving(true);
      await _service.updateDisciplinaryCase(token, id, kase);
      await fetchCases(token);
      return true;
    } catch (e) {
      debugPrint("Update Error: $e");
      return false;
    } finally {
      isSaving(false);
    }
  }

  Future<bool> deleteCase(String token, String id) async {
    try {
      await _service.deleteDisciplinaryCase(token, id);
      caseList.removeWhere((c) => c.id == id);
      return true;
    } catch (e) {
      debugPrint("Delete Error: $e");
      await fetchCases(token);
      return false;
    }
  }
}
