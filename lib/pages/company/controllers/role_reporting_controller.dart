import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../../../src/model/role_reporting_model.dart';
import '../../../src/services/role_service.dart';

class RoleReportingController extends GetxController {
  final RoleService _service;
  final Future<String?> Function()? tokenReader;

  final tree = Rxn<RoleReportingTree>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  RoleReportingController({RoleService? service, this.tokenReader})
      : _service = service ?? RoleService();

  Future<String?> _getToken() async {
    if (tokenReader != null) return tokenReader!();
    return const FlutterSecureStorage().read(key: 'access_token');
  }

  Future<void> fetch(int roleId) async {
    isLoading.value = true;
    errorMessage.value = '';
    tree.value = null;
    try {
      final token = await _getToken();
      if (token == null || token.trim().isEmpty) {
        errorMessage.value = 'Authentication is required to load the org chart.';
        return;
      }
      final data = await _service.getReportingTree(token, roleId);
      tree.value = RoleReportingTree.fromJson(data);
    } catch (e) {
      log('RoleReportingController.fetch error: $e');
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
