import 'dart:developer';
import 'package:bms_front_end/components/dialog/dialog_scaffold.dart';
import 'package:bms_front_end/components/feedback/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';

import '../../../src/model/employees_model.dart';
import '../../../src/services/employees_services.dart';
import '../../../src/services/hr/loan_service.dart';
import '../models/loans_model.dart';

class LoanController extends GetxController {
  final LoanService _service = LoanService();
  final EmployeeService _employeeService = EmployeeService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // --- State Variables ---
  var isLoading = false.obs;
  var isSaving = false.obs;
  var allLoans = <LoanRequest>[].obs;
  var displayedLoans = <LoanRequest>[].obs;
  var totalCount = 0.obs;
  var errorMessage = ''.obs;
  var hasError = false.obs;

  // Filters
  var activeTab = 'All'.obs;
  final searchController = TextEditingController();
  var selectedStatusFilter = 'All Statutes'.obs;
  final List<String> statusOptions = [
    'All Statutes',
    'Pending',
    'Approved',
    'Rejected'
  ];

  // Pagination
  var currentPage = 1.obs;
  var itemsPerPage = 10.obs;

  // Employee dropdown data
  var allEmployees = <Employee>[].obs;

  // Form Controllers
  final loanAmountController = TextEditingController();
  final repaymentDateController = TextEditingController();
  final reasonController = TextEditingController();
  final emergencyContactNameController = TextEditingController();
  final emergencyContactPhoneController = TextEditingController();
  final attachmentController = TextEditingController();

  DateTime? selectedRepaymentDate;

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    _fetchEmployees();
  }

  Future<void> _fetchEmployees() async {
    try {
      String? token = await _storage.read(key: 'access_token');
      if (token == null) return;
      if (token.startsWith('Bearer '))
        token = token.replaceFirst('Bearer ', '');
      token = token.replaceAll('"', '').trim();
      final result = await _employeeService.getEmployees(token, limit: 500);
      allEmployees.assignAll(result.list);
    } catch (e) {
      log("Error fetching employees for loan dropdown: $e");
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    loanAmountController.dispose();
    repaymentDateController.dispose();
    reasonController.dispose();
    emergencyContactNameController.dispose();
    emergencyContactPhoneController.dispose();
    attachmentController.dispose();
    _debounce?.cancel();
    super.onClose();
  }

  // --- Search ---

  void onSearchChanged(BuildContext context) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      currentPage.value = 1;
      fetchLoans(context);
    });
  }

  // --- Tab / Filter Actions ---

  void setActiveTab(String tab, BuildContext context) {
    activeTab.value = tab;
    currentPage.value = 1;
    if (tab == 'Pending Approvals') {
      selectedStatusFilter.value = 'Pending';
    } else if (tab == 'History') {
      selectedStatusFilter.value = 'All Statutes';
    } else {
      selectedStatusFilter.value = 'All Statutes';
    }
    fetchLoans(context);
  }

  void updateStatusFilter(String? val, BuildContext context) {
    if (val != null) {
      selectedStatusFilter.value = val;
      currentPage.value = 1;
      fetchLoans(context);
    }
  }

  void changePage(int page, BuildContext context) {
    currentPage.value = page;
    fetchLoans(context, refresh: true);
  }

  void changeLimit(int limit, BuildContext context) {
    itemsPerPage.value = limit;
    currentPage.value = 1;
    fetchLoans(context, refresh: true);
  }

  // --- API Calls ---

  Future<void> fetchLoans(BuildContext context, {bool refresh = false}) async {
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

      final result = await _service.getLoans(
        token,
        status: statusParam,
        search: searchController.text.trim().isNotEmpty
            ? searchController.text.trim()
            : null,
        limit: itemsPerPage.value,
        offset: offset,
      );

      allLoans.assignAll(result.items);
      displayedLoans.assignAll(result.items);
      totalCount.value = result.count;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      log('Fetch loans error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createLoan(BuildContext context) async {
    try {
      isSaving.value = true;

      final token = await _getToken(context);
      if (token == null) return;

      final loan = LoanRequest(
        loanAmount: loanAmountController.text.trim(),
        repaymentDate: repaymentDateController.text.trim(),
        reason: reasonController.text.trim(),
        emergencyContactName: emergencyContactNameController.text.trim(),
        emergencyContactPhone: emergencyContactPhoneController.text.trim(),
        attachment: attachmentController.text.trim(),
      );

      await _service.createLoan(token, loan);

      if (context.mounted) {
        AppToast.success(context, 'Loan request created successfully');
        Navigator.pop(context);
      }

      clearForm();
      await fetchLoans(context, refresh: true);
    } catch (e) {
      log('Create loan error: $e');
      if (context.mounted) {
        _showDialog(context, 'Error',
            'Failed to create loan request. Please try again.');
      }
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> approveLoan(BuildContext context, int loanId) async {
    try {
      isSaving.value = true;

      final token = await _getToken(context);
      if (token == null) return;

      await _service.approveLoan(token, loanId);

      await fetchLoans(context, refresh: true);

      if (context.mounted) {
        Navigator.pop(context);
        AppToast.success(context, 'Loan approved successfully');
      }
    } catch (e) {
      log('Approve loan error: $e');
      if (context.mounted) {
        _showDialog(
            context, 'Error', 'Failed to approve loan. Please try again.');
      }
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> rejectLoan(BuildContext context, int loanId) async {
    try {
      isSaving.value = true;

      final token = await _getToken(context);
      if (token == null) return;

      await _service.rejectLoan(token, loanId);

      await fetchLoans(context, refresh: true);

      if (context.mounted) {
        Navigator.pop(context);
        AppToast.error(context, 'Loan rejected');
      }
    } catch (e) {
      log('Reject loan error: $e');
      if (context.mounted) {
        _showDialog(
            context, 'Error', 'Failed to reject loan. Please try again.');
      }
    } finally {
      isSaving.value = false;
    }
  }

  // --- Form Helpers ---

  void clearForm() {
    loanAmountController.clear();
    repaymentDateController.clear();
    reasonController.clear();
    emergencyContactNameController.clear();
    emergencyContactPhoneController.clear();
    attachmentController.clear();
    selectedRepaymentDate = null;
  }

  Future<void> pickRepaymentDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          selectedRepaymentDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      selectedRepaymentDate = picked;
      repaymentDateController.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  // --- Utilities ---

  Future<String?> _getToken(BuildContext context) async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith('Bearer ')) token = token.replaceFirst('Bearer ', '');
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
            child: const Text('OK'),
          ),],
    );
  }
}
