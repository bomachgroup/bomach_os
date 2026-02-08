import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../../../src/model/company_model.dart';
import '../../../src/services/company_service.dart';

class CompanyController extends GetxController {
  final CompanyService _companyService = CompanyService();
  final _storage = const FlutterSecureStorage();

  var isLoading = true.obs;
  var isSaving = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  Rxn<CompanySettings> companySettings = Rxn<CompanySettings>();

  @override
  void onInit() {
    super.onInit();
    fetchCompanyProfile();
  }

  Future<void> fetchCompanyProfile() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      final token = await _storage.read(key: 'access_token');

      if (token != null) {
        final settings =
            await _companyService.getCompanySettings(accessToken: token);
        companySettings.value = settings;
      } else {
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

  Future<void> updateCompanyProfile(
    BuildContext context, {
    required String name,
    required String email,
    required String phone,
    required String address,
    required String rcNumber,
    required String primaryColor,
    required String secondaryColor,
    required String slogan,
    required String currency,
    required String language,
    required String rules,
    String? logoUrl,
  }) async {
    try {
      isSaving.value = true;

      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        if (context.mounted) {
          _showSnackBar(context, "Authentication Error", isError: true);
        }
        return;
      }

      final current = companySettings.value!;
      final updatedSettings = CompanySettings(
        id: current.id,
        companyName: name,
        companyEmail: email,
        companyPhone: phone,
        companyAddresses: address,
        rcNumber: rcNumber,
        primaryColorCode: primaryColor,
        secondaryColorCode: secondaryColor,
        companySlogan: slogan,
        defaultCurrency: currency,
        languagePreference: language,
        businessRules: rules,
        companyLogo: logoUrl ?? current.companyLogo,
        createdAt: current.createdAt,
        updatedAt: DateTime.now().toIso8601String(),
      );

      final result = await _companyService.updateCompanySettings(
        accessToken: token,
        settings: updatedSettings,
      );

      companySettings.value = result;

      if (context.mounted) {
        context.pop();
        _showSnackBar(context, "Company profile updated successfully");
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

  Color getColorFromHex(String hexColor) {
    try {
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
