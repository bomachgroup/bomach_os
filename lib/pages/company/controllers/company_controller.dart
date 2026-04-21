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

  // Equity (local state — API endpoint not yet available)
  var authorizedShares = 0.obs;
  var isEquityLoading = false.obs;

  int get issuedShares =>
      shareholders.fold<int>(0, (sum, s) => sum + s.shareCount);

  int get unissuedShares {
    final auth = authorizedShares.value;
    final issued = issuedShares;
    return auth > issued ? auth - issued : 0;
  }

  List<Shareholder> get boardMembers =>
      shareholders.where((s) => s.isBoardMember).toList();

  // Board Members search
  var boardSearchQuery = ''.obs;

  List<Shareholder> get filteredBoardMembers {
    final query = boardSearchQuery.value.toLowerCase();
    if (query.isEmpty) return boardMembers;
    return boardMembers.where((s) {
      return s.fullName.toLowerCase().contains(query) ||
          s.email.toLowerCase().contains(query) ||
          s.titleDisplay.toLowerCase().contains(query);
    }).toList();
  }

// Compliance
  var complianceList = <Compliance>[].obs;
  var isComplianceLoading = false.obs;
  var complianceSearchQuery = ''.obs;

  // Audit
  var auditLogs = <AuditLog>[].obs;
  var isAuditLoading = false.obs;
  var auditLogsTotal = 0.obs;
  var auditPage = 0.obs;
  static const auditPageSize = 10;

  // Dashboard Stats
  var dashboardStats = Rxn<DashboardStats>();
  var isDashboardLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCompanyProfile();
    fetchDashboardStats();
    fetchShareholders();
    fetchEquityInfo();
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
      if (context.mounted) {
        _showSnackBar(context, "Failed to update: $e", isError: true);
      }
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

  List<Compliance> get filteredComplianceList {
    final query = complianceSearchQuery.value.toLowerCase();
    if (query.isEmpty) return complianceList;
    return complianceList.where((item) {
      return item.complianceType.toLowerCase().contains(query) ||
          item.referenceNumber.toLowerCase().contains(query) ||
          item.fullName.toLowerCase().contains(query) ||
          item.issuingAuthority.toLowerCase().contains(query) ||
          item.status.toLowerCase().contains(query) ||
          item.description.toLowerCase().contains(query);
    }).toList();
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
      if (context.mounted) {
        _showSnackBar(context, "Error: $e", isError: true);
      }
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> updateCompliance(
      BuildContext context, String id, Compliance item) async {
    try {
      isSaving.value = true;
      final token = await _storage.read(key: 'access_token');
      if (token != null) {
        await _companyService.updateCompliance(token, id, item);
        await fetchComplianceRecords();
        if (context.mounted) {
          Navigator.pop(context);
          _showSnackBar(context, "Compliance record updated");
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, "Error: $e", isError: true);
      }
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteCompliance(BuildContext context, String id) async {
    try {
      isSaving.value = true;
      final token = await _storage.read(key: 'access_token');
      if (token != null) {
        await _companyService.deleteCompliance(token, id);
        complianceList.removeWhere((c) => c.id == id);
        if (context.mounted) {
          _showSnackBar(context, "Compliance record deleted");
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, "Error: $e", isError: true);
      }
    } finally {
      isSaving.value = false;
    }
  }

  // --- AUDIT OPERATIONS ---
  Future<void> fetchAuditLogs({int page = 0}) async {
    try {
      isAuditLoading.value = true;
      auditPage.value = page;
      final token = await _storage.read(key: 'access_token');
      if (token != null) {
        final result = await _companyService.getAuditLogs(
          token,
          limit: auditPageSize,
          offset: page * auditPageSize,
        );
        auditLogs.assignAll(result.items);
        auditLogsTotal.value = result.count;
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

  Future<void> createShareholder(
      BuildContext context, Map<String, dynamic> data) async {
    try {
      isSaving.value = true;
      final token = await _storage.read(key: 'access_token');
      if (token == null) return;

      await _companyService.createShareholder(token, data);
      await fetchShareholders();
      await fetchEquityInfo();

      if (context.mounted) {
        Navigator.pop(context);
        _showSnackBar(context, "Shareholder added successfully");
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, "Failed to add shareholder: $e", isError: true);
      }
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> updateShareholder(
      BuildContext context, int id, Map<String, dynamic> data) async {
    try {
      isSaving.value = true;
      final token = await _storage.read(key: 'access_token');
      if (token == null) return;

      await _companyService.updateShareholder(token, id, data);
      await fetchShareholders();
      await fetchEquityInfo();

      if (context.mounted) {
        Navigator.pop(context);
        _showSnackBar(context, "Shareholder updated successfully");
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, "Failed to update shareholder: $e",
            isError: true);
      }
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteShareholder(BuildContext context, int id) async {
    try {
      isSaving.value = true;
      final token = await _storage.read(key: 'access_token');
      if (token == null) return;

      await _companyService.deleteShareholder(token, id);
      shareholders.removeWhere((s) => s.id == id);
      await fetchEquityInfo();

      if (context.mounted) {
        _showSnackBar(context, "Shareholder removed successfully");
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, "Failed to remove shareholder: $e",
            isError: true);
      }
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> fetchEquityInfo() async {
    try {
      isEquityLoading.value = true;
      // Try API first
      final token = await _storage.read(key: 'access_token');
      if (token != null) {
        try {
          final info = await _companyService.getEquityInfo(token);
          authorizedShares.value = info.authorizedShares;
          return;
        } catch (_) {
          // API not available — fall back to local storage
        }
      }
      // Fall back to locally saved value
      final saved = await _storage.read(key: 'authorized_shares');
      if (saved != null) {
        authorizedShares.value = int.tryParse(saved) ?? 0;
      }
    } catch (e) {
      log("Error loading equity info: $e");
    } finally {
      isEquityLoading.value = false;
    }
  }

  Future<void> updateEquityValue(BuildContext context, int shares) async {
    try {
      isSaving.value = true;
      // Try API first
      final token = await _storage.read(key: 'access_token');
      if (token != null) {
        try {
          final result = await _companyService.updateEquityInfo(token, shares);
          authorizedShares.value = result.authorizedShares;
        } catch (_) {
          // API not available — save locally
          authorizedShares.value = shares;
          await _storage.write(
              key: 'authorized_shares', value: shares.toString());
        }
      } else {
        authorizedShares.value = shares;
        await _storage.write(
            key: 'authorized_shares', value: shares.toString());
      }

      if (context.mounted) {
        Navigator.pop(context);
        _showSnackBar(context, "Equity value updated successfully");
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, "Failed to update equity: $e", isError: true);
      }
    } finally {
      isSaving.value = false;
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
    String? rcNumber,
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
              rcNumber: rcNumber ?? current.rcNumber,
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
}
