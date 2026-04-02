import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../pages/hr/models/training_program_model.dart';
import '../../../src/services/hr/training_program_services.dart';

// Mock Model for Skill Assessments (since no file was provided)
class SkillAssessment {
  final String id;
  final String employeeName;
  final String employeeRole;
  final String gap;
  final String priority;
  final String requestedByName;
  final String status;

  SkillAssessment(
      {required this.id,
      required this.employeeName,
      required this.employeeRole,
      required this.gap,
      required this.priority,
      required this.requestedByName,
      required this.status});
}

class TrainingProgramController extends GetxController {
  final TrainingProgramService _service = TrainingProgramService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // --- UI State ---
  var isLoading = false.obs;
  var isSaving = false.obs;
  var activeTab = 'Training Programs'.obs;
  var errorMessage = ''.obs;

  // --- Data Lists ---
  var programList = <TrainingProgram>[].obs;
  var assessmentList = <SkillAssessment>[].obs; // Mock list for 2nd tab

  // --- Pagination & Filters ---
  var currentPage = 1.obs;
  var itemsPerPage = 10.obs;
  var totalCount = 0.obs;

  final searchController = TextEditingController();
  var selectedStatusFilter = 'All Statutes'.obs;
  final List<String> statusOptions = [
    'All Statutes',
    'Active',
    'Inactive',
    'Scheduled',
    'Pending'
  ];

  // --- Stats ---
  var stats = <String, int>{
    'totalPrograms': 0,
    'totalEnrolled': 0, // This would likely come from an API summary endpoint
  }.obs;

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void onClose() {
    searchController.dispose();
    _debounce?.cancel();
    super.onClose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      currentPage.value = 1;
      fetchData();
    });
  }

  void setActiveTab(String tab) {
    activeTab.value = tab;
    currentPage.value = 1;
    selectedStatusFilter.value = 'All Statutes';
    searchController.clear();
    fetchData();
  }

  void updateStatusFilter(String? val) {
    if (val != null) {
      selectedStatusFilter.value = val;
      currentPage.value = 1;
      fetchData();
    }
  }

  // Unified fetch method
  Future<void> fetchData() async {
    final token = await _getToken();
    if (token == null) return;

    if (activeTab.value == 'Training Programs') {
      await fetchPrograms(token);
    } else {
      await fetchAssessments(token);
    }
  }

  Future<void> fetchPrograms(String token) async {
    try {
      isLoading(true);
      errorMessage('');

      int offset = (currentPage.value - 1) * itemsPerPage.value;

      final result = await _service.getTrainingPrograms(
        token,
        limit: itemsPerPage.value,
        offset: offset,
        search: searchController.text.trim(),
        status: selectedStatusFilter.value == 'All Statutes'
            ? null
            : selectedStatusFilter.value.toLowerCase(),
      );

      programList.assignAll(result.items);
      totalCount.value = result.count;

      // Update mock stats based on fetch
      stats['totalPrograms'] = result.count;
      stats['totalEnrolled'] = 45; // Mock data
    } catch (e) {
      errorMessage('Failed to load programs: $e');
      debugPrint("Fetch Error: $e");
    } finally {
      isLoading(false);
    }
  }

  // Mock fetch for assessments
  Future<void> fetchAssessments(String token) async {
    isLoading(true);
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate API

    // Mock Data
    var mockData = [
      SkillAssessment(
          id: '1',
          employeeName: "Evelyn George",
          employeeRole: "Software Engineer",
          gap: "Advanced Cloud Arch.",
          priority: "High",
          requestedByName: "Evelyn George",
          status: "Scheduled"),
      SkillAssessment(
          id: '2',
          employeeName: "Mathew Parker",
          employeeRole: "Software Engineer",
          gap: "B2B Negotiation",
          priority: "Medium",
          requestedByName: "Evelyn George",
          status: "Pending"),
      SkillAssessment(
          id: '3',
          employeeName: "Silvia Torres",
          employeeRole: "Software Engineer",
          gap: "Safety Compliance",
          priority: "Low",
          requestedByName: "Evelyn George",
          status: "Pending"),
    ];

    // Local Filtering
    String search = searchController.text.toLowerCase();
    var filtered = mockData.where((e) {
      bool matchesSearch = e.employeeName.toLowerCase().contains(search) ||
          e.gap.toLowerCase().contains(search);
      bool matchesStatus = selectedStatusFilter.value == 'All Statutes' ||
          e.status.toLowerCase() == selectedStatusFilter.value.toLowerCase();
      return matchesSearch && matchesStatus;
    }).toList();

    assessmentList.assignAll(filtered);
    totalCount.value = filtered.length;
    isLoading(false);
  }

  Future<String?> _getToken() async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith("Bearer ")) token = token.replaceFirst("Bearer ", "");
    return token.replaceAll('"', '').trim();
  }

  // --- Pagination Actions ---
  void changePage(int page) {
    currentPage.value = page;
    fetchData();
  }

  void changeLimit(int limit) {
    itemsPerPage.value = limit;
    currentPage.value = 1;
    fetchData();
  }

  // --- CRUD (Existing) ---
  Future<bool> createProgram(TrainingProgram program) async {
    final token = await _getToken();
    if (token == null) return false;
    try {
      isSaving(true);
      await _service.createTrainingProgram(token, program);
      await fetchPrograms(token);
      return true;
    } catch (e) {
      return false;
    } finally {
      isSaving(false);
    }
  }

  Future<bool> updateProgram(
      String token, String id, TrainingProgram program) async {
    try {
      isSaving(true);
      await _service.updateTrainingProgram(token, id, program);
      await fetchPrograms(token);
      return true;
    } catch (e) {
      debugPrint("Update Error: $e");
      return false;
    } finally {
      isSaving(false);
    }
  }

  Future<bool> deleteProgram(String id) async {
    final token = await _getToken();
    if (token == null) return false;
    try {
      await _service.deleteTrainingProgram(token, id);
      fetchPrograms(token);
      return true;
    } catch (e) {
      return false;
    }
  }
}
