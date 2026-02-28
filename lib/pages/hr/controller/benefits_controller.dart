import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/benefits_model.dart';

class BenefitsController extends GetxController {
  // --- State ---
  var isLoading = false.obs;
  var employeeList = <BenefitRecord>[].obs;
  var availableBenefits = <String>[].obs;

  // Filters & Pagination
  final searchController = TextEditingController();
  var currentPage = 1.obs;
  var itemsPerPage = 10.obs;

  @override
  void onInit() {
    super.onInit();
    _loadDummyData();
  }

  // --- Actions ---

  // 1. Manage Master List of Benefits
  // Returns true if successful, false otherwise
  bool addBenefitType(String name) {
    if (name.isNotEmpty && !availableBenefits.contains(name)) {
      availableBenefits.add(name);
      return true;
    }
    return false;
  }

  void removeBenefitType(String name) {
    availableBenefits.remove(name);
  }

  // 2. Manage Employee Benefits
  void updateEmployeeBenefits(String empId, List<String> newBenefits) {
    int index = employeeList.indexWhere((e) => e.id == empId);
    if (index != -1) {
      final old = employeeList[index];
      employeeList[index] = BenefitRecord(
        id: old.id,
        employeeName: old.employeeName,
        employeeId: old.employeeId,
        employeeRole: old.employeeRole,
        activeBenefits: newBenefits,
        startDate: old.startDate,
        status: old.status,
        imageUrl: old.imageUrl,
      );
      employeeList.refresh();
    }
  }

  // --- Dummy Data ---
  void _loadDummyData() {
    availableBenefits.addAll([
      "Tax Incentive",
      "House Allowance",
      "Car Allowance",
      "Feeding Allowance",
      "Health Insurance",
      "Data Allowance"
    ]);

    employeeList.addAll([
      BenefitRecord(
        id: '1',
        employeeName: "Evelyn George",
        employeeId: "R5900833",
        employeeRole: "Software Engineer",
        activeBenefits: ["Tax Incentive", "House Allowance", "Car Allowance"],
        startDate: DateTime(2024, 2, 10),
        status: "Approved",
      ),
      BenefitRecord(
        id: '2',
        employeeName: "Mathew Parker",
        employeeId: "R5900834",
        employeeRole: "Software Engineer",
        activeBenefits: ["Tax Incentive", "House Allowance"],
        startDate: DateTime(2024, 2, 10),
        status: "Rejected",
      ),
      BenefitRecord(
        id: '3',
        employeeName: "Silvia Torres",
        employeeId: "R5900835",
        employeeRole: "Software Engineer",
        activeBenefits: ["Tax Incentive", "House Allowance", "Car Allowance"],
        startDate: DateTime(2024, 2, 10),
        status: "Pending",
      ),
    ]);
  }
}
