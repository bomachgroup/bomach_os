import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:bms_front_end/src/model/branch_model.dart';
import 'package:bms_front_end/src/model/employees_model.dart';
import '../../../src/services/branch_service.dart';
import '../../../src/services/employees_services.dart';

class BranchController extends GetxController {
  final BranchService _branchService = BranchService();
  final EmployeeService _employeeService = EmployeeService();
  final _storage = const FlutterSecureStorage();

  // --- State Variables ---
  var isLoadingList = true.obs;
  var isLoadingDetail = false.obs;
  var isSaving = false.obs;
  var isFetchingStates = false.obs;

  var branchList = <Branch>[].obs;
  var currentBranch = Rxn<Branch>();
  var currentPerformance = Rxn<BranchPerformance>();

  // --- Resources for Dropdowns ---
  var countryList = <Country>[].obs;
  var stateList = <StateModel>[].obs;
  var fieldChoices = Rxn<BranchFieldChoices>();
  var allEmployees = <Employee>[].obs; // For manager dropdown

  // --- Enriched Detail Data ---
  var currentCountryDetail = Rxn<Country>();
  var currentStateDetail = Rxn<StateModel>();

  // --- Filters ---
  var searchQuery = ''.obs;
  var filterStateId = Rxn<int>();
  var filterBranchRole = Rxn<String>(); // For "All Types"
  var filterStatus = Rxn<String>(); // For "Status" dropdown

