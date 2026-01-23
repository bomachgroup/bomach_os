import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import 'package:bms_front_end/src/model/branch_model.dart';
import '../../../src/services/branch_service.dart';

class BranchController extends GetxController {
  final BranchService _branchService =
      BranchService(baseUrl: 'https://bomach-backend.onrender.com');
  final _storage = const FlutterSecureStorage();

  var isLoadingList = true.obs;
  var isLoadingDetail = true.obs;
  var isSaving = false.obs;
  var isFetchingStates = false.obs;

  var branchList = <Branch>[].obs;
  var currentBranch = Rxn<Branch>();
  var currentPerformance = Rxn<BranchPerformance>();

  var countryList = <Country>[].obs;
  var stateList = <StateModel>[].obs;
  var fieldChoices = Rxn<BranchFieldChoices>();

  var currentSearch = ''.obs;
  var activeFilter = true.obs;
  var currentOperationalStatus = ''.obs;
  var currentFilterStateId = Rxn<int>();

  @override
  void onInit() {
    super.onInit();
    fetchBranches();
  }

  void applyStateFilter(int? stateId) {
    currentFilterStateId.value = stateId;
    fetchBranches();
  }

  /// Fetch the main list of branches
  Future<void> fetchBranches({bool refresh = false}) async {
    try {
      if (!refresh) isLoadingList.value = true;

      final token = await _storage.read(key: 'access_token');
      if (token == null) return;

      final branches = await _branchService.getBranches(
        accessToken: token,
        search: currentSearch.value,
        isActive: activeFilter.value,
        stateId: currentFilterStateId.value,
        operationalStatus: currentOperationalStatus.value.isEmpty
            ? null
            : currentOperationalStatus.value,
        limit: 100,
      );

      branchList.assignAll(branches);
    } catch (e) {
      log("Error fetching branches: $e");
    } finally {
      isLoadingList.value = false;
    }
  }

  /// Fetch full details + performance metrics for a specific branch
  Future<void> fetchBranchDetails(int branchId) async {
    try {
      isLoadingDetail.value = true;
      currentBranch.value = null;
      currentPerformance.value = null;

      final token = await _storage.read(key: 'access_token');
      if (token == null) return;

      final results = await Future.wait([
        _branchService.getBranch(accessToken: token, branchId: branchId),
        _branchService.getBranchPerformance(
            accessToken: token, branchId: branchId),
      ]);

      currentBranch.value = results[0] as Branch;
      currentPerformance.value = results[1] as BranchPerformance;
    } catch (e) {
      log("Error fetching branch details: $e");
    } finally {
      isLoadingDetail.value = false;
    }
  }

  /// Load Countries and Field Choices (Run when entering Add/Edit Screen)
  Future<void> loadFormResources() async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) return;

      final results = await Future.wait([
        _branchService.getCountries(accessToken: token, isActive: true),
        _branchService.getBranchFieldChoices(accessToken: token),
      ]);

      countryList.assignAll(results[0] as List<Country>);
      fieldChoices.value = results[1] as BranchFieldChoices;
    } catch (e) {
      log("Error loading form resources: $e");
    }
  }

  /// Fetch States based on selected Country ID
  Future<void> fetchStatesForCountry(int countryId) async {
    try {
      isFetchingStates.value = true;
      stateList.clear();

      final token = await _storage.read(key: 'access_token');
      if (token == null) return;

      final states = await _branchService.getStates(
        accessToken: token,
        countryId: countryId,
      );

      stateList.assignAll(states);
    } catch (e) {
      log("Error fetching states: $e");
    } finally {
      isFetchingStates.value = false;
    }
  }

  Future<void> createBranch(
      BuildContext context, Map<String, dynamic> branchData) async {
    try {
      isSaving.value = true;
      final token = await _storage.read(key: 'access_token');

      if (token == null) {
        if (context.mounted) {
          _showSnackBar(context, "Authentication Error", isError: true);
        }
        return;
      }

      await _branchService.createBranch(
          accessToken: token, branchData: branchData);

      await fetchBranches(refresh: true);

      if (context.mounted) {
        context.pop();
        _showSnackBar(context, "Branch created successfully");
      }
    } catch (e) {
      log("Create Error: $e");
      if (context.mounted) {
        _showDialog(context, "Creation Failed", e.toString());
      }
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> updateBranch(BuildContext context, int branchId,
      Map<String, dynamic> updateData) async {
    try {
      isSaving.value = true;
      final token = await _storage.read(key: 'access_token');

      if (token == null) return;

      final updatedBranch = await _branchService.updateBranch(
        accessToken: token,
        branchId: branchId,
        updateData: updateData,
      );

      if (currentBranch.value?.id == branchId) {
        currentBranch.value = updatedBranch;
      }

      fetchBranches(refresh: true);

      if (context.mounted) {
        context.pop();
        _showSnackBar(context, "Branch updated successfully");
      }
    } catch (e) {
      log("Update Error: $e");
      if (context.mounted) _showDialog(context, "Update Failed", e.toString());
    } finally {
      isSaving.value = false;
    }
  }

  void setSearch(String query) {
    // Debounce could be added here if needed
    currentSearch.value = query;
    fetchBranches();
  }

  void toggleActiveFilter() {
    activeFilter.value = !activeFilter.value;
    fetchBranches();
  }

  void _showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title,
            style: TextStyle(
                color: title.toLowerCase().contains("failed")
                    ? Colors.red
                    : Colors.black)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
