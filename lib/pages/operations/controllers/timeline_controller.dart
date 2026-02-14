import 'package:bms_front_end/pages/operations/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../../../src/services/operations/timeline_services.dart';

class TimelineController extends GetxController {
  final TimelineService _service =
      TimelineService(baseUrl: 'https://bomachoperations.bgbot.app');
  final _storage = const FlutterSecureStorage();

  var timelines = <TimelineModel>[].obs;
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
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> fetchTimelines(BuildContext context,
      {int? projectId, String? search}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final token = await _getToken(context);
      if (token == null) throw Exception("Authentication token not found");

      final result = await _service.getTimelines(
        accessToken: token,
        projectId: projectId,
        search: search,
        limit: currentLimit.value,
        offset: currentOffset.value,
      );

      timelines.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString();
      _showError(context, "Error loading timelines: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createTimeline(
      BuildContext context, TimelineModel timeline) async {
    try {
      isActionLoading.value = true;
      final token = await _getToken(context);
      if (token == null) throw Exception("Authentication token not found");

      await _service.createTimeline(accessToken: token, timeline: timeline);

      _showSuccess(context, "Timeline phase created successfully");
      Navigator.of(context).pop();

      fetchTimelines(context,
          projectId: timeline.projectId != 0 ? timeline.projectId : null);
    } catch (e) {
      _showError(context, "Failed to create timeline: ${e.toString()}");
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> updateTimeline(
      BuildContext context, int id, TimelineModel timeline) async {
    try {
      isActionLoading.value = true;
      final token = await _getToken(context);
      if (token == null) throw Exception("Authentication token not found");

      await _service.updateTimeline(
          accessToken: token, timelineId: id, timeline: timeline);

      _showSuccess(context, "Timeline updated successfully");
      Navigator.of(context).pop();

      fetchTimelines(context,
          projectId: timeline.projectId != 0 ? timeline.projectId : null);
    } catch (e) {
      _showError(context, "Failed to update timeline: ${e.toString()}");
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> deleteTimeline(
      BuildContext context, int id, int? projectId) async {
    try {
      isActionLoading.value = true;
      final token = await _getToken(context);
      if (token == null) throw Exception("Authentication token not found");

      await _service.deleteTimeline(accessToken: token, timelineId: id);

      _showSuccess(context, "Timeline deleted successfully");

      if (Navigator.canPop(context)) {}

      fetchTimelines(context, projectId: projectId);
    } catch (e) {
      _showError(context, "Failed to delete timeline: ${e.toString()}");
    } finally {
      isActionLoading.value = false;
    }
  }
}
