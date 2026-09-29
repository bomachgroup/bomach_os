import 'dart:developer';
import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:bomach_os/pages/auth/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import '../../../src/constants/permissions.dart';
import '../../../src/services/permission_service.dart';
import '../../../src/services/hr/leave_request_services.dart';
import '../models/leave_request_model.dart' show LeaveRequest;

class LeaveRequestController extends GetxController {
  final LeaveRequestService _service = LeaveRequestService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  var isLoading = false.obs;
  var isSaving = false.obs;
  var leaveList = <LeaveRequest>[].obs;
  var totalCount = 0.obs;
  var errorMessage = ''.obs;
  var hasError = false.obs;

  // --- Pagination & Filter Variables ---
  var currentPage = 1.obs;
  var itemsPerPage = 10.obs;
  var activeTab = 'All'.obs;
  var selectedRequestKind = 'all'.obs;
  var stats = <String, int>{
    'pending': 0,
    'onLeave': 0,
    'approved': 0,
    'rejected': 0
  }.obs;
  final searchController = TextEditingController();
  var selectedStatusFilter = 'All statuses'.obs;

  final List<String> leaveTypes = [
    'sick_leave',
    'casual_leave',
    'annual_leave',
    'maternity_leave',
    'paternity_leave',
    'unpaid_leave'
  ];
  final List<String> filterStatusOptions = [
    'All statuses',
    'Pending',
    'Approved',
    'Rejected'
  ];
  final List<String> requestKindOptions = [
    'all',
    'leave',
    'absence',
    'running_late',
  ];

  // Form Controllers
  final employeeIdController = TextEditingController();
  final employeeNameController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  final reasonController = TextEditingController();
  final approverIdController = TextEditingController();
  final rejectionReasonController = TextEditingController();

  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  var selectedLeaveType = ''.obs;
  var selectedStatus = 'pending'.obs;

  Timer? _debounce;

  @override
  void onClose() {
    searchController.dispose();
    _debounce?.cancel();
    employeeIdController.dispose();
    employeeNameController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    reasonController.dispose();
    approverIdController.dispose();
    rejectionReasonController.dispose();
    super.onClose();
  }

  // ... [Keep existing _onSearchChanged, updateStatusFilter, fetchLeaveRequests, _fetchStats, setActiveTab] ...

