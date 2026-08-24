import 'dart:async';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/feedback/app_toast.dart';
import 'dart:developer';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../src/model/branch_model.dart';
import '../../../src/model/departments_units_model.dart';
import '../../../src/model/employees_model.dart';
import '../../../src/model/role_model.dart';
import '../../../src/services/auth_service.dart';
import '../../../src/services/branch_service.dart';
import '../../../src/services/employees_services.dart';
import '../../../src/services/role_service.dart';

class EmployeeController extends GetxController {
  final EmployeeService _service = EmployeeService();
  final BranchService _branchService = BranchService();
  final RoleService _roleService = RoleService();
  final AuthService _authService = AuthService();
  final _storage = const FlutterSecureStorage();

  // ─── Loading & Error State ──────────────────────────────────────────
  var isLoading = false.obs;
  var isSaving = false.obs;
  var errorMessage = ''.obs;

  // ─── Employee List ──────────────────────────────────────────────────
  var employeeList = <Employee>[].obs;

  // ─── Filter State ───────────────────────────────────────────────────
  var currentIsActive = true.obs;

  // ─── Pagination State ───────────────────────────────────────────────
  var currentPage = 1.obs;
  var limit = 10.obs;
  var totalItems = 0.obs;

  // ─── Search State ───────────────────────────────────────────────────
  var searchQuery = ''.obs;
  Timer? _debounce;

  // ─── Dropdown Data ──────────────────────────────────────────────────
  var departments = <Department>[].obs;
  var departmentUnits = <DepartmentUnit>[].obs;
  var branches = <Branch>[].obs;
  var allEmployees = <Employee>[].obs; // For "Reporting To" dropdown
  var roles = <Role>[].obs; // For "Role" dropdown

  // ─── Selected Employee (for profile page) ──────────────────────────
  var selectedEmployee = Rxn<Employee>();

  // ─── Documents & Reviews ────────────────────────────────────────────
  var documents = <dynamic>[].obs;
  var reviews = <dynamic>[].obs;
  var isLoadingDocuments = false.obs;
  var isLoadingReviews = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  // ─── INIT ───────────────────────────────────────────────────────────

  Future<void> _loadInitialData() async {
    final token = await _getToken();
    if (token == null) return;

    // Load dropdown data and employee list in parallel
    await Future.wait([
      _fetchDepartments(token),
      _fetchBranches(token),
      _fetchAllEmployees(token),
      _fetchRoles(token),
      fetchEmployees(),
    ]);
  }

  Future<void> _fetchDepartments(String token) async {
    try {
      final result = await _service.getDepartments(token, limit: 200);
      departments.assignAll(result);
    } catch (e) {
      log("Error fetching departments: $e");
    }
  }

  Future<void> _fetchBranches(String token) async {
    try {
      final result =
          await _branchService.getBranches(accessToken: token, limit: 200);
      branches.assignAll(result.items);
    } catch (e) {
      log("Error fetching branches: $e");
    }
  }

  Future<void> _fetchAllEmployees(String token) async {
    try {
      final result = await _service.getEmployees(token, limit: 500);
      allEmployees.assignAll(result.list);
    } catch (e) {
      log("Error fetching all employees: $e");
    }
  }

  Future<void> _fetchRoles(String token) async {
    try {
      final result = await _roleService.listRoles(token, limit: 200);
      roles.assignAll(result.list);
    } catch (e) {
      log("Error fetching roles: $e");
    }
  }

  /// Fetch department units — called when department selection changes
  Future<void> fetchDepartmentUnits({String? departmentId}) async {
    try {
      final token = await _getToken();
      if (token == null) return;
      final result = await _service.getDepartmentUnits(
        token,
        departmentId: departmentId,
        limit: 200,
      );
      departmentUnits.assignAll(result);
    } catch (e) {
      log("Error fetching department units: $e");
    }
  }

  // ─── FETCH EMPLOYEES ───────────────────────────────────────────────

  Future<void> fetchEmployees({bool refresh = false}) async {
    try {
      if (!refresh) isLoading(true);
      errorMessage('');

      final token = await _getToken();
      if (token == null) return;

      int offset = (currentPage.value - 1) * limit.value;

      final result = await _service.getEmployees(
        token,
        limit: limit.value,
        offset: offset,
        isActive: currentIsActive.value,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
      );
      employeeList.assignAll(result.list);
      totalItems.value = result.count;
    } catch (e) {
      errorMessage('Failed to load employees: $e');
      log("Fetch Error: $e");
    } finally {
      isLoading(false);
    }
  }

