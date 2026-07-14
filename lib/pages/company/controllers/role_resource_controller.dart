import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../../../src/model/role_resource_models.dart';
import '../../../src/services/role_resource_service.dart';

class RoleResourceController extends GetxController {
  final RoleResourceService _service = RoleResourceService();
  final _storage = const FlutterSecureStorage();

  var physicalResources = <PhysicalResource>[].obs;
  var softwareTools = <SoftwareTool>[].obs;
  var referenceDocuments = <ReferenceDocument>[].obs;
  var technicalSkills = <TechnicalSkill>[].obs;
  var softSkills = <SoftSkill>[].obs;
  var experienceRequirements = <ExperienceRequirement>[].obs;
  var certifications = <Certification>[].obs;

  var isLoading = false.obs;
  var isSaving = false.obs;

  int? scopedRoleId;

  Future<String?> _getToken() async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith('Bearer ')) token = token.substring(7);
    return token.replaceAll('"', '').trim();
  }

  Future<void> fetchAll({int? roleId}) async {
    isLoading.value = true;
    try {
      final token = await _getToken();
      if (token == null) return;
      final role = roleId ?? scopedRoleId;
      if (role == null) return;

      final r0 = await _service.listPhysicalResources(token, roleId: role);
      final r1 = await _service.listSoftwareTools(token, roleId: role);
      final r2 = await _service.listReferenceDocuments(token, roleId: role);
      final r3 = await _service.listTechnicalSkills(token, roleId: role);
      final r4 = await _service.listSoftSkills(token, roleId: role);
      final r5 = await _service.listExperienceRequirements(token, roleId: role);
      final r6 = await _service.listCertifications(token, roleId: role);

      physicalResources.assignAll(r0.list);
      softwareTools.assignAll(r1.list);
      referenceDocuments.assignAll(r2.list);
      technicalSkills.assignAll(r3.list);
      softSkills.assignAll(r4.list);
      experienceRequirements.assignAll(r5.list);
      certifications.assignAll(r6.list);
    } catch (e) {
      log('RoleResourceController.fetchAll error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> create(BuildContext context, ResourceType type, Map<String, dynamic> payload) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return false;

      payload['role_id'] = scopedRoleId ?? payload['role_id'];

      switch (type) {
        case ResourceType.physicalResource:
          await _service.createPhysicalResource(token, payload);
          final r = await _service.listPhysicalResources(token, roleId: scopedRoleId);
          physicalResources.assignAll(r.list);
        case ResourceType.softwareTool:
          await _service.createSoftwareTool(token, payload);
          final r = await _service.listSoftwareTools(token, roleId: scopedRoleId);
          softwareTools.assignAll(r.list);
        case ResourceType.referenceDocument:
          await _service.createReferenceDocument(token, payload);
          final r = await _service.listReferenceDocuments(token, roleId: scopedRoleId);
          referenceDocuments.assignAll(r.list);
        case ResourceType.technicalSkill:
          await _service.createTechnicalSkill(token, payload);
          final r = await _service.listTechnicalSkills(token, roleId: scopedRoleId);
          technicalSkills.assignAll(r.list);
        case ResourceType.softSkill:
          await _service.createSoftSkill(token, payload);
          final r = await _service.listSoftSkills(token, roleId: scopedRoleId);
          softSkills.assignAll(r.list);
        case ResourceType.experienceRequirement:
          await _service.createExperienceRequirement(token, payload);
          final r = await _service.listExperienceRequirements(token, roleId: scopedRoleId);
          experienceRequirements.assignAll(r.list);
        case ResourceType.certification:
          await _service.createCertification(token, payload);
          final r = await _service.listCertifications(token, roleId: scopedRoleId);
          certifications.assignAll(r.list);
      }

      if (context.mounted) {
        Get.snackbar('Success', 'Created successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade50,
            colorText: Colors.green.shade800);
      }
      return true;
    } catch (e) {
      log('RoleResourceController.create error: $e');
      if (context.mounted) {
        Get.snackbar('Error', 'Failed to create: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade50,
            colorText: Colors.red.shade800);
      }
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> delete(BuildContext context, ResourceType type, int id) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      switch (type) {
        case ResourceType.physicalResource:
          await _service.deletePhysicalResource(token, id);
          physicalResources.removeWhere((r) => r.id == id);
        case ResourceType.softwareTool:
          await _service.deleteSoftwareTool(token, id);
          softwareTools.removeWhere((r) => r.id == id);
        case ResourceType.referenceDocument:
          await _service.deleteReferenceDocument(token, id);
          referenceDocuments.removeWhere((r) => r.id == id);
        case ResourceType.technicalSkill:
          await _service.deleteTechnicalSkill(token, id);
          technicalSkills.removeWhere((r) => r.id == id);
        case ResourceType.softSkill:
          await _service.deleteSoftSkill(token, id);
          softSkills.removeWhere((r) => r.id == id);
        case ResourceType.experienceRequirement:
          await _service.deleteExperienceRequirement(token, id);
          experienceRequirements.removeWhere((r) => r.id == id);
        case ResourceType.certification:
          await _service.deleteCertification(token, id);
          certifications.removeWhere((r) => r.id == id);
      }

      if (context.mounted) {
        Get.snackbar('Success', 'Deleted successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade50,
            colorText: Colors.green.shade800);
      }
      return true;
    } catch (e) {
      log('RoleResourceController.delete error: $e');
      return false;
    }
  }
}
