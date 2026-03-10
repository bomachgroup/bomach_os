import 'package:bms_front_end/pages/operations/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../../../src/services/operations/milestone_services.dart';

class MilestoneController extends GetxController {
  final MilestoneService _service =
      MilestoneService(baseUrl: 'https://bomachoperations.bgbot.app');
  final _storage = const FlutterSecureStorage();

  var milestones = <Milestone>[].obs;
  var isLoading = false.obs;
  var isActionLoading = false.obs;
  var errorMessage = ''.obs;

  var currentLimit = 100.obs;
  var currentOffset = 0.obs;

  Future<String?> _getToken(BuildContext context) async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith("Bearer ")) token = token.replaceFirst("Bearer ", "");
    return token.replaceAll('"', '').trim();
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating),
    );
  }

  void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> fetchMilestones(BuildContext context,
      {int? projectId, String? search}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final token = await _getToken(context);
      if (token == null) throw Exception("Authentication token not found");

      final result = await _service.getMilestones(
        accessToken: token,
        projectId: projectId,
        search: search,
        limit: currentLimit.value,
        offset: currentOffset.value,
      );

      milestones.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString();
      _showError(context, "Error loading milestones: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createMilestone(BuildContext context, Milestone milestone) async {
    try {
      isActionLoading.value = true;
      final token = await _getToken(context);
      if (token == null) throw Exception("Authentication token not found");

      await _service.createMilestone(accessToken: token, milestone: milestone);

      _showSuccess(context, "Milestone created successfully");
      Navigator.of(context).pop();

      fetchMilestones(context,
          projectId: milestone.projectId != 0 ? milestone.projectId : null);
    } catch (e) {
      _showError(context, "Failed to create milestone: ${e.toString()}");
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> updateMilestone(
      BuildContext context, int id, Milestone milestone) async {
    try {
      isActionLoading.value = true;
      final token = await _getToken(context);
      if (token == null) throw Exception("Authentication token not found");

      await _service.updateMilestone(
          accessToken: token, milestoneId: id, milestone: milestone);

      _showSuccess(context, "Milestone updated successfully");
      Navigator.of(context).pop();

      fetchMilestones(context,
          projectId: milestone.projectId != 0 ? milestone.projectId : null);
    } catch (e) {
      _showError(context, "Failed to update milestone: ${e.toString()}");
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> deleteMilestone(
      BuildContext context, int id, int? projectId) async {
    try {
      isActionLoading.value = true;
      final token = await _getToken(context);
      if (token == null) throw Exception("Authentication token not found");

      await _service.deleteMilestone(accessToken: token, milestoneId: id);

      _showSuccess(context, "Milestone deleted successfully");

      fetchMilestones(context, projectId: projectId);
    } catch (e) {
      _showError(context, "Failed to delete milestone: ${e.toString()}");
    } finally {
      isActionLoading.value = false;
    }
  }
}
