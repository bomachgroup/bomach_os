import 'package:bomach_os/pages/operations/models/models.dart';
import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../../../src/services/operations/contract_services.dart';

class ContractController extends GetxController {
  final ContractService _service =
      ContractService(baseUrl: ApiConstants.operationsBaseUrl);
  final _storage = const FlutterSecureStorage();

  var contracts = <Contract>[].obs;
  var isLoading = false.obs;
  var isActionLoading = false.obs;
  var errorMessage = ''.obs;
  var totalCount = 0.obs;
  var currentSearch = ''.obs;

  var currentLimit = 10.obs;
  var currentOffset = 0.obs;

  Future<String?> _getToken(BuildContext context) async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith("Bearer ")) token = token.replaceFirst("Bearer ", "");
    return token.replaceAll('"', '').trim();
  }

  void _showError(BuildContext context, String message) {
    AppToast.error(context, message);
  }

  void _showSuccess(BuildContext context, String message) {
    AppToast.success(context, message);
  }

  Future<void> fetchContracts(BuildContext context,
      {int? projectId, String? search}) async {
    try {
      if (search != null) {
        currentSearch.value = search;
        currentOffset.value = 0;
      }
      isLoading.value = true;
      errorMessage.value = '';

      final token = await _getToken(context);
      if (token == null) throw Exception("Authentication token not found");

      final result = await _service.getContracts(
        accessToken: token,
        projectId: projectId,
        search: currentSearch.value.isEmpty ? null : currentSearch.value,
        limit: currentLimit.value,
        offset: currentOffset.value,
      );

      contracts.assignAll(result.items);
      totalCount.value = result.count;
    } catch (e) {
      errorMessage.value = e.toString();
      _showError(context, "Error loading contracts: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createContract(BuildContext context, Contract contract) async {
    try {
      isActionLoading.value = true;
      final token = await _getToken(context);
      if (token == null) throw Exception("Authentication token not found");

      await _service.createContract(accessToken: token, contract: contract);

      _showSuccess(context, "Contract created successfully");
      Navigator.of(context).pop();

      fetchContracts(context,
          projectId: contract.projectId != 0 ? contract.projectId : null);
    } catch (e) {
      _showError(context, "Failed to create contract: ${e.toString()}");
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> updateContract(
      BuildContext context, int id, Contract contract) async {
    try {
      isActionLoading.value = true;
      final token = await _getToken(context);
      if (token == null) throw Exception("Authentication token not found");

      await _service.updateContract(
          accessToken: token, contractId: id, contract: contract);

      _showSuccess(context, "Contract updated successfully");
      Navigator.of(context).pop();

      fetchContracts(context,
          projectId: contract.projectId != 0 ? contract.projectId : null);
    } catch (e) {
      _showError(context, "Failed to update contract: ${e.toString()}");
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> updateContractStatus(
      BuildContext context, int id, String status) async {
    try {
      isActionLoading.value = true;
      final token = await _getToken(context);
      if (token == null) throw Exception("Authentication token not found");

      await _service.updateContractStatus(
          accessToken: token, contractId: id, status: status);

      _showSuccess(context, "Contract status updated to $status");
      fetchContracts(context);
    } catch (e) {
      _showError(context, "Failed to update contract status: ${e.toString()}");
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> deleteContract(
      BuildContext context, int id, int? projectId) async {
    try {
      isActionLoading.value = true;
      final token = await _getToken(context);
      if (token == null) throw Exception("Authentication token not found");

      await _service.deleteContract(accessToken: token, contractId: id);

      _showSuccess(context, "Contract deleted successfully");

      if (Navigator.canPop(context)) {}

      fetchContracts(context, projectId: projectId);
    } catch (e) {
      _showError(context, "Failed to delete contract: ${e.toString()}");
    } finally {
      isActionLoading.value = false;
    }
  }
}
