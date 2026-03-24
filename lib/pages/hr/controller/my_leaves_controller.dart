import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';

import '../../../src/services/hr/leave_request_services.dart';
import '../models/leave_request_model.dart';

class MyLeavesController extends GetxController {
  final LeaveRequestService _service = LeaveRequestService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  var isLoading = false.obs;
  var isSaving = false.obs;
  var leaveList = <LeaveRequest>[].obs;
  var totalCount = 0.obs;
  var errorMessage = ''.obs;
  var hasError = false.obs;

  // Pagination
  var currentPage = 1.obs;
  var itemsPerPage = 10.obs;

  // Stats
  var stats = <String, dynamic>{}.obs;

  // Search
  final searchController = TextEditingController();
  Timer? _debounce;

  // Filter
  var selectedStatusFilter = 'All'.obs;
  final List<String> statusOptions = [
    'All',
    'Pending',
    'Approved',
    'Rejected',
  ];

  @override
  void onClose() {
    searchController.dispose();
    _debounce?.cancel();
    super.onClose();
  }

  void onSearchChanged(BuildContext context) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      currentPage.value = 1;
      fetchMyLeaves(context);
    });
  }

  void updateStatusFilter(String? newValue, BuildContext context) {
    if (newValue != null) {
      selectedStatusFilter.value = newValue;
      currentPage.value = 1;
      fetchMyLeaves(context);
    }
  }

  Future<void> fetchMyLeaves(BuildContext context,
      {bool refresh = false}) async {
    try {
      if (!refresh) isLoading.value = true;
      hasError.value = false;

      final token = await _getToken();
      final userId = await _storage.read(key: 'user_id');
      if (token == null || userId == null) {
        hasError.value = true;
        errorMessage.value = 'Authentication failed.';
        return;
      }

      String? statusParam;
      if (selectedStatusFilter.value != 'All') {
        statusParam = selectedStatusFilter.value.toLowerCase();
      }

      int offset = (currentPage.value - 1) * itemsPerPage.value;

      final result = await _service.getLeaveRequests(
        token,
        employeeId: userId,
        status: statusParam,
        search: searchController.text.trim().isNotEmpty
            ? searchController.text.trim()
            : null,
        limit: itemsPerPage.value,
        offset: offset,
      );

      leaveList.assignAll(result.items);
      totalCount.value = result.count;

      // Fetch personal stats
      _fetchMyStats(token, userId);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      log("Fetch my leaves error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchMyStats(String token, String userId) async {
    try {
      final data = await _service.getEmployeeLeaveStats(token, userId);
      if (data is Map) {
        stats.assignAll(Map<String, dynamic>.from(data));
      }
    } catch (e) {
      log("My leaves stats error: $e");
    }
  }

  void changePage(int page, BuildContext context) {
    currentPage.value = page;
    fetchMyLeaves(context, refresh: true);
  }

  void changeLimit(int limit, BuildContext context) {
    itemsPerPage.value = limit;
    currentPage.value = 1;
    fetchMyLeaves(context, refresh: true);
  }

  Future<String?> _getToken() async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith("Bearer ")) {
      token = token.replaceFirst("Bearer ", "");
    }
    return token.replaceAll('"', '').trim();
  }
}
