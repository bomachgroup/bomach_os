import 'dart:developer';

import 'package:bms_front_end/src/constants/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class PaymentApprovalController extends GetxController {
  final _storage = const FlutterSecureStorage();
  final Dio _dio = Dio(BaseOptions(
    baseUrl: '${ApiConstants.baseUrl}/api/v1',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  var pendingInvoices = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPendingApprovals();
  }

  Future<String?> _getToken() async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith("Bearer ")) {
      token = token.replaceFirst("Bearer ", "");
    }
    return token.replaceAll('"', '').trim();
  }

  Future<void> fetchPendingApprovals() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final token = await _getToken();
      if (token == null) {
        errorMessage.value = 'Authentication token not found';
        return;
      }

      final response = await _dio.get(
        '/estate-invoices/pending-approvals',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final data = response.data;
      if (data is List) {
        pendingInvoices.assignAll(
          data.map((e) => Map<String, dynamic>.from(e)).toList(),
        );
      } else if (data is Map && data.containsKey('items')) {
        pendingInvoices.assignAll(
          (data['items'] as List)
              .map((e) => Map<String, dynamic>.from(e))
              .toList(),
        );
      } else if (data is Map && data.containsKey('results')) {
        pendingInvoices.assignAll(
          (data['results'] as List)
              .map((e) => Map<String, dynamic>.from(e))
              .toList(),
        );
      }
    } on DioException catch (e) {
      log("Error fetching pending approvals: $e");
      errorMessage.value =
          e.response?.data?['detail'] ?? 'Failed to load pending approvals';
    } catch (e) {
      log("Error fetching pending approvals: $e");
      errorMessage.value = 'Failed to load pending approvals';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> approveInvoice(int invoiceId, int step,
      {String? comment}) async {
    try {
      final token = await _getToken();
      if (token == null) {
        Get.snackbar('Error', 'Authentication token not found');
        return;
      }

      await _dio.post(
        '/estate-invoices/$invoiceId/approvals/$step/decide',
        data: {
          'decision': 'approved',
          'comment': comment ?? '',
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      Get.snackbar('Success', 'Invoice approved successfully',
          snackPosition: SnackPosition.BOTTOM);
      await fetchPendingApprovals();
    } on DioException catch (e) {
      log("Error approving invoice: $e");
      final message =
          e.response?.data?['detail'] ?? 'Failed to approve invoice';
      Get.snackbar('Error', message, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      log("Error approving invoice: $e");
      Get.snackbar('Error', 'Failed to approve invoice',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> rejectInvoice(int invoiceId, int step,
      {required String reason}) async {
    try {
      final token = await _getToken();
      if (token == null) {
        Get.snackbar('Error', 'Authentication token not found');
        return;
      }

      await _dio.post(
        '/estate-invoices/$invoiceId/approvals/$step/decide',
        data: {
          'decision': 'rejected',
          'comment': reason,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      Get.snackbar('Success', 'Invoice rejected',
          snackPosition: SnackPosition.BOTTOM);
      await fetchPendingApprovals();
    } on DioException catch (e) {
      log("Error rejecting invoice: $e");
      final message = e.response?.data?['detail'] ?? 'Failed to reject invoice';
      Get.snackbar('Error', message, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      log("Error rejecting invoice: $e");
      Get.snackbar('Error', 'Failed to reject invoice',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
