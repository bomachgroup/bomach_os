import 'dart:developer';
import 'package:bms_front_end/src/services/hr/hr_services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class HRController extends GetxController {
  final HRServices _hrService = HRServices();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Reactive variables
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var stats = Rxn<DashboardStatsModel>(); // Nullable reactive variable

  @override
  void onInit() {
    super.onInit();
    fetchDashboardStats();
  }

  Future<String?> _getToken() async {
    String? token = await _storage.read(key: 'access_token');

    if (token == null) return null;

    if (token.startsWith("Bearer ")) token = token.replaceFirst("Bearer ", "");

    return token.replaceAll('"', '').trim();
  }

  Future<void> fetchDashboardStats() async {
    try {
      isLoading.value = true;
      errorMessage.value = ''; // Reset error message
      final token = await _getToken();
      if (token == null) return;
      final result = await _hrService.getDashboardStats(token);
      stats.value = result;
    } catch (e) {
      errorMessage.value = e.toString();
      log('Error in HRController: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
