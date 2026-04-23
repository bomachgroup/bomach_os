import 'dart:developer';
import 'package:bms_front_end/components/dialog/dialog_scaffold.dart';
import 'package:bms_front_end/components/feedback/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:bms_front_end/src/model/board_model.dart';
import 'package:bms_front_end/src/model/approval_model.dart';
import 'package:bms_front_end/src/services/approval_service.dart';

class ApprovalController extends GetxController {
  final ApprovalService _approvalService = ApprovalService();
  final _storage = const FlutterSecureStorage();

  // ─── Current tab ───────────────────────────────────────────────────
  var currentTab = 'Workflows'.obs;

  // ─── Flows state ───────────────────────────────────────────────────
  var isLoadingFlows = true.obs;
  var isSavingFlow = false.obs;
  var flowList = <ApprovalFlow>[].obs;
  var flowSearchQuery = ''.obs;
  var flowCurrentPage = 1.obs;
  var flowLimit = 10.obs;
  var flowTotalItems = 0.obs;

  // ─── Requests state ────────────────────────────────────────────────
  var isLoadingRequests = true.obs;
  var isSavingRequest = false.obs;
  var requestList = <ApprovalRequest>[].obs;
  var requestSearchQuery = ''.obs;
  var requestCurrentPage = 1.obs;
  var requestLimit = 10.obs;
  var requestTotalItems = 0.obs;

  // ─── Field choices ─────────────────────────────────────────────────
  var flowChoices = Rxn<ApprovalFlowChoices>();

  @override
  void onInit() {
    super.onInit();
    fetchFlows();
    fetchRequests();
    loadFlowChoices();
  }

  // ─── FLOWS CRUD ────────────────────────────────────────────────────

  Future<void> fetchFlows({bool refresh = false}) async {
    try {
      if (!refresh) isLoadingFlows.value = true;

      final token = await _getToken();
      if (token == null) return;

      final offset = (flowCurrentPage.value - 1) * flowLimit.value;

      final result = await _approvalService.getFlows(
        accessToken: token,
        search: flowSearchQuery.value.isNotEmpty ? flowSearchQuery.value : null,
        limit: flowLimit.value,
        offset: offset,
      );

      flowList.assignAll(result.items);
      flowTotalItems.value = result.total;
    } catch (e) {
      log("Error fetching approval flows: $e");
    } finally {
      isLoadingFlows.value = false;
    }
  }

