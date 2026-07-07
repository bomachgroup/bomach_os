import 'dart:developer';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../src/services/legal/legal_contract_service.dart';

class LegalContractController extends GetxController {
  final LegalContractService _service = LegalContractService();
  final _storage = const FlutterSecureStorage();

  var isLoading = true.obs;
  var contractList = <ContractWithType>[].obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchContracts();
  }

  Future<void> fetchContracts({bool refresh = false}) async {
    try {
      if (!refresh) isLoading.value = true;

      final token = await _getToken();
      if (token == null) return;

      final result = await _service.getContracts(
        token,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
      );

      // Transform to ContractWithType for display
      contractList.assignAll(
        result.items.map((c) => ContractWithType(contract: c)),
      );
    } catch (e) {
      log("Error fetching contracts: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void onSearchChanged(String val) {
    searchQuery.value = val;
    fetchContracts();
  }

  Future<String?> _getToken() async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith("Bearer ")) {
      token = token.replaceFirst("Bearer ", "");
    }
    return token.replaceAll('"', '').trim();
  }
}

class ContractWithType {
  final dynamic contract;
  ContractWithType({required this.contract});
}
