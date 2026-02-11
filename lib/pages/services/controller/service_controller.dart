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
  var isLoadingQuotes = false.obs;
  var isLoadingOrders = false.obs;
  var services = <Service>[].obs;
  var categories = <ServiceCategory>[].obs;
  var quotes = <Quote>[].obs;
  var orders = <Order>[].obs;
  var errorMessage = ''.obs;

  int limit = 100;
  int offset = 0;
  var currentPage = 1.obs;
  var currentQuotePage = 1.obs;
  var currentOrderPage = 1.obs;
  var totalItems = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchServices();
    fetchCategories();
    fetchQuotes();
    fetchOrders();
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

      offset = (currentPage.value - 1) * limit;

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

  void nextPage({String? status, int? categoryId, String? search}) {
    currentPage.value++;
    fetchServices(status: status, categoryId: categoryId, search: search);
  }

  void previousPage({String? status, int? categoryId, String? search}) {
    if (currentPage.value > 1) {
      currentPage.value--;
      fetchServices(status: status, categoryId: categoryId, search: search);
    }
  }

  void goToPage(int page, {String? status, int? categoryId, String? search}) {
    if (page > 0) {
      currentPage.value = page;
      fetchServices(status: status, categoryId: categoryId, search: search);
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

  Future<void> fetchQuotes({String? status}) async {
    try {
      isLoadingQuotes(true);
      errorMessage('');

      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        errorMessage('Authentication token not found');
        return;
      }

      final quoteOffset = (currentQuotePage.value - 1) * limit;

      final result = await _service.getQuotes(
        token,
        status: status,
        limit: limit,
        offset: quoteOffset,
      );
      quotes.assignAll(result);
    } catch (e) {
      errorMessage('Failed to load quotes: $e');
      log("Fetch Quotes Error: $e");
    } finally {
      isLoadingQuotes(false);
    }
  }

  void nextQuotePage({String? status}) {
    currentQuotePage.value++;
    fetchQuotes(status: status);
  }

  void previousQuotePage({String? status}) {
    if (currentQuotePage.value > 1) {
      currentQuotePage.value--;
      fetchQuotes(status: status);
    }
  }

  void goToQuotePage(int page, {String? status}) {
    if (page > 0) {
      currentQuotePage.value = page;
      fetchQuotes(status: status);
    }
  }

  Future<void> fetchOrders({String? orderStatus, String? paymentStatus}) async {
    try {
      isLoadingOrders(true);
      errorMessage('');

      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        errorMessage('Authentication token not found');
        return;
      }

      final orderOffset = (currentOrderPage.value - 1) * limit;

      final result = await _service.getOrders(
        token,
        orderStatus: orderStatus,
        paymentStatus: paymentStatus,
        limit: limit,
        offset: orderOffset,
      );
      orders.assignAll(result);
    } catch (e) {
      errorMessage('Failed to load orders: $e');
      log("Fetch Orders Error: $e");
    } finally {
      isLoadingOrders(false);
    }
  }

  void nextOrderPage({String? orderStatus, String? paymentStatus}) {
    currentOrderPage.value++;
    fetchOrders(orderStatus: orderStatus, paymentStatus: paymentStatus);
  }

  void previousOrderPage({String? orderStatus, String? paymentStatus}) {
    if (currentOrderPage.value > 1) {
      currentOrderPage.value--;
      fetchOrders(orderStatus: orderStatus, paymentStatus: paymentStatus);
    }
  }

  void goToOrderPage(int page, {String? orderStatus, String? paymentStatus}) {
    if (page > 0) {
      currentOrderPage.value = page;
      fetchOrders(orderStatus: orderStatus, paymentStatus: paymentStatus);
    }
  }
}