  void onSearchChanged(context) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      currentPage.value = 1;
      fetchLeaveRequests(context);
    });
  }

  bool _requirePermission(
    BuildContext context,
    Permission permission,
    String action,
  ) {
    if (Get.find<PermissionService>().has(permission)) return true;
    if (context.mounted) {
      AppToast.error(context, 'Your role does not allow you to $action.');
    }
    return false;
  }

  void updateStatusFilter(String? newValue, BuildContext context) {
    if (newValue != null) {
      selectedStatusFilter.value = newValue;
      if (newValue != 'All statuses') activeTab.value = 'All';
      currentPage.value = 1;
      fetchLeaveRequests(context);
    }
  }

  void updateRequestKindFilter(String? newValue, BuildContext context) {
    if (newValue != null && requestKindOptions.contains(newValue)) {
      selectedRequestKind.value = newValue;
      currentPage.value = 1;
      fetchLeaveRequests(context);
    }
  }

  Future<void> fetchLeaveRequests(BuildContext context,
      {bool refresh = false}) async {
    if (!Get.find<PermissionService>().has(Perms.leaveRequestsList)) {
      leaveList.clear();
      totalCount.value = 0;
      stats.updateAll((_, __) => 0);
      isLoading.value = false;
      hasError.value = false;
      errorMessage.value = '';
      return;
    }

    try {
      if (!refresh) isLoading.value = true;
      hasError.value = false;

      final token = await _getToken(context);
      if (token == null) {
        hasError.value = true;
        errorMessage.value = 'Authentication failed.';
        return;
      }

      String? statusParam;
      if (activeTab.value == 'Pending Approvals') {
        statusParam = 'pending';
      } else if (activeTab.value == 'History' &&
          selectedStatusFilter.value == 'All statuses') {
        statusParam = 'history';
      } else if (selectedStatusFilter.value != 'All statuses') {
        statusParam = selectedStatusFilter.value.toLowerCase();
      }

      int offset = (currentPage.value - 1) * itemsPerPage.value;

      final result = await _service.getLeaveRequests(
        token,
        status: statusParam,
        requestKind: selectedRequestKind.value,
        search: searchController.text.trim().isNotEmpty
            ? searchController.text.trim()
            : null,
        limit: itemsPerPage.value,
        offset: offset,
      );

      leaveList.assignAll((result.items as List)
          .map((e) => e is LeaveRequest ? e : LeaveRequest.fromJson(e))
          .toList());
      totalCount.value = result.count;
      _fetchStats(token);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchStats(String token) async {
    try {
      final summary = await _service.getLeaveRequestsSummary(token);
      if (summary is Map) {
        int count(String key) => (summary[key] as num?)?.toInt() ?? 0;
        stats['pending'] = count('pending');
        stats['onLeave'] = count('on_leave');
        stats['approved'] = count('approved_this_month');
        stats['rejected'] = count('rejected');
      }
    } catch (e) {
      log("Stats error: $e");
    }
  }

  void setActiveTab(String tab, BuildContext context) {
    activeTab.value = tab;
    currentPage.value = 1;
    selectedStatusFilter.value = 'All statuses';
    fetchLeaveRequests(context);
  }

  // --- NEW METHOD: Update Status (Approve/Reject) ---
  Future<void> updateLeaveStatus(
    BuildContext context,
    int id,
    String status, {
    required String requestEmployeeId,
    String? rejectionReason,
  }) async {
    final normalizedStatus = status.toLowerCase();
    final requiredPermission = switch (normalizedStatus) {
      'approved' => Perms.leaveRequestsApprove,
      'rejected' => Perms.leaveRequestsReject,
      _ => null,
    };
    if (requiredPermission == null) return;
    final action = normalizedStatus == 'approved' ? 'approve' : 'reject';
    if (!_requirePermission(
      context,
      requiredPermission,
      '$action leave requests',
    )) {
      return;
    }

    final currentEmployeeId = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>().currentUser.value?.id
        : null;
    if (currentEmployeeId == null || currentEmployeeId <= 0) {
      if (context.mounted) {
        AppToast.warning(context, 'Your employee profile is still loading.');
      }
      return;
    }
    if (currentEmployeeId.toString() == requestEmployeeId) {
      if (context.mounted) {
        AppToast.error(context, 'You cannot review your own request.');
      }
      return;
    }

    try {
      isSaving.value = true;
      final token = await _getToken(context);
      if (token == null) return;

      await _service.updateLeaveRequestStatus(
        token,
        id.toString(),
        status: status,
        rejectionReason: rejectionReason,
        // approvedBy: 'CurrentUserId' // You can pass this if you have the logged-in user's ID
      );

      await fetchLeaveRequests(context, refresh: true);

      if (context.mounted) {
        Navigator.pop(context); // Close the View Dialog
        AppToast.info(context,
            "Request ${status == 'approved' ? 'Approved' : 'Rejected'} Successfully");
      }
    } catch (e) {
      log("Status Update Error: $e");
      if (context.mounted) {
        AppToast.error(
          context,
          e.toString().replaceFirst(RegExp(r'^Exception: '), ''),
        );
      }
    } finally {
      isSaving.value = false;
    }
  }

  // ... [Keep existing saveLeaveRequest, clearForm, populateForm, pickDate, _getToken, _showDialog, changePage, changeLimit] ...

  Future<void> saveLeaveRequest(BuildContext context, {int? id}) async {
    // ... existing implementation for Create/Edit
    final permission =
        id == null ? Perms.leaveRequestsCreate : Perms.leaveRequestsUpdate;
    final action = id == null ? 'create leave requests' : 'edit leave requests';
    if (!_requirePermission(context, permission, action)) return;

    try {
      isSaving.value = true;
      final request = LeaveRequest(
        id: id,
        employeeId: employeeIdController.text.trim(),
        leaveType: selectedLeaveType.value,
        status: selectedStatus.value,
        startDate: selectedStartDate,
        endDate: selectedEndDate,
        reason: reasonController.text.trim(),
      );

      final token = await _getToken(context);
      if (token == null) return;

      if (id == null) {
        await _service.createLeaveRequest(token, request);
      } else {
        await _service.updateLeaveRequest(token, id.toString(), request);
      }

      if (context.mounted) {
        AppToast.info(context, "Success");
        Navigator.pop(context);
      }
      await fetchLeaveRequests(context, refresh: true);
      clearForm();
    } catch (e) {
      // ... error
    } finally {
      isSaving.value = false;
    }
  }

  void clearForm() {
    employeeIdController.clear();
    reasonController.clear();
    selectedStartDate = null;
    selectedEndDate = null;
    startDateController.clear();
    endDateController.clear();
    selectedLeaveType.value = '';
  }

  void populateForm(LeaveRequest request) {
    employeeIdController.text = request.employeeId;
    reasonController.text = request.reason ?? '';
    selectedStartDate = request.startDate;
    selectedEndDate = request.endDate;
    startDateController.text = request.startDate != null
        ? DateFormat('yyyy-MM-dd').format(request.startDate!)
        : '';
    endDateController.text = request.endDate != null
        ? DateFormat('yyyy-MM-dd').format(request.endDate!)
        : '';
    selectedLeaveType.value = request.leaveType;
  }

  Future<void> pickDate(BuildContext context, bool isStart) async {
    final earliestDate = DateTime(1900);
    final latestDate = DateTime(2100, 12, 31);
    final startDate = selectedStartDate == null
        ? null
        : DateTime(
            selectedStartDate!.year,
            selectedStartDate!.month,
            selectedStartDate!.day,
          );
    final firstDate = !isStart && startDate != null ? startDate : earliestDate;
    final currentSelection = isStart ? selectedStartDate : selectedEndDate;
    var initialDate = currentSelection ?? startDate ?? DateTime.now();

    if (initialDate.isBefore(firstDate)) initialDate = firstDate;
    if (initialDate.isAfter(latestDate)) initialDate = latestDate;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: latestDate,
    );

    if (pickedDate == null || !context.mounted) return;

    final date = DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
    if (isStart) {
      selectedStartDate = date;
      startDateController.text = DateFormat('yyyy-MM-dd').format(date);

      // A later start date makes an earlier end date invalid.
      if (selectedEndDate != null && selectedEndDate!.isBefore(date)) {
        selectedEndDate = null;
        endDateController.clear();
      }
    } else {
      selectedEndDate = date;
      endDateController.text = DateFormat('yyyy-MM-dd').format(date);
    }
  }

  Future<String?> _getToken(BuildContext context) async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith("Bearer ")) token = token.replaceFirst("Bearer ", "");
    return token.replaceAll('"', '').trim();
  }

  void changePage(int page, BuildContext context) {
    currentPage.value = page;
    fetchLeaveRequests(context, refresh: true);
  }

  void changeLimit(int limit, BuildContext context) {
    itemsPerPage.value = limit;
    currentPage.value = 1;
    fetchLeaveRequests(context, refresh: true);
  }
}
