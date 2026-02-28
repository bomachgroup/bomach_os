import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/loans_model.dart';

class LoanController extends GetxController {
  // --- State Variables ---
  var isLoading = false.obs;
  var allLoans = <LoanRequest>[].obs;       // Master list
  var displayedLoans = <LoanRequest>[].obs; // Filtered & Paginated list
  
  // Filters
  var activeTab = 'All'.obs; 
  final searchController = TextEditingController();
  var selectedStatusFilter = 'All Statutes'.obs;
  final List<String> statusOptions = ['All Statutes', 'Pending', 'Approved', 'Rejected'];

  // Pagination
  var currentPage = 1.obs;
  var itemsPerPage = 10.obs;
  var totalItems = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _generateDummyData(); // Load initial dummy data
    searchController.addListener(_applyFilters);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // --- Actions ---

  void setActiveTab(String tab) {
    activeTab.value = tab;
    currentPage.value = 1; // Reset page on tab change
    // Auto-set status filter based on tab for convenience
    if (tab == 'Pending Approvals') {
      selectedStatusFilter.value = 'Pending';
    } else if (tab == 'History') {
       // History usually implies resolved, but we'll leave filter open or set to 'All'
       selectedStatusFilter.value = 'All Statutes';
    } else {
      selectedStatusFilter.value = 'All Statutes';
    }
    _applyFilters();
  }

  void updateStatusFilter(String? val) {
    if (val != null) {
      selectedStatusFilter.value = val;
      currentPage.value = 1;
      _applyFilters();
    }
  }

  void changePage(int page) {
    currentPage.value = page;
    _applyFilters();
  }

  void changeLimit(int limit) {
    itemsPerPage.value = limit;
    currentPage.value = 1;
    _applyFilters();
  }

  // --- Filtering Logic ---

  void _applyFilters() {
    isLoading.value = true;
    
    // 1. Filter by Tab & Status & Search
    List<LoanRequest> temp = allLoans.where((loan) {
      // Tab Logic
      bool matchTab = true;
      if (activeTab.value == 'Pending Approvals') {
        matchTab = loan.status == 'Pending';
      } else if (activeTab.value == 'History') {
        matchTab = loan.status != 'Pending';
      }

      // Status Dropdown Logic
      bool matchStatus = true;
      if (selectedStatusFilter.value != 'All Statutes') {
        matchStatus = loan.status == selectedStatusFilter.value;
      }

      // Search Logic
      bool matchSearch = true;
      if (searchController.text.isNotEmpty) {
        String query = searchController.text.toLowerCase();
        matchSearch = loan.employeeName.toLowerCase().contains(query) || 
                      loan.reason.toLowerCase().contains(query);
      }

      return matchTab && matchStatus && matchSearch;
    }).toList();

    totalItems.value = temp.length;

    // 2. Pagination Logic (Slice the list)
    int start = (currentPage.value - 1) * itemsPerPage.value;
    if (start >= temp.length) {
      start = 0; 
      currentPage.value = 1;
    }
    int end = start + itemsPerPage.value;
    if (end > temp.length) end = temp.length;

    displayedLoans.assignAll(temp.sublist(start, end));
    
    // Simulate slight delay for realism if desired
    Future.delayed(const Duration(milliseconds: 200), () {
      isLoading.value = false;
    });
  }

  // --- Dummy Data Generation ---
  void _generateDummyData() {
    allLoans.value = List.generate(25, (index) {
      String status = index % 3 == 0 ? 'Approved' : (index % 3 == 1 ? 'Rejected' : 'Pending');
      return LoanRequest(
        id: '$index',
        employeeName: index % 2 == 0 ? "Evelyn George" : "Mathew Parker",
        employeeRole: "Software Engineer",
        amount: (index + 1) * 50000.0,
        repaymentDate: DateTime.now().add(Duration(days: index * 5)),
        reason: index % 2 == 0 ? "Family trip" : "Medical Emergency",
        status: status,
      );
    });
    _applyFilters();
  }
}