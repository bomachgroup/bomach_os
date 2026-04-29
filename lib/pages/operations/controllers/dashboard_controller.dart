import 'package:bomach_os/pages/operations/models/models.dart';
import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../../../src/services/operations/operations_services.dart';

class OperationsDashboardController extends GetxController {
  final DashboardService _service =
      DashboardService(baseUrl: ApiConstants.operationsBaseUrl);
  final _storage = const FlutterSecureStorage();

  var stats = Rxn<DashboardStats>();
  var projects = <Project>[].obs;

  var isLoadingStats = false.obs;
  var isLoadingProjects = false.obs;
  var errorMessage = ''.obs;

  var currentLimit = 10.obs;
  var currentOffset = 0.obs;

  Future<String?> _getToken(BuildContext context) async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith("Bearer ")) token = token.replaceFirst("Bearer ", "");
    return token.replaceAll('"', '').trim();
  }

  void _showError(BuildContext context, String message) {
    AppToast.error(context, message);
  }

  Future<void> fetchDashboardData(BuildContext context) async {
    await Future.wait([
      fetchStats(context),
      fetchProjects(context),
    ]);
  }

  Future<void> fetchStats(BuildContext context) async {
    try {
      isLoadingStats.value = true;
      final token = await _getToken(context);
      if (token == null) throw Exception("Authentication token not found");

      final result = await _service.getDashboardStats(accessToken: token);
      stats.value = result;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoadingStats.value = false;
    }
  }

  Future<void> fetchProjects(BuildContext context, {String? search}) async {
    try {
      isLoadingProjects.value = true;
      final token = await _getToken(context);
      if (token == null) throw Exception("Authentication token not found");

      final result = await _service.getProjects(
        accessToken: token,
        limit: currentLimit.value,
        offset: currentOffset.value,
        search: search,
      );

      projects.assignAll(result.items);
    } catch (e) {
      _showError(context, "Failed to load projects: ${e.toString()}");
    } finally {
      isLoadingProjects.value = false;
    }
  }

  Future<void> deleteProject(BuildContext context, int projectId) async {
    try {
      final token = await _getToken(context);
      if (token == null) throw Exception("Authentication token not found");

      await _service.deleteProject(accessToken: token, projectId: projectId);

      AppToast.success(context, 'Project deleted successfully');

      fetchProjects(context);
      fetchStats(context);
    } catch (e) {
      _showError(context, "Failed to delete project: ${e.toString()}");
    }
  }
}
