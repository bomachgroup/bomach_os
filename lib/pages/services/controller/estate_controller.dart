import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import 'package:bomach_os/pages/services/models/estate_models.dart';
import 'package:bomach_os/src/services/estate_service.dart';

class EstateController extends GetxController {
  final EstateService _service = EstateService();
  final _storage = const FlutterSecureStorage();

  var estates = <Estate>[].obs;
  var estateCount = 0.obs;
  var isLoading = false.obs;
  var isSaving = false.obs;

  // Field choices for dropdowns
  var estateTypes = <Map<String, dynamic>>[].obs;
  var estateStatuses = <Map<String, dynamic>>[].obs;
  var areaUnits = <Map<String, dynamic>>[].obs;

  var searchQuery = ''.obs;
  var statusFilter = ''.obs;
  var currentPage = 1.obs;
  var limit = 20.obs;

  @override
  void onInit() {
    super.onInit();
    fetchEstates();
    fetchFieldChoices();
  }

  Future<String?> _getToken() => _storage.read(key: 'access_token');

  Future<void> fetchEstates() async {
    try {
      isLoading.value = true;
      final token = await _getToken();
      if (token == null) return;

      final result = await _service.getEstates(
        token,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        estateStatus: statusFilter.value.isEmpty ? null : statusFilter.value,
        limit: limit.value,
        offset: (currentPage.value - 1) * limit.value,
      );

      estates.assignAll(result.items);
      estateCount.value = result.count;
    } catch (e) {
      log('Error fetching estates: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchFieldChoices() async {
    try {
      final token = await _getToken();
      if (token == null) return;

      final choices = await _service.getFieldChoices(token);
      estateTypes.assignAll(choices['estate_type'] ?? []);
      estateStatuses.assignAll(choices['estate_status'] ?? []);
      areaUnits.assignAll(choices['area_unit'] ?? []);
    } catch (e) {
      log('Error fetching field choices: $e');
    }
  }

  Future<bool> createEstate(
      BuildContext context, Map<String, dynamic> payload) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return false;

      await _service.createEstate(token, payload);
      await fetchEstates();

      if (context.mounted) {
        Get.snackbar('Success', 'Estate created successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade50,
            colorText: Colors.green.shade800);
      }
      return true;
    } catch (e) {
      log('Error creating estate: $e');
      if (context.mounted) {
        final msg = e.toString();
        final dashIdx = msg.lastIndexOf(' - ');
        final cleanMsg = dashIdx != -1
            ? msg.substring(dashIdx + 3)
            : msg.replaceFirst('Exception: ', '');
        Get.snackbar('Error', cleanMsg,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade50,
            colorText: Colors.red.shade800);
      }
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deleteEstate(BuildContext context, int estateId) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      await _service.deleteEstate(token, estateId);
      await fetchEstates();

      if (context.mounted) {
        Get.snackbar('Success', 'Estate deleted',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade50,
            colorText: Colors.green.shade800);
      }
      return true;
    } catch (e) {
      log('Error deleting estate: $e');
      if (context.mounted) {
        Get.snackbar('Error', 'Failed to delete estate',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade50,
            colorText: Colors.red.shade800);
      }
      return false;
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    currentPage.value = 1;
    fetchEstates();
  }

  void onStatusFilterChanged(String status) {
    statusFilter.value = status;
    currentPage.value = 1;
    fetchEstates();
  }

  void onPageChanged(int page) {
    currentPage.value = page;
    fetchEstates();
  }
}
