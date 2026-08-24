import 'dart:developer';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../../../src/services/crm/crm_service.dart';

class ClientPortalController extends GetxController {
  final CrmService _crmService = CrmService();
  final _storage = const FlutterSecureStorage();

  // ─── Observables ────────────────────────────────────────────────────
  var totalClients = 0.obs;
  var activeClients = 0.obs;
  var isLoading = false.obs;

  bool _warnedNoToken = false;

  @override
  void onInit() {
    super.onInit();
    fetchPortalStats();
  }

  /// Audit B4 fix: tokens live in FlutterSecureStorage (written at login),
  /// never in SharedPreferences. The old `prefs.getString('access_token')`
  /// read a key nothing ever writes, so stats silently stayed at zero.
  Future<String?> _getToken() async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith('Bearer ')) {
      token = token.replaceFirst('Bearer ', '');
    }
    return token.replaceAll('"', '').trim();
  }

  Future<void> fetchPortalStats() async {
    try {
      isLoading.value = true;
      final token = await _getToken();
      if (token == null) {
        if (!_warnedNoToken) {
          _warnedNoToken = true;
          log('ClientPortalController: No access token found');
        }
        return;
      }

      final result = await _crmService.getClients(token);
      totalClients.value = result.total;
      activeClients.value = result.total;
    } catch (e) {
      log('ClientPortalController: Error fetching portal stats: $e');
      Get.snackbar('Error', 'Failed to load portal stats');
    } finally {
      isLoading.value = false;
    }
  }
}
