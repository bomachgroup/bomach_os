import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';

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

  final List<String> leaveTypes = [
    'sick_leave',
    'casual_leave',
    'annual_leave',
    'maternity_leave',
    'paternity_leave',
    'unpaid_leave'
  ];

  final List<String> statusOptions = ['pending', 'approved', 'rejected'];

  final employeeIdController = TextEditingController();
  final employeeNameController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  final reasonController = TextEditingController();
  final approverIdController = TextEditingController();
  final rejectionReasonController = TextEditingController();

  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  var selectedLeaveType = 'sick_leave'.obs;
  var selectedStatus = 'pending'.obs;

  @override
  void onClose() {
    employeeIdController.dispose();
    employeeNameController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    reasonController.dispose();
    approverIdController.dispose();
    rejectionReasonController.dispose();
    super.onClose();
  }

  Future<void> fetchLeaveRequests(BuildContext context,
      {bool refresh = false}) async {
    try {
      if (!refresh) isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final token = await _getToken(context);
      if (token == null) {
        hasError.value = true;
        errorMessage.value = 'Authentication failed. Please login again.';
        return;
      }

      final result = await _service.getLeaveRequests(token);

      leaveList.assignAll((result.items as List)
          .map((e) => e is LeaveRequest
              ? e
              : LeaveRequest.fromJson(e as Map<String, dynamic>))
          .toList());
      totalCount.value = result.count;
      hasError.value = false;
    } catch (e) {
      log("Fetch Error: $e");
      hasError.value = true;
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          errorMessage.value = 'Session expired. Please login again.';
        } else if (e.response?.statusCode == 403) {
          errorMessage.value = 'You do not have permission to view this data.';
        } else if (e.response?.statusCode == 404) {
          errorMessage.value = 'No leave requests found.';
        } else if (e.type == DioExceptionType.connectionTimeout) {
          errorMessage.value =
              'Connection timeout. Please check your internet.';
        } else if (e.type == DioExceptionType.unknown) {
          errorMessage.value = 'Network error. Please check your connection.';
        } else {
          errorMessage.value =
              e.response?.data?['detail'] ?? 'Failed to load leave requests';
        }
      } else {
        errorMessage.value = 'An unexpected error occurred: ${e.toString()}';
      }
      leaveList.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveLeaveRequest(BuildContext context, {int? id}) async {
    try {
      isSaving.value = true;

      if (selectedStartDate == null || selectedEndDate == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Please select start and end dates")));
        }
        return;
      }

      final request = LeaveRequest(
        id: id,
        employeeId: employeeIdController.text.trim(),
        leaveType: selectedLeaveType.value,
        status: selectedStatus.value,
        startDate: selectedStartDate,
        endDate: selectedEndDate,
        reason: reasonController.text.trim(),
        approverId: approverIdController.text.trim().isEmpty
            ? null
            : approverIdController.text.trim(),
        rejectionReason: rejectionReasonController.text.trim().isEmpty
            ? null
            : rejectionReasonController.text.trim(),
        createdAt: null,
        updatedAt: null,
        durationDays: null,
      );

      final token = await _getToken(context);
      if (token == null) return;

      if (id == null) {
        final resp = await _service.createLeaveRequest(token, request);
        leaveList.insert(0, resp);
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Request Submitted")));
          Navigator.pop(context);
        }
      } else {
        final req =
            await _service.updateLeaveRequest(token, id.toString(), request);
        final index = leaveList.indexWhere((element) => element.id == id);
        if (index != -1) {
          leaveList[index] = req;
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Request Updated")));
          Navigator.pop(context);
        }
      }

      await fetchLeaveRequests(context, refresh: true);
      clearForm();
    } catch (e) {
      log("Save Error: $e");
      if (e is DioException && e.response?.data != null) {
        if (context.mounted) {
          _showDialog(context, "Error",
              e.response?.data['detail'] ?? "Operation failed");
        }
      }
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteRequest(BuildContext context, int? id) async {
    if (id == null) return;
    try {
      isLoading.value = true;
      final token = await _getToken(context);
      if (token == null) return;

      await _service.deleteLeaveRequest(token, id.toString());
      leaveList.removeWhere((r) => r.id == id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Deleted Successfully")));
      }
    } catch (e) {
      log("Delete Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void clearForm() {
    employeeIdController.clear();
    employeeNameController.clear();
    startDateController.clear();
    endDateController.clear();
    reasonController.clear();
    approverIdController.clear();
    rejectionReasonController.clear();
    selectedStartDate = null;
    selectedEndDate = null;
    selectedLeaveType.value = 'sick_leave';
    selectedStatus.value = 'pending';
  }

  void populateForm(LeaveRequest request) {
    employeeIdController.text = request.employeeId;
    reasonController.text = request.reason ?? '';
    approverIdController.text = request.approverId ?? '';
    rejectionReasonController.text = request.rejectionReason ?? '';

    selectedStartDate = request.startDate;
    selectedEndDate = request.endDate;
    startDateController.text = request.startDate != null
        ? DateFormat('yyyy-MM-dd').format(request.startDate!)
        : '';
    endDateController.text = request.endDate != null
        ? DateFormat('yyyy-MM-dd').format(request.endDate!)
        : '';

    selectedLeaveType.value = request.leaveType;
    selectedStatus.value = request.status ?? 'pending';
  }

  Future<void> pickDate(BuildContext context, bool isStart) async {
    final DateTime initial = isStart
        ? (selectedStartDate ?? DateTime.now())
        : (selectedEndDate ?? DateTime.now());
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      if (isStart) {
        selectedStartDate = picked;
        startDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      } else {
        selectedEndDate = picked;
        endDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      }
    }
  }

  Future<String?> _getToken(BuildContext context) async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith("Bearer ")) token = token.replaceFirst("Bearer ", "");
    return token.replaceAll('"', '').trim();
  }

  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text(title),
              content: Text(content),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("OK"))
              ],
            ));
  }
}
