import 'dart:developer';

import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../src/services/service_service.dart';
import '../models/service_model.dart';

class ServiceController extends GetxController {
  final ServiceService _service = ServiceService();
  final _storage = const FlutterSecureStorage();

  var isLoading = false.obs;
  var isSaving = false.obs;
  var isLoadingCategories = false.obs;
  var services = <Service>[].obs;
  var categories = <ServiceCategory>[].obs;
  var errorMessage = ''.obs;

  int limit = 100;
  int offset = 0;

  @override
  void onInit() {
    super.onInit();
    fetchServices();
    fetchCategories();
  }

  Future<void> fetchServices(
      {String? status, int? categoryId, String? search}) async {
    try {
      isLoading(true);
      errorMessage('');

      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        errorMessage('Authentication token not found');
        return;
      }

      final result = await _service.getServices(
        token,
        status: status,
        categoryId: categoryId,
        search: search,
        limit: limit,
        offset: offset,
      );
      services.assignAll(result);
    } catch (e) {
      errorMessage('Failed to load services: $e');
      log("Fetch Error: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<Service?> getServiceById(int serviceId) async {
    try {
      isLoading(true);

      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        errorMessage('Authentication token not found');
        return null;
      }

      final result = await _service.getServiceById(token, serviceId);
      return result;
    } catch (e) {
      errorMessage('Failed to load service: $e');
      log("Fetch Error: $e");
      return null;
    } finally {
      isLoading(false);
    }
  }

  Future<bool> createService(Service service) async {
    try {
      isSaving(true);

      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        errorMessage('Authentication token not found');
        return false;
      }

      await _service.createService(token, service);
      await fetchServices();
      return true;
    } catch (e) {
      log("Create Error: $e");
      return false;
    } finally {
      isSaving(false);
    }
  }

  Future<bool> updateService(int serviceId, Service service) async {
    try {
      isSaving(true);

      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        errorMessage('Authentication token not found');
        return false;
      }

      await _service.updateService(token, serviceId, service);
      await fetchServices();
      return true;
    } catch (e) {
      log("Update Error: $e");
      return false;
    } finally {
      isSaving(false);
    }
  }

  Future<bool> deleteService(int serviceId) async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        errorMessage('Authentication token not found');
        return false;
      }

      await _service.deleteService(token, serviceId);
      services.removeWhere((s) => s.id == serviceId);
      return true;
    } catch (e) {
      log("Delete Error: $e");
      await fetchServices();
      return false;
    }
  }

  Future<void> fetchCategories() async {
    try {
      isLoadingCategories(true);

      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        errorMessage('Authentication token not found');
        return;
      }

      final result = await _service.getCategories(token);
      categories.assignAll(result);
    } catch (e) {
      errorMessage('Failed to load categories: $e');
      log("Fetch Categories Error: $e");
    } finally {
      isLoadingCategories(false);
    }
  }
}
