import 'dart:developer';
import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';

import '../../../src/services/hr/leave_request_services.dart';
import '../models/leave_request_model.dart' show LeaveRequest;

import 'package:bomach_os/src/utils/app_date_format.dart';
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
  var stats = <String, int>{
    'pending': 0,
    'onLeave': 0,
    'approved': 0,
    'rejected': 0
  }.obs;
  final searchController = TextEditingController();
  var selectedStatusFilter = 'All Statutes'.obs;

  final List<String> leaveTypes = [
    'sick_leave',
    'casual_leave',
    'annual_leave',
    'maternity_leave',
    'paternity_leave',
    'unpaid_leave'
  ];
  final List<String> filterStatusOptions = [
    'All Statutes',
    'Pending',
    'Approved',
    'Rejected'
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
    reasonController.dispose();
    // ... dispose other controllers
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

  void updateStatusFilter(String? newValue, BuildContext context) {
    if (newValue != null) {
      selectedStatusFilter.value = newValue;
      currentPage.value = 1;
      fetchLeaveRequests(context);
    }
  }

  Future<void> fetchLeaveRequests(BuildContext context,
      {bool refresh = false}) async {
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
      } else if (selectedStatusFilter.value != 'All Statutes') {
        statusParam = selectedStatusFilter.value.toLowerCase();
      }

      int offset = (currentPage.value - 1) * itemsPerPage.value;

      final result = await _service.getLeaveRequests(
        token,
        status: statusParam,
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
        stats['pending'] = summary['pending'] ?? 0;
        stats['onLeave'] = summary['on_leave'] ?? 0;
        stats['approved'] = summary['approved'] ?? 0;
        stats['rejected'] = summary['rejected'] ?? 0;
      }
    } catch (e) {
      log("Stats error: $e");
    }
  }

  void setActiveTab(String tab, BuildContext context) {
    activeTab.value = tab;
    currentPage.value = 1;
    if (tab == 'Pending Approvals') selectedStatusFilter.value = 'All Statutes';
    fetchLeaveRequests(context);
  }

  // --- NEW METHOD: Update Status (Approve/Reject) ---
  Future<void> updateLeaveStatus(BuildContext context, int id, String status,
      {String? rejectionReason}) async {
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
        AppToast.info(context, "Request ${status == 'approved' ? 'Approved' : 'Rejected'} Successfully");
      }
    } catch (e) {
      log("Status Update Error: $e");
      if (context.mounted) {
        _showDialog(
            context, "Error", "Failed to update status. Please try again.");
      }
    } finally {
      isSaving.value = false;
    }
  }

  // ... [Keep existing saveLeaveRequest, clearForm, populateForm, pickDate, _getToken, _showDialog, changePage, changeLimit] ...

  Future<void> saveLeaveRequest(BuildContext context, {int? id}) async {
    // ... existing implementation for Create/Edit
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
        ? formatAppDate(request.startDate!)
        : '';
    endDateController.text = request.endDate != null
        ? formatAppDate(request.endDate!)
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
      startDateController.text = formatAppDate(date);

      // A later start date makes an earlier end date invalid.
      if (selectedEndDate != null && selectedEndDate!.isBefore(date)) {
        selectedEndDate = null;
        endDateController.clear();
      }
    } else {
      selectedEndDate = date;
      endDateController.text = formatAppDate(date);
    }
  }

  Future<String?> _getToken(BuildContext context) async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith("Bearer ")) token = token.replaceFirst("Bearer ", "");
    return token.replaceAll('"', '').trim();
  }

  void _showDialog(BuildContext context, String title, String content) {
    DialogScaffold.show(
      context,
      title: title,
      size: DialogSize.sm,
      body: Text(content),
      actions: [TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("OK"))],
    );
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
