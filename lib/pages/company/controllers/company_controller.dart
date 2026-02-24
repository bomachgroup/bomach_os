import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

// Assuming these exist based on your imports
import 'package:bms_front_end/src/model/company_model.dart';
import 'package:bms_front_end/src/services/company_service.dart';

class CompanyController extends GetxController {
  final CompanyService _companyService = CompanyService();
  final _storage = const FlutterSecureStorage();

  var isLoading = true.obs;
  var isSaving = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  Rxn<CompanySettings> companySettings = Rxn<CompanySettings>();

  // --- EXTENDED STATE (Fields missing from Model) ---
  // These allow the UI to function before the Backend/Model is updated.
  var industry = 'Professional Services'.obs;
  var timeZone = 'West Africa Time (WAT)'.obs;

  // Toggles
  var approvalType = 'Single-level'.obs; // Single-level vs Multi-level
  var notifyEmail = true.obs;
  var notifySMS = false.obs;
  var notifyPush = false.obs;
  var dataGdpr = true.obs;
  var dataCcpa = false.obs;

  // Shareholders / Board Members
  var shareholders = <Shareholder>[].obs;
  var isShareholdersLoading = false.obs;

  List<Shareholder> get boardMembers =>
      shareholders.where((s) => s.isBoardMember).toList();

// Compliance
  var complianceList = <Compliance>[].obs;
  var isComplianceLoading = false.obs;

  // Audit
  var auditLogs = <AuditLog>[].obs;
  var isAuditLoading = false.obs;

  // Dashboard Stats
  var dashboardStats = Rxn<DashboardStats>();
  var isDashboardLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCompanyProfile();
    fetchDashboardStats();
    fetchShareholders();
  }

  Future<void> updateCompanyProfile(
      BuildContext context, CompanySettings settings) async {
    try {
      isSaving.value = true;
      final token = await _storage.read(key: 'access_token');
      if (token == null) return;

      final result = await _companyService.updateCompanySettings(
          accessToken: token, settings: settings);
      companySettings.value = result;

      if (context.mounted) {
        Navigator.pop(context);
        _showSnackBar(context, "Profile updated successfully");
      }
    } catch (e) {
      _showSnackBar(context, "Failed to update: $e", isError: true);
    } finally {
      isSaving.value = false;
    }
  }

  // --- COMPLIANCE OPERATIONS ---
  Future<void> fetchComplianceRecords() async {
    try {
      isComplianceLoading.value = true;
      final token = await _storage.read(key: 'access_token');
      if (token != null) {
        final records = await _companyService.getComplianceRecords(token);
        complianceList.assignAll(records);
      }
    } catch (e) {
      log("Error loading compliance: $e");
    } finally {
      isComplianceLoading.value = false;
    }
  }

  Future<void> createCompliance(BuildContext context, Compliance item) async {
    try {
      isSaving.value = true;
      final token = await _storage.read(key: 'access_token');
      if (token != null) {
        await _companyService.createCompliance(token, item);
        await fetchComplianceRecords();
        if (context.mounted) {
          Navigator.pop(context);
          _showSnackBar(context, "Compliance record added");
        }
      }
    } catch (e) {
      _showSnackBar(context, "Error: $e", isError: true);
    } finally {
      isSaving.value = false;
    }
  }

  // --- AUDIT OPERATIONS ---
  Future<void> fetchAuditLogs() async {
    try {
      isAuditLoading.value = true;
      final token = await _storage.read(key: 'access_token');
      if (token != null) {
        final logs = await _companyService.getAuditLogs(token);
        auditLogs.assignAll(logs);
      }
    } catch (e) {
      log("Error loading audit logs: $e");
    } finally {
      isAuditLoading.value = false;
    }
  }

  Future<void> fetchCompanyProfile() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      final token = await _storage.read(key: 'access_token');

      // For dev purposes, if no token, we might still want to show UI (remove this in prod)
      if (token != null) {
        final settings =
            await _companyService.getCompanySettings(accessToken: token);
        companySettings.value = settings;
      } else {
        // Fallback for UI testing if auth fails
        hasError.value = true;
        errorMessage.value = "Authentication token not found";
      }
    } catch (e) {
      log("Error loading company profile: $e");
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchDashboardStats() async {
    try {
      isDashboardLoading.value = true;
      final token = await _storage.read(key: 'access_token');
      if (token != null) {
        final stats =
            await _companyService.getDashboardStats(accessToken: token);
        dashboardStats.value = stats;
      }
    } catch (e) {
      log("Error loading dashboard stats: $e");
    } finally {
      isDashboardLoading.value = false;
    }
  }

  Future<void> fetchShareholders() async {
    try {
      isShareholdersLoading.value = true;
      final token = await _storage.read(key: 'access_token');
      if (token != null) {
        final list = await _companyService.getShareholders(token);
        shareholders.assignAll(list);
      }
    } catch (e) {
      log("Error loading shareholders: $e");
    } finally {
      isShareholdersLoading.value = false;
    }
  }

  // --- UPDATE METHODS ---

  // Refactored to handle "Profile" specific updates
  Future<void> updateProfileInfo(
    BuildContext context, {
    required String name,
    required String email,
    required String phone,
    required String address,
    required String slogan,
    required String industryVal, // New
    String? logoUrl,
  }) async {
    // Update local reactive var immediately for UI responsiveness
    industry.value = industryVal;

    // Call the main update method with the specific fields
    await _performUpdate(
        context,
        (current) => current.copyWith(
              companyName: name,
              companyEmail: email,
              companyPhone: phone,
              companyAddresses: address,
              companySlogan: slogan,
              companyLogo: logoUrl ?? current.companyLogo,
            ));
  }

  // Refactored to handle "Global Business" specific updates
  Future<void> updateGlobalBusiness(
    BuildContext context, {
    required String primaryColor,
    required String secondaryColor,
    required String currency,
    required String language,
    required String timeZoneVal, // New
    required String rules,
    // Toggles handled locally for now
  }) async {
    timeZone.value = timeZoneVal;

    await _performUpdate(
        context,
        (current) => current.copyWith(
              primaryColorCode: primaryColor,
              secondaryColorCode: secondaryColor,
              defaultCurrency: currency,
              languagePreference: language,
              businessRules: rules,
            ));
  }

  // Helper to reduce code duplication
  Future<void> _performUpdate(BuildContext context,
      CompanySettings Function(CompanySettings) updateFn) async {
    try {
      isSaving.value = true;
      final token = await _storage.read(key: 'access_token');

      if (token == null || companySettings.value == null) return;

      final updatedSettings = updateFn(companySettings.value!);

      // Optimistic update
      companySettings.value = updatedSettings;

      final result = await _companyService.updateCompanySettings(
        accessToken: token,
        settings: updatedSettings,
      );

      companySettings.value = result;

      if (context.mounted) {
        context.pop(); // Close dialog
        _showSnackBar(context, "Settings updated successfully");
      }
    } catch (e) {
      log("Update Error: $e");
      if (context.mounted) {
        _showDialog(context, "Update Failed", e.toString());
      }
    } finally {
      isSaving.value = false;
    }
  }

  // --- UTILS ---
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
          TextButton(onPressed: () => context.pop(), child: const Text("OK"))
        ],
      ),
    );
  }

  Color getColorFromHex(String hexColor) {
    try {
      if (hexColor.isEmpty) return Colors.grey;
      hexColor = hexColor.toUpperCase().replaceAll("#", "");
      if (hexColor.length == 6) {
        hexColor = "FF$hexColor";
      }
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }
}

