import 'package:bms_front_end/pages/operations/models/models.dart';
import 'package:bms_front_end/components/feedback/app_toast.dart';
import 'package:bms_front_end/src/constants/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../../../src/services/operations/works_services.dart';

class WorksiteController extends GetxController {
  final WorksiteService _service =
      WorksiteService(baseUrl: ApiConstants.operationsBaseUrl);
  final _storage = const FlutterSecureStorage();

  var worksites = <Worksite>[].obs;
  var isLoading = false.obs;
  var isActionLoading = false.obs;
  var errorMessage = ''.obs;
  var totalCount = 0.obs;
  var currentSearch = ''.obs;

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

  void _showSuccess(BuildContext context, String message) {
    AppToast.success(context, message);
  }

  Future<void> fetchWorksites(BuildContext context,
      {int? projectId, String? search}) async {
    try {
      if (search != null) {
        currentSearch.value = search;
        currentOffset.value = 0;
      }
      isLoading.value = true;
      errorMessage.value = '';

      final token = await _getToken(context);
      if (token == null) throw Exception("Authentication token not found");

      final result = await _service.getWorksites(
        accessToken: token,
        projectId: projectId,
        search: currentSearch.value.isEmpty ? null : currentSearch.value,
        limit: currentLimit.value,
        offset: currentOffset.value,
      );

      worksites.assignAll(result.items);
      totalCount.value = result.count;
    } catch (e) {
      errorMessage.value = e.toString();
      _showError(context, "Error loading worksites: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createWorksite(BuildContext context, Worksite worksite) async {
    try {
      isActionLoading.value = true;
      final token = await _getToken(context);
      if (token == null) throw Exception("Authentication token not found");

      await _service.createWorksite(accessToken: token, worksite: worksite);

      _showSuccess(context, "Worksite added successfully");
      Navigator.of(context).pop();

      if (worksite.projectId != 0) {
        fetchWorksites(context, projectId: worksite.projectId);
      }
    } catch (e) {
      _showError(context, "Failed to add worksite: ${e.toString()}");
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> updateWorksite(
      BuildContext context, int id, Worksite worksite) async {
    try {
      isActionLoading.value = true;
      final token = await _getToken(context);
      if (token == null) throw Exception("Authentication token not found");

      await _service.updateWorksite(
          accessToken: token, worksiteId: id, worksite: worksite);

      _showSuccess(context, "Worksite updated successfully");
      Navigator.of(context).pop();
      if (worksite.projectId != 0) {
        fetchWorksites(context, projectId: worksite.projectId);
      }
    } catch (e) {
      _showError(context, "Failed to update worksite: ${e.toString()}");
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> deleteWorksite(
      BuildContext context, int id, int projectId) async {
    try {
      isActionLoading.value = true;
      final token = await _getToken(context);
      if (token == null) throw Exception("Authentication token not found");

      await _service.deleteWorksite(accessToken: token, worksiteId: id);

      _showSuccess(context, "Worksite deleted successfully");

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      fetchWorksites(context, projectId: projectId);
    } catch (e) {
      _showError(context, "Failed to delete worksite: ${e.toString()}");
    } finally {
      isActionLoading.value = false;
    }
  }
}