  // --- Pagination ---
  var currentPage = 1.obs;
  var limit = 10.obs;
  var totalItems = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Load initial data
    fetchBranches();
    loadFilterResources();
  }

  // --- Data Fetching ---

  Future<void> fetchBranches({bool refresh = false}) async {
    try {
      if (!refresh) isLoadingList.value = true;

      final token = await _getToken();
      if (token == null) return;

      int offset = (currentPage.value - 1) * limit.value;

      final result = await _branchService.getBranches(
        accessToken: token,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        stateId: filterStateId.value,
        branchRole: filterBranchRole.value,
        operationalStatus: filterStatus.value,
        limit: limit.value,
        offset: offset,
      );

      branchList.assignAll(result.items);
      totalItems.value = result.total;
    } catch (e) {
      log("Error fetching branches: $e");
    } finally {
      isLoadingList.value = false;
    }
  }

  Future<void> fetchBranchDetails(int branchId) async {
    try {
      isLoadingDetail.value = true;
      currentBranch.value = null;
      currentPerformance.value = null;
      currentCountryDetail.value = null;
      currentStateDetail.value = null;

      final token = await _getToken();
      if (token == null) return;

      final results = await Future.wait([
        _branchService.getBranch(accessToken: token, branchId: branchId),
        _branchService.getBranchPerformance(
            accessToken: token, branchId: branchId),
      ]);

      currentBranch.value = results[0] as Branch;
      currentPerformance.value = results[1] as BranchPerformance;

      // Fetch enriched country and state details using single-item endpoints
      final branch = currentBranch.value!;
      if (branch.countryId != 0) {
        _fetchCountryDetail(token, branch.countryId);
      }
      if (branch.stateId != 0) {
        _fetchStateDetail(token, branch.stateId);
      }
    } catch (e) {
      log("Error fetching branch details: $e");
    } finally {
      isLoadingDetail.value = false;
    }
  }

  Future<void> _fetchCountryDetail(String token, int countryId) async {
    try {
      final country = await _branchService.getCountry(
        accessToken: token,
        countryId: countryId,
      );
      currentCountryDetail.value = country;
    } catch (e) {
      log("Error fetching country detail: $e");
    }
  }

  Future<void> _fetchStateDetail(String token, int stateId) async {
    try {
      final state = await _branchService.getState(
        accessToken: token,
        stateId: stateId,
      );
      currentStateDetail.value = state;
    } catch (e) {
      log("Error fetching state detail: $e");
    }
  }

  // --- Resource Loading ---

  Future<void> loadFilterResources() async {
    try {
      final token = await _getToken();
      if (token == null) return;

      // Load countries, choices, and employees for filters/forms in parallel
      final results = await Future.wait([
        _branchService.getCountries(accessToken: token, isActive: true),
        _branchService.getBranchFieldChoices(accessToken: token),
        _fetchAllEmployees(token),
      ]);

      countryList.assignAll(results[0] as List<Country>);
      fieldChoices.value = results[1] as BranchFieldChoices;

      // Attempt to load states for the default country (e.g., Nigeria if id=1 exists)
      // This helps populate the "All States" filter immediately if applicable
      if (countryList.isNotEmpty) {
        fetchStatesForCountry(countryList.first.id);
      }
    } catch (e) {
      log("Error loading resources: $e");
    }
  }

  Future<void> _fetchAllEmployees(String token) async {
    try {
      final result = await _employeeService.getEmployees(token, limit: 500);
      allEmployees.assignAll(result.list);
    } catch (e) {
      log("Error fetching employees for manager dropdown: $e");
    }
  }

  Future<void> fetchStatesForCountry(int countryId) async {
    try {
      isFetchingStates.value = true;
      stateList.clear();
      final token = await _getToken();
      if (token == null) return;

      final states = await _branchService.getStates(
          accessToken: token, countryId: countryId);
      stateList.assignAll(states);
    } catch (e) {
      log("Error fetching states: $e");
    } finally {
      isFetchingStates.value = false;
    }
  }

  // --- CRUD Operations ---

  Future<void> createBranch(
      BuildContext context, Map<String, dynamic> data) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return;

      await _branchService.createBranch(accessToken: token, branchData: data);

      if (context.mounted) {
        Navigator.pop(context);
        fetchBranches(refresh: true);
        _showSnackBar(context, "Branch created successfully");
      }
    } catch (e) {
      log("Create Error: $e");
      if (context.mounted)
        _showDialog(
            context, "Error", "Failed to create branch: ${e.toString()}");
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> updateBranch(
      BuildContext context, int branchId, Map<String, dynamic> data) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return;

      await _branchService.updateBranch(
          accessToken: token, branchId: branchId, updateData: data);

      if (context.mounted) {
        Navigator.pop(context);
        fetchBranches(refresh: true);
        _showSnackBar(context, "Branch updated successfully");
      }
    } catch (e) {
      log("Update Error: $e");
      if (context.mounted)
        _showDialog(context, "Error", "Failed to update branch");
    } finally {
      isSaving.value = false;
    }
  }

  // --- Filter Actions ---

  void onSearchChanged(String val) {
    searchQuery.value = val;
    currentPage.value = 1; // Reset to page 1
    fetchBranches();
  }

  void onStateFilterChanged(String? stateName) {
    if (stateName == 'All States' || stateName == null) {
      filterStateId.value = null;
    } else {
      final state = stateList.firstWhere((s) => s.name == stateName,
          orElse: () => StateModel(id: 0, name: '', countryId: 0, code: ''));
      if (state.id != 0) filterStateId.value = state.id;
    }
    currentPage.value = 1;
    fetchBranches();
  }

  void onTypeFilterChanged(String? typeLabel) {
    if (typeLabel == null || typeLabel == 'All Types') {
      filterBranchRole.value = null;
    } else {
      // Map display label to API value
      final option = fieldChoices.value?.branchRole
          .firstWhereOrNull((e) => e.label == typeLabel);
      filterBranchRole.value = option?.value ?? typeLabel;
    }
    currentPage.value = 1;
    fetchBranches();
  }

  void onStatusFilterChanged(String? statusLabel) {
    if (statusLabel == null || statusLabel == 'All Status') {
      filterStatus.value = null;
    } else {
      // Map display label to API value
      final option = fieldChoices.value?.operationalStatus
          .firstWhereOrNull((e) => e.label == statusLabel);
      filterStatus.value = option?.value ?? statusLabel;
    }
    currentPage.value = 1;
    fetchBranches();
  }

  // --- Pagination Actions ---

  void goToPage(int page) {
    currentPage.value = page;
    fetchBranches();
  }

  void setLimit(int newLimit) {
    limit.value = newLimit;
    currentPage.value = 1;
    fetchBranches();
  }

  // --- Helpers ---

  Future<String?> _getToken() async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith("Bearer ")) token = token.replaceFirst("Bearer ", "");
    return token.replaceAll('"', '').trim();
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green));
  }

  void _showDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("OK"))
        ],
      ),
    );
  }
}