  Future<void> createFlow(
      BuildContext context, Map<String, dynamic> data) async {
    try {
      isSavingFlow.value = true;
      final token = await _getToken();
      if (token == null) return;

      log("Create Approval Flow payload: $data");
      await _approvalService.createFlow(accessToken: token, data: data);

      if (context.mounted) {
        Navigator.pop(context);
        fetchFlows(refresh: true);
        _showSnackBar(context, "Workflow created successfully");
      }
    } catch (e) {
      log("Create Flow Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to create workflow: ${e.toString()}");
      }
    } finally {
      isSavingFlow.value = false;
    }
  }

  Future<void> updateFlow(
      BuildContext context, int id, Map<String, dynamic> data) async {
    try {
      isSavingFlow.value = true;
      final token = await _getToken();
      if (token == null) return;

      log("Update Approval Flow payload: $data");
      await _approvalService.updateFlow(
          accessToken: token, flowId: id, data: data);

      if (context.mounted) {
        Navigator.pop(context);
        fetchFlows(refresh: true);
        _showSnackBar(context, "Workflow updated successfully");
      }
    } catch (e) {
      log("Update Flow Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to update workflow");
      }
    } finally {
      isSavingFlow.value = false;
    }
  }

  Future<void> deleteFlow(BuildContext context, int id) async {
    try {
      final token = await _getToken();
      if (token == null) return;

      await _approvalService.deleteFlow(accessToken: token, flowId: id);

      if (context.mounted) {
        fetchFlows(refresh: true);
        _showSnackBar(context, "Workflow deactivated successfully");
      }
    } catch (e) {
      log("Delete Flow Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to deactivate workflow");
      }
    }
  }

  // ─── REQUESTS ──────────────────────────────────────────────────────

  Future<void> fetchRequests({bool refresh = false}) async {
    try {
      if (!refresh) isLoadingRequests.value = true;

      final token = await _getToken();
      if (token == null) return;

      final offset = (requestCurrentPage.value - 1) * requestLimit.value;

      final result = await _approvalService.getRequests(
        accessToken: token,
        search: requestSearchQuery.value.isNotEmpty
            ? requestSearchQuery.value
            : null,
        limit: requestLimit.value,
        offset: offset,
      );

      requestList.assignAll(result.items);
      requestTotalItems.value = result.total;
    } catch (e) {
      log("Error fetching approval requests: $e");
    } finally {
      isLoadingRequests.value = false;
    }
  }

  Future<void> approveRequest(BuildContext context, int requestId) async {
    try {
      final token = await _getToken();
      if (token == null) return;

      await _approvalService.approveRequest(
          accessToken: token, requestId: requestId);

      if (context.mounted) {
        fetchRequests(refresh: true);
        _showSnackBar(context, "Request approved successfully");
      }
    } catch (e) {
      log("Approve Request Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to approve request");
      }
    }
  }

  Future<void> rejectRequest(BuildContext context, int requestId,
      {String? reason}) async {
    try {
      final token = await _getToken();
      if (token == null) return;

      await _approvalService.rejectRequest(
        accessToken: token,
        requestId: requestId,
        data: reason != null ? {'reason': reason} : null,
      );

      if (context.mounted) {
        fetchRequests(refresh: true);
        _showSnackBar(context, "Request rejected");
      }
    } catch (e) {
      log("Reject Request Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to reject request");
      }
    }
  }

  Future<void> cancelRequest(BuildContext context, int requestId) async {
    try {
      final token = await _getToken();
      if (token == null) return;

      await _approvalService.cancelRequest(
          accessToken: token, requestId: requestId);

      if (context.mounted) {
        fetchRequests(refresh: true);
        _showSnackBar(context, "Request cancelled");
      }
    } catch (e) {
      log("Cancel Request Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to cancel request");
      }
    }
  }

  // ─── FIELD CHOICES ─────────────────────────────────────────────────

  Future<void> loadFlowChoices() async {
    try {
      final token = await _getToken();
      if (token == null) return;

      flowChoices.value =
          await _approvalService.getFlowChoices(accessToken: token);
    } catch (e) {
      log("Error loading flow choices: $e");
      // Fallback defaults based on Figma design
      flowChoices.value = ApprovalFlowChoices(
        actions: [
          BoardFieldOption(value: 'spend_request', label: 'Spend Request'),
          BoardFieldOption(value: 'contract', label: 'Contract'),
          BoardFieldOption(value: 'offer', label: 'Offer'),
          BoardFieldOption(value: 'access_request', label: 'Access Request'),
          BoardFieldOption(value: 'leave_request', label: 'Leave Request'),
        ],
        approverTypes: [
          BoardFieldOption(value: 'HOD', label: 'Department Head'),
          BoardFieldOption(value: 'COO', label: 'COO'),
          BoardFieldOption(value: 'HOB', label: 'Branch Head'),
          BoardFieldOption(value: 'HOR', label: 'Regional Head'),
          BoardFieldOption(value: 'HOS', label: 'State Head'),
        ],
        statuses: [
          BoardFieldOption(value: 'active', label: 'Active'),
          BoardFieldOption(value: 'inactive', label: 'Inactive'),
        ],
        levels: [
          BoardFieldOption(value: '1', label: '1 Level'),
          BoardFieldOption(value: '2', label: '2 Levels'),
          BoardFieldOption(value: '3', label: '3 Levels'),
          BoardFieldOption(value: '4', label: '4 Levels'),
          BoardFieldOption(value: '5', label: '5 Levels'),
        ],
      );
    }
  }

  // ─── SEARCH / FILTER ───────────────────────────────────────────────

  void onFlowSearchChanged(String val) {
    flowSearchQuery.value = val;
    flowCurrentPage.value = 1;
    fetchFlows();
  }

  void onRequestSearchChanged(String val) {
    requestSearchQuery.value = val;
    requestCurrentPage.value = 1;
    fetchRequests();
  }

  // ─── PAGINATION ────────────────────────────────────────────────────

  void flowGoToPage(int page) {
    flowCurrentPage.value = page;
    fetchFlows();
  }

  void flowSetLimit(int newLimit) {
    flowLimit.value = newLimit;
    flowCurrentPage.value = 1;
    fetchFlows();
  }

  void requestGoToPage(int page) {
    requestCurrentPage.value = page;
    fetchRequests();
  }

  void requestSetLimit(int newLimit) {
    requestLimit.value = newLimit;
    requestCurrentPage.value = 1;
    fetchRequests();
  }

  // ─── HELPERS ───────────────────────────────────────────────────────

  Future<String?> _getToken() async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith("Bearer ")) {
      token = token.replaceFirst("Bearer ", "");
    }
    return token.replaceAll('"', '').trim();
  }

  void _showSnackBar(BuildContext context, String message) {
    AppToast.success(context, message);
  }

  void _showErrorDialog(BuildContext context, String message) {
    DialogScaffold.show(
      context,
      title: "Error",
      size: DialogSize.sm,
      body: Text(message),
      actions: [TextButton(
              onPressed: () => Navigator.pop(context), child: const Text("OK")),],
    );
  }
}
