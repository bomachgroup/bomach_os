import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../src/services/crm/crm_service.dart';

class CrmController extends GetxController {
  final CrmService _service = CrmService();
  final _storage = const FlutterSecureStorage();

  // ─── Loading ──────────────────────────────────────────────────────
  var isLoadingClients = true.obs;
  var isLoadingLeads = true.obs;
  var isSaving = false.obs;

  // ─── Data ─────────────────────────────────────────────────────────
  var clientList = <CrmClient>[].obs;
  var leadList = <CrmLead>[].obs;
  var totalClients = 0.obs;
  var totalLeads = 0.obs;

  // ─── Search ───────────────────────────────────────────────────────
  var clientSearch = ''.obs;
  var leadSearch = ''.obs;
  var leadStatusFilter = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchClients();
    fetchLeads();
  }

  // ─── CLIENTS ──────────────────────────────────────────────────────

  Future<void> fetchClients({bool refresh = false}) async {
    try {
      if (!refresh) isLoadingClients.value = true;
      final token = await _getToken();
      if (token == null) return;

      final result = await _service.getClients(
        token,
        search:
            clientSearch.value.isNotEmpty ? clientSearch.value : null,
      );
      clientList.assignAll(result.items);
      totalClients.value = result.total;
    } catch (e) {
      log("Error fetching clients: $e");
    } finally {
      isLoadingClients.value = false;
    }
  }

  Future<void> createClient(
      BuildContext context, Map<String, dynamic> data) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return;

      await _service.createClient(token, data);

      if (context.mounted) {
        Navigator.pop(context);
        fetchClients(refresh: true);
        _showSnackBar(context, "Client created successfully");
      }
    } catch (e) {
      log("Create Client Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to create client: ${e.toString()}");
      }
    } finally {
      isSaving.value = false;
    }
  }

  // ─── LEADS ────────────────────────────────────────────────────────

  Future<void> fetchLeads({bool refresh = false}) async {
    try {
      if (!refresh) isLoadingLeads.value = true;
      final token = await _getToken();
      if (token == null) return;

      final result = await _service.getLeads(
        token,
        search: leadSearch.value.isNotEmpty ? leadSearch.value : null,
        status: leadStatusFilter.value.isNotEmpty
            ? leadStatusFilter.value
            : null,
      );
      leadList.assignAll(result.items);
      totalLeads.value = result.total;
    } catch (e) {
      log("Error fetching leads: $e");
    } finally {
      isLoadingLeads.value = false;
    }
  }

  Future<void> createLead(
      BuildContext context, Map<String, dynamic> data) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return;

      await _service.createLead(token, data);

      if (context.mounted) {
        Navigator.pop(context);
        fetchLeads(refresh: true);
        _showSnackBar(context, "Lead created successfully");
      }
    } catch (e) {
      log("Create Lead Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to create lead: ${e.toString()}");
      }
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteLead(BuildContext context, int leadId) async {
    try {
      final token = await _getToken();
      if (token == null) return;

      await _service.deleteLead(token, leadId);

      if (context.mounted) {
        fetchLeads(refresh: true);
        _showSnackBar(context, "Lead deleted successfully");
      }
    } catch (e) {
      log("Delete Lead Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to delete lead");
      }
    }
  }

  Future<void> convertLeadToClient(
      BuildContext context, int leadId) async {
    try {
      final token = await _getToken();
      if (token == null) return;

      await _service.convertLeadToClient(token, leadId);

      if (context.mounted) {
        fetchLeads(refresh: true);
        fetchClients(refresh: true);
        _showSnackBar(context, "Lead converted to client successfully");
      }
    } catch (e) {
      log("Convert Lead Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to convert lead");
      }
    }
  }

  // ─── SEARCH ───────────────────────────────────────────────────────

  void onClientSearchChanged(String val) {
    clientSearch.value = val;
    fetchClients();
  }

  void onLeadSearchChanged(String val) {
    leadSearch.value = val;
    fetchLeads();
  }

  void onLeadStatusFilterChanged(String? val) {
    leadStatusFilter.value = val ?? '';
    fetchLeads();
  }

  // ─── HELPERS ──────────────────────────────────────────────────────

  Future<String?> _getToken() async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith("Bearer ")) {
      token = token.replaceFirst("Bearer ", "");
    }
    return token.replaceAll('"', '').trim();
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c), child: const Text("OK")),
        ],
      ),
    );
  }
}