// Extension to help with copyWith since we don't have the model file to edit
extension CompanySettingsExt on CompanySettings {
  CompanySettings copyWith({
    String? companyName,
    String? companyEmail,
    String? companyPhone,
    String? companyAddresses,
    String? rcNumber,
    String? primaryColorCode,
    String? secondaryColorCode,
    String? companySlogan,
    String? defaultCurrency,
    String? languagePreference,
    String? businessRules,
    String? companyLogo,
  }) {
    return CompanySettings(
      id: id,
      companyName: companyName ?? this.companyName,
      companyEmail: companyEmail ?? this.companyEmail,
      companyPhone: companyPhone ?? this.companyPhone,
      companyAddresses: companyAddresses ?? this.companyAddresses,
      rcNumber: rcNumber ?? this.rcNumber,
      primaryColorCode: primaryColorCode ?? this.primaryColorCode,
      secondaryColorCode: secondaryColorCode ?? this.secondaryColorCode,
      companySlogan: companySlogan ?? this.companySlogan,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      languagePreference: languagePreference ?? this.languagePreference,
      businessRules: businessRules ?? this.businessRules,
      companyLogo: companyLogo ?? this.companyLogo,
      createdAt: createdAt,
      updatedAt: DateTime.now().toIso8601String(),
    );
  }

  // Helper for update JSON since method in model might be restricted
  Map<String, dynamic> toUpdateJson() {
    return {
      "company_name": companyName,
      "company_email": companyEmail,
      "company_phone": companyPhone,
      "company_addresses": companyAddresses,
      "company_slogan": companySlogan,
      "primary_color_code": primaryColorCode,
      "secondary_color_code": secondaryColorCode,
      "default_currency": defaultCurrency,
      "language_preference": languagePreference,
      "business_rules": businessRules,
      // "company_logo": companyLogo, // Often handled separately via multipart
    };
  }
}
