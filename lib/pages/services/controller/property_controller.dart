import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../../../src/services/service_service.dart';
import '../models/property_model.dart';

class PropertyController extends GetxController {
  final ServiceService _service = ServiceService();
  final _storage = const FlutterSecureStorage();

  var isLoading = false.obs;
  var properties = <Property>[].obs;
  var errorMessage = ''.obs;

  // Selected property for detail page
  var selectedProperty = Rxn<Property>();

  // Active filter state (preserved across pagination)
  var activeSearch = Rxn<String>();
  var activeStatus = Rxn<String>();
  var activeCategory = Rxn<String>();
  var activePropertyType = Rxn<String>();

  int limit = 100;
  int offset = 0;
  var currentPage = 1.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProperties();
  }

  Future<void> fetchProperties({
    String? search,
    String? status,
    String? propertyType,
    String? category,
    bool preserveFilters = false,
  }) async {
    try {
      isLoading(true);
      errorMessage('');

      // Store filters if not preserving (i.e. new filter applied)
      if (!preserveFilters) {
        activeSearch.value = search;
        activeStatus.value = status;
        activeCategory.value = category;
        activePropertyType.value = propertyType;
      }

      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        errorMessage('Authentication token not found');
        return;
      }

      offset = (currentPage.value - 1) * limit;

      final result = await _service.getProperties(
        token,
        search: activeSearch.value,
        status: activeStatus.value,
        propertyType: activePropertyType.value,
        category: activeCategory.value,
        limit: limit,
        offset: offset,
      );
      properties.assignAll(result);
    } catch (e) {
      errorMessage('Failed to load properties: $e');
      log("Fetch Properties Error: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchPropertyById(int propertyId) async {
    try {
      isLoading(true);
      errorMessage('');

      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        errorMessage('Authentication token not found');
        return;
      }

      final result = await _service.getPropertyById(token, propertyId);
      selectedProperty.value = result;
    } catch (e) {
      errorMessage('Failed to load property: $e');
      log("Fetch Property Error: $e");
    } finally {
      isLoading(false);
    }
  }

  void nextPage() {
    currentPage.value++;
    fetchProperties(preserveFilters: true);
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      fetchProperties(preserveFilters: true);
    }
  }

  void goToPage(int page) {
    if (page > 0) {
      currentPage.value = page;
      fetchProperties(preserveFilters: true);
    }
  }

  void clearFilters() {
    activeSearch.value = null;
    activeStatus.value = null;
    activeCategory.value = null;
    activePropertyType.value = null;
    currentPage.value = 1;
    fetchProperties();
  }

  Future<bool> createProperty(Map<String, dynamic> data) async {
    try {
      isLoading(true);
      errorMessage('');

      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        errorMessage('Authentication token not found');
        return false;
      }

      await _service.createProperty(token, data);
      fetchProperties(preserveFilters: true);
      return true;
    } catch (e) {
      errorMessage('Failed to create property: $e');
      log("Create Property Error: $e");
      return false;
    } finally {
      isLoading(false);
    }
  }

  Future<bool> updateProperty(int propertyId, Map<String, dynamic> data) async {
    try {
      isLoading(true);
      errorMessage('');

      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        errorMessage('Authentication token not found');
        return false;
      }

      final updated = await _service.updateProperty(token, propertyId, data);
      selectedProperty.value = updated;
      fetchProperties(preserveFilters: true);
      return true;
    } catch (e) {
      errorMessage('Failed to update property: $e');
      log("Update Property Error: $e");
      return false;
    } finally {
      isLoading(false);
    }
  }
}
