import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../../../src/services/auth_service.dart';
import '../models/client_model.dart';

class ClientController extends GetxController {
  final AuthService _authService = AuthService();
  final _storage = const FlutterSecureStorage();

  var isLoading = false.obs;
  var isSaving = false.obs;
  var clients = <Client>[].obs;
  var errorMessage = ''.obs;

  int limit = 100;
  int offset = 0;
  var currentPage = 1.obs;
  var totalItems = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchClients();
  }

  Future<void> fetchClients({String? search}) async {
    try {
      isLoading(true);
      errorMessage('');

      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        errorMessage('Authentication token not found');
        return;
      }

      offset = (currentPage.value - 1) * limit;

      final result = await _authService.getClients(
        token,
        search: search,
        limit: limit,
        offset: offset,
      );
      clients.assignAll(result);
    } catch (e) {
      errorMessage('Failed to load clients: $e');
      log("Fetch Clients Error: $e");
    } finally {
      isLoading(false);
    }
  }

  void nextPage({String? search}) {
    currentPage.value++;
    fetchClients(search: search);
  }

  void previousPage({String? search}) {
    if (currentPage.value > 1) {
      currentPage.value--;
      fetchClients(search: search);
    }
  }

  void goToPage(int page, {String? search}) {
    if (page > 0) {
      currentPage.value = page;
      fetchClients(search: search);
    }
  }

  Future<bool> createClient(Map<String, dynamic> clientData) async {
    try {
      isSaving(true);

      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        errorMessage('Authentication token not found');
        return false;
      }

      await _authService.createClient(token, clientData);
      await fetchClients();
      return true;
    } catch (e) {
      errorMessage('Failed to create client: $e');
      log("Create Client Error: $e");
      return false;
    } finally {
      isSaving(false);
    }
  }

  Future<bool> updateClient(int clientId, Map<String, dynamic> clientData) async {
    try {
      isSaving(true);

      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        errorMessage('Authentication token not found');
        return false;
      }

      await _authService.updateClient(token, clientId, clientData);
      await fetchClients();
      return true;
    } catch (e) {
      errorMessage('Failed to update client: $e');
      log("Update Client Error: $e");
      return false;
    } finally {
      isSaving(false);
    }
  }

  Future<bool> deleteClient(int clientId) async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        errorMessage('Authentication token not found');
        return false;
      }

      await _authService.deleteClient(token, clientId);
      clients.removeWhere((c) => c.id == clientId);
      return true;
    } catch (e) {
      errorMessage('Failed to delete client: $e');
      log("Delete Client Error: $e");
      await fetchClients();
      return false;
    }
  }
}
