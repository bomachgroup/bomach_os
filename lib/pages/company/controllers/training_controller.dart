import 'dart:developer';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../../hr/models/training_program_model.dart';
import '../../../src/services/hr/training_program_services.dart';

class TrainingController extends GetxController {
  final TrainingProgramService _service = TrainingProgramService();
  final _storage = const FlutterSecureStorage();

  var programs = <TrainingProgram>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  int? scopedRoleId;

  Future<String?> _getToken() async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith('Bearer ')) token = token.substring(7);
    return token.replaceAll('"', '').trim();
  }

  Future<void> fetchPrograms({int? roleId}) async {
    isLoading.value = true;
    try {
      final token = await _getToken();
      if (token == null) return;

      final role = roleId ?? scopedRoleId;
      if (role == null) return;

      final result = await _service.getTrainingPrograms(
        token,
        limit: 100,
      );

      final rolePrograms = result.items.where((p) {
        final audience = p.targetAudience.toLowerCase();
        return audience.contains(role.toString()) ||
            audience.contains('all') ||
            audience.contains('role');
      }).toList();

      programs.assignAll(rolePrograms);
    } catch (e) {
      log('TrainingController.fetchPrograms error: $e');
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
