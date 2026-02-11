import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../../../src/services/auth_service.dart';
import '../models/lead_model.dart';

class LeadController extends GetxController {
  final AuthService _authService = AuthService();
  final _storage = const FlutterSecureStorage();

  var isLoading = false.obs;
  var isSaving = false.obs;
  var leads = <Lead>[].obs;
  var errorMessage = ''.obs;

  int limit = 100;
  int offset = 0;
  var currentPage = 1.obs;
  var totalItems = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLeads();
  }

  Future<void> fetchLeads({String? status, String? search}) async {
    try {
      isLoading(true);
      errorMessage('');

      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        errorMessage('Authentication token not found');
        return;
      }

      offset = (currentPage.value - 1) * limit;

      final result = await _authService.getLeads(
        token,
        status: status,
        search: search,
        limit: limit,
        offset: offset,
      );
      leads.assignAll(result);
    } catch (e) {
      errorMessage('Failed to load leads: $e');
      log("Fetch Leads Error: $e");
    } finally {
      isLoading(false);
    }
  }

  void nextPage({String? status, String? search}) {
    currentPage.value++;
    fetchLeads(status: status, search: search);
  }

  void previousPage({String? status, String? search}) {
    if (currentPage.value > 1) {
      currentPage.value--;
      fetchLeads(status: status, search: search);
    }
  }

  void goToPage(int page, {String? status, String? search}) {
    if (page > 0) {
      currentPage.value = page;
      fetchLeads(status: status, search: search);
    }
  }

  Future<bool> createLead(Map<String, dynamic> leadData) async {
    try {
      isSaving(true);

      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        errorMessage('Authentication token not found');
        return false;
      }

      await _authService.createLead(token, leadData);
      await fetchLeads();
      return true;
    } catch (e) {
      errorMessage('Failed to create lead: $e');
      log("Create Lead Error: $e");
      return false;
    } finally {
      isSaving(false);
    }
  }

  Future<bool> updateLead(int leadId, Map<String, dynamic> leadData) async {
    try {
      isSaving(true);

      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        errorMessage('Authentication token not found');
        return false;
      }

      await _authService.updateLead(token, leadId, leadData);
      await fetchLeads();
      return true;
    } catch (e) {
      errorMessage('Failed to update lead: $e');
      log("Update Lead Error: $e");
      return false;
    } finally {
      isSaving(false);
    }
  }

  Future<bool> deleteLead(int leadId) async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        errorMessage('Authentication token not found');
        return false;
      }

      await _authService.deleteLead(token, leadId);
      leads.removeWhere((l) => l.id == leadId);
      return true;
    } catch (e) {
      errorMessage('Failed to delete lead: $e');
      log("Delete Lead Error: $e");
      await fetchLeads();
      return false;
    }
  }

  Future<bool> convertLeadToClient(int leadId) async {
    try {
      isSaving(true);

      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        errorMessage('Authentication token not found');
        return false;
      }

      await _authService.convertLeadToClient(token, leadId);
      await fetchLeads();
      return true;
    } catch (e) {
      errorMessage('Failed to convert lead to client: $e');
      log("Convert Lead Error: $e");
      return false;
    } finally {
      isSaving(false);
    }
  }
}
