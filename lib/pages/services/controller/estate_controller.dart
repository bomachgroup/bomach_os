import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import 'package:bms_front_end/pages/services/models/estate_models.dart';
import 'package:bms_front_end/src/services/estate_service.dart';

class EstateController extends GetxController {
  final EstateService _service = EstateService();
  final _storage = const FlutterSecureStorage();

  var estates = <Estate>[].obs;
  var estateCount = 0.obs;
  var isLoading = false.obs;

  var searchQuery = ''.obs;
  var statusFilter = ''.obs;
  var currentPage = 1.obs;
  var limit = 20.obs;

  @override
  void onInit() {
    super.onInit();
    fetchEstates();
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
