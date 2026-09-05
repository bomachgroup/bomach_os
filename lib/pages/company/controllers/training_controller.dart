import 'dart:developer';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../../hr/models/training_program_model.dart';
import '../../../src/model/role_training_requirement_model.dart';
import '../../../src/services/role_training_requirement_service.dart';

class TrainingController extends GetxController {
  final RoleTrainingRequirementService _service =
      RoleTrainingRequirementService();
  final _storage = const FlutterSecureStorage();

  var programs = <TrainingProgram>[].obs;
  var requirements = <RoleTrainingRequirement>[].obs;
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

      final result = await _service.listRequirements(
        token,
        roleId: role,
        isActive: true,
        limit: 100,
      );
      requirements.assignAll(result.items);
      programs.assignAll(result.items.map((item) => item.toTrainingProgram()));
    } catch (e) {
      log('TrainingController.fetchPrograms error: $e');
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
