import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../../pages/hr/models/training_program_model.dart';
import '../../../src/services/hr/training_program_services.dart';

class TrainingProgramController extends GetxController {
  final TrainingProgramService _service = TrainingProgramService();

  var isLoading = false.obs;
  var isSaving = false.obs;
  var programList = <TrainingProgram>[].obs;
  var errorMessage = ''.obs;

  int limit = 100;
  int offset = 0;

  Future<void> fetchPrograms(String token) async {
    try {
      isLoading(true);
      errorMessage('');
      final result = await _service.getTrainingPrograms(
        token,
        limit: limit,
        offset: offset,
      );
      programList.assignAll(result);
    } catch (e) {
      errorMessage('Failed to load programs: $e');
      debugPrint("Fetch Error: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<bool> createProgram(String token, TrainingProgram program) async {
    try {
      isSaving(true);
      await _service.createTrainingProgram(token, program);
      await fetchPrograms(token);
      return true;
    } catch (e) {
      debugPrint("Create Error: $e");
      return false;
    } finally {
      isSaving(false);
    }
  }

  Future<bool> updateProgram(
      String token, String id, TrainingProgram program) async {
    try {
      isSaving(true);
      await _service.updateTrainingProgram(token, id, program);
      await fetchPrograms(token);
      return true;
    } catch (e) {
      debugPrint("Update Error: $e");
      return false;
    } finally {
      isSaving(false);
    }
  }

  Future<bool> deleteProgram(String token, String id) async {
    try {
      await _service.deleteTrainingProgram(token, id);
      programList.removeWhere((p) => p.id == id);
      return true;
    } catch (e) {
      debugPrint("Delete Error: $e");
      fetchPrograms(token);
      return false;
    }
  }
}
