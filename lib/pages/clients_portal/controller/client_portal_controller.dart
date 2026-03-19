import 'dart:developer';
import 'package:get/get.dart';

import '../../../main.dart';
import '../../../src/services/crm/crm_service.dart';

class ClientPortalController extends GetxController {
  final CrmService _crmService = CrmService();

  // ─── Observables ────────────────────────────────────────────────────
  var totalClients = 0.obs;
  var activeClients = 0.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPortalStats();
  }

  Future<void> fetchPortalStats() async {
    try {
      isLoading.value = true;
      final token = _getToken();
      if (token.isEmpty) {
        log('ClientPortalController: No access token found');
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

  String _getToken() {
    String token = prefs.getString('access_token') ?? '';
    if (token.startsWith('Bearer ')) {
      token = token.replaceFirst('Bearer ', '');
    }
    return token.replaceAll('"', '').trim();
  }
}
