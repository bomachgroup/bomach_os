import 'dart:developer';
import 'package:bms_front_end/src/constants/api_constants.dart';
import 'package:dio/dio.dart';

import '../../../pages/finance/models/service_invoice_model_api.dart';

class ServiceInvoiceService {
  final Dio _dio;

  static const String _baseUrl = '${ApiConstants.baseUrl}/api/v1';

  ServiceInvoiceService({
    Dio? dioOverride,
  }) : _dio = dioOverride ??
            Dio(BaseOptions(
              baseUrl: _baseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            )) {
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      responseBody: true,
      responseHeader: false,
    ));
  }

  Options _authOptions(String token) {
    return Options(headers: {
      'Authorization': 'Bearer $token',
    });
  }

  /// GET /api/v1/invoices — List Service Invoices
  Future<({List<ServiceInvoice> items, int total})> getInvoices(
    String token, {
    String? status,
    int? clientId,
    String? search,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/invoices/',
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          if (status != null && status != 'All') 'status': status,
          if (clientId != null) 'client_id': clientId,
          'limit': limit,
          'offset': offset,
        },
        options: _authOptions(token),
      );

      final data = response.data;
      if (data is Map && data.containsKey('items')) {
        final items = (data['items'] as List)
            .map((json) => ServiceInvoice.fromJson(json))
            .toList();
        final total = data['count'] ?? data['total'] ?? items.length;
        return (items: items, total: total as int);
      }

      // Fallback: data is a plain list
      final items =
          (data as List).map((json) => ServiceInvoice.fromJson(json)).toList();
      return (items: items, total: items.length);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST /api/v1/invoices — Create Service Invoice
  Future<ServiceInvoice> createInvoice(
      String token, Map<String, dynamic> data) async {
    try {
      log("ServiceInvoiceService: Creating invoice...");
      final response = await _dio.post(
        '/invoices/',
        data: data,
        options: _authOptions(token),
      );
      return ServiceInvoice.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// GET /api/v1/invoices/{id} — Get Service Invoice
  Future<ServiceInvoice> getInvoiceById(String token, int invoiceId) async {
    try {
      final response = await _dio.get(
        '/invoices/$invoiceId',
        options: _authOptions(token),
      );
      return ServiceInvoice.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT /api/v1/invoices/{id} — Update Service Invoice
  Future<ServiceInvoice> updateInvoice(
      String token, int invoiceId, Map<String, dynamic> data) async {
    try {
      log("ServiceInvoiceService: Updating invoice $invoiceId...");
      final response = await _dio.put(
        '/invoices/$invoiceId',
        data: data,
        options: _authOptions(token),
      );
      return ServiceInvoice.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE /api/v1/invoices/{id} — Delete Service Invoice
  Future<void> deleteInvoice(String token, int invoiceId) async {
    try {
      log("ServiceInvoiceService: Deleting invoice $invoiceId...");
      await _dio.delete(
        '/invoices/$invoiceId',
        options: _authOptions(token),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    String msg = "An unexpected error occurred";

    if (error is DioException) {
      if (error.response != null) {
        final data = error.response?.data;
        log("SERVER ERROR: $data");

        if (data is Map<String, dynamic>) {
          if (data['errors'] != null) {
            return Exception("Validation: ${data['errors']}");
          }
          if (data.containsKey('detail')) {
            msg = data['detail'];
          } else if (data.containsKey('message')) {
            msg = data['message'];
          }
        }
      } else {
        msg = "Connection error. Please check your internet.";
      }
    }
    return Exception(msg);
  }
}
