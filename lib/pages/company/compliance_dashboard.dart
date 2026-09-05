import 'package:bomach_os/pages/company/compliance.dart';
import 'package:bomach_os/pages/company/controllers/company_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// The API currently exposes a compliance register, not a separate aggregate
/// dashboard. Reuse that supported screen until dashboard aggregates exist.
class ComplianceDashboardPage extends StatelessWidget {
  const ComplianceDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CompanyController>()) {
      Get.put(CompanyController());
    }
    return const CompliancePage();
  }
}