  // ─── FILE UPLOAD ────────────────────────────────────────────────────

  Future<String?> uploadProfileImage(
      String token, List<int> fileBytes, String fileName) async {
    try {
      return await _authService.uploadFile(token, fileBytes, fileName);
    } catch (e) {
      log("Upload Profile Image Error: $e");
      return null;
    }
  }

  // ─── CREATE ─────────────────────────────────────────────────────────

  Future<void> createEmployee(BuildContext context, Map<String, dynamic> data,
      {List<int>? imageBytes, String? imageName}) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return;

      // Upload profile image if provided
      if (imageBytes != null && imageName != null) {
        final imageUrl = await uploadProfileImage(token, imageBytes, imageName);
        if (imageUrl != null) {
          data['profile_picture'] = imageUrl;
        }
      }

      log("Create Employee payload: $data");
      await _service.createEmployee(token, data);

      if (context.mounted) {
        Navigator.pop(context);
        fetchEmployees(refresh: true);
        _showSnackBar(context, "Employee created successfully");
      }
    } catch (e) {
      log("Create Employee Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to create employee: ${e.toString()}");
      }
    } finally {
      isSaving.value = false;
    }
  }

  // ─── FETCH SINGLE EMPLOYEE ──────────────────────────────────────────

  Future<void> fetchEmployeeById(String userId) async {
    try {
      final token = await _getToken();
      if (token == null) return;
      final emp = await _service.getEmployeeById(token, userId);
      selectedEmployee.value = emp;
    } catch (e) {
      log("Fetch Employee By ID Error: $e");
    }
  }

  // ─── UPDATE ─────────────────────────────────────────────────────────

  Future<void> updateEmployee(
      BuildContext context, String userId, Map<String, dynamic> data,
      {List<int>? imageBytes, String? imageName}) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return;

      // Upload profile image if new one provided
      if (imageBytes != null && imageName != null) {
        final imageUrl = await uploadProfileImage(token, imageBytes, imageName);
        if (imageUrl != null) {
          data['profile_picture'] = imageUrl;
        }
      }

      log("Update Employee payload: $data");
      await _service.updateEmployee(token, userId, data);

      if (context.mounted) {
        Navigator.pop(context);
        fetchEmployees(refresh: true);
        // Refresh the selected employee so the profile page updates
        fetchEmployeeById(userId);
        _showSnackBar(context, "Employee updated successfully");
      }
    } catch (e) {
      log("Update Employee Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to update employee: ${e.toString()}");
      }
    } finally {
      isSaving.value = false;
    }
  }

  // ─── DOCUMENTS ──────────────────────────────────────────────────────

  Future<void> fetchDocuments(String userId) async {
    try {
      isLoadingDocuments.value = true;
      final token = await _getToken();
      if (token == null) return;
      final result = await _service.getEmployeeDocuments(token, userId);
      documents.assignAll(result);
    } catch (e) {
      log("Error fetching documents: $e");
    } finally {
      isLoadingDocuments.value = false;
    }
  }

  Future<void> uploadDocument(
      BuildContext context, String userId, dio.FormData formData) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return;

      await _service.uploadEmployeeDocument(token, userId, formData);

      if (context.mounted) {
        Navigator.pop(context);
        fetchDocuments(userId);
        _showSnackBar(context, "Document uploaded successfully");
      }
    } catch (e) {
      log("Upload Document Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to upload document: ${e.toString()}");
      }
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteDocument(
      BuildContext context, String userId, String docId) async {
    try {
      final token = await _getToken();
      if (token == null) return;

      await _service.deleteEmployeeDocument(token, userId, docId);

      if (context.mounted) {
        fetchDocuments(userId);
        _showSnackBar(context, "Document deleted successfully");
      }
    } catch (e) {
      log("Delete Document Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to delete document");
      }
    }
  }

  // ─── REVIEWS ────────────────────────────────────────────────────────

  Future<void> fetchReviews(String userId) async {
    try {
      isLoadingReviews.value = true;
      final token = await _getToken();
      if (token == null) return;
      final result = await _service.getEmployeeReviews(token, userId);
      reviews.assignAll(result);
    } catch (e) {
      log("Error fetching reviews: $e");
    } finally {
      isLoadingReviews.value = false;
    }
  }

  Future<void> createReview(
      BuildContext context, String userId, Map<String, dynamic> data) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return;

      await _service.createEmployeeReview(token, userId, data);

      if (context.mounted) {
        Navigator.pop(context);
        fetchReviews(userId);
        _showSnackBar(context, "Review submitted successfully");
      }
    } catch (e) {
      log("Create Review Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to create review: ${e.toString()}");
      }
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteReview(
      BuildContext context, String userId, String reviewId) async {
    try {
      final token = await _getToken();
      if (token == null) return;

      await _service.deleteEmployeeReview(token, reviewId);

      if (context.mounted) {
        fetchReviews(userId);
        _showSnackBar(context, "Review deleted successfully");
      }
    } catch (e) {
      log("Delete Review Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to delete review");
      }
    }
  }

  // ─── STATUS ACTIONS & EXIT ──────────────────────────────────────────
  //
  // Audit B5 fix: these return Future<bool> instead of swallowing errors
  // while pushing their own dialog — the old contract made callers'
  // `.then(pop)` close the error dialog one frame after it opened
  // (silent failure). Callers decide UI from the result.

  /// Success/failure message surfaced via [errorMessage] for toast display.
  Future<bool> suspendEmployee(
    BuildContext? context,
    String userId, {
    String? reason,
  }) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) {
        errorMessage.value = 'Not signed in.';
        return false;
      }

      await _service.suspendEmployee(token, userId, reason: reason);

      fetchEmployees(refresh: true);
      fetchEmployeeById(userId);
      errorMessage.value = '';
      return true;
    } catch (e) {
      log("Suspend Employee Error: $e");
      errorMessage.value = 'Could not suspend employee. Please try again.';
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deactivateEmployee(
    BuildContext? context,
    String userId,
  ) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) {
        errorMessage.value = 'Not signed in.';
        return false;
      }

      await _service.deactivateEmployee(token, userId);

      fetchEmployees(refresh: true);
      fetchEmployeeById(userId);
      if (context != null && context.mounted) {
        _showSnackBar(context, "Employee deactivated successfully");
      }
      errorMessage.value = '';
      return true;
    } catch (e) {
      log("Deactivate Employee Error: $e");
      errorMessage.value =
          'Could not deactivate employee. Please try again.';
      if (context != null && context.mounted) {
        AppToast.error(context, errorMessage.value);
      }
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> activateEmployee(
    BuildContext? context,
    String userId,
  ) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) {
        errorMessage.value = 'Not signed in.';
        return false;
      }

      await _service.activateEmployee(token, userId);

      fetchEmployees(refresh: true);
      fetchEmployeeById(userId);
      if (context != null && context.mounted) {
        _showSnackBar(context, "Employee activated successfully");
      }
      errorMessage.value = '';
      return true;
    } catch (e) {
      log("Activate Employee Error: $e");
      errorMessage.value = 'Could not activate employee. Please try again.';
      if (context != null && context.mounted) {
        AppToast.error(context, errorMessage.value);
      }
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> exitEmployee(
    BuildContext? context,
    String userId, {
    required String exitDate,
    required String reason,
  }) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) {
        errorMessage.value = 'Not signed in.';
        return false;
      }

      await _service.exitEmployee(
        token,
        userId,
        exitDate: exitDate,
        reason: reason,
      );

      fetchEmployees(refresh: true);
      fetchEmployeeById(userId);
      errorMessage.value = '';
      return true;
    } catch (e) {
      log("Exit Employee Error: $e");
      errorMessage.value = 'Could not offboard employee. Please try again.';
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // ─── SEARCH / FILTER / PAGINATION ──────────────────────────────────


  void changePage(int newPage) {
    currentPage.value = newPage;
    fetchEmployees();
  }

  void changeLimit(int newLimit) {
    limit.value = newLimit;
    currentPage.value = 1;
    fetchEmployees();
  }

  void onSearchChanged(String val) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      searchQuery.value = val;
      currentPage.value = 1;
      fetchEmployees();
    });
  }

  void filterByStatus(bool isActive) {
    currentIsActive.value = isActive;
    currentPage.value = 1;
    fetchEmployees();
  }

  // ─── HELPERS ────────────────────────────────────────────────────────

  Future<String?> _getToken() async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith("Bearer ")) {
      token = token.replaceFirst("Bearer ", "");
    }
    return token.replaceAll('"', '').trim();
  }

  void _showSnackBar(BuildContext context, String message) {
    AppToast.success(context, message);
  }

  void _showErrorDialog(BuildContext context, String message) {
    DialogScaffold.show(
      context,
      title: "Error",
      size: DialogSize.sm,
      body: Text(message),
      actions: [TextButton(
              onPressed: () => Navigator.pop(context), child: const Text("OK")),],
    );
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}
