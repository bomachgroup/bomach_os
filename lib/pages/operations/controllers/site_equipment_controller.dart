import 'package:bms_front_end/pages/operations/models/models.dart';
import 'package:bms_front_end/src/constants/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../../../src/services/operations/site_equipment_services.dart';

class SiteEquipmentController extends GetxController {
  final SiteEquipmentService _service =
      SiteEquipmentService(baseUrl: ApiConstants.baseUrl);
  final _storage = const FlutterSecureStorage();

  var equipment = <SiteEquipment>[].obs;
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
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  Future<void> fetchEquipment(BuildContext context,
      {int? worksiteId, String? search}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final token = await _getToken(context);
      if (token == null) throw Exception("Authentication token not found");

      final result = await _service.getSiteEquipment(
        accessToken: token,
        worksiteId: worksiteId,
        search: search,
        limit: currentLimit.value,
        offset: currentOffset.value,
      );

      equipment.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString();
      _showError(context, "Error loading equipment: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createEquipment(BuildContext context, SiteEquipment item) async {
    try {
      isActionLoading.value = true;
      final token = await _getToken(context);
      if (token == null) throw Exception("Authentication token not found");

      await _service.createSiteEquipment(accessToken: token, equipment: item);

      _showSuccess(context, "Equipment added successfully");
      Navigator.of(context).pop();

      fetchEquipment(context,
          worksiteId: item.worksiteId != 0 ? item.worksiteId : null);
    } catch (e) {
      _showError(context, "Failed to add equipment: ${e.toString()}");
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> deleteEquipment(
      BuildContext context, int id, int? worksiteId) async {
    try {
      isActionLoading.value = true;
      final token = await _getToken(context);
      if (token == null) throw Exception("Authentication token not found");

      await _service.deleteSiteEquipment(accessToken: token, equipmentId: id);

      _showSuccess(context, "Equipment deleted successfully");

      fetchEquipment(context, worksiteId: worksiteId);
    } catch (e) {
      _showError(context, "Failed to delete equipment: ${e.toString()}");
    } finally {
      isActionLoading.value = false;
    }
  }
}
