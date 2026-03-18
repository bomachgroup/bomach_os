import 'dart:developer';
import 'package:dio/dio.dart';

import '../../../pages/finance/models/payment_model.dart';

class PaymentService {
  final Dio _dio;

  static const String _baseUrl = 'https://bomachauth.bgbot.app/api/v1';

  PaymentService({
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

  /// GET /api/v1/payments — List Payments
  Future<({List<Payment> items, int total})> getPayments(
    String token, {
    int? invoiceId,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/payments/',
        queryParameters: {
          if (invoiceId != null) 'invoice_id': invoiceId,
          'limit': limit,
          'offset': offset,
        },
        options: _authOptions(token),
      );

      final data = response.data;
      if (data is Map && data.containsKey('items')) {
        final items = (data['items'] as List)
            .map((json) => Payment.fromJson(json))
            .toList();
        final total = data['count'] ?? data['total'] ?? items.length;
        return (items: items, total: total as int);
      }

      // Fallback: data is a plain list
      final items =
          (data as List).map((json) => Payment.fromJson(json)).toList();
      return (items: items, total: items.length);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST /api/v1/payments — Create Payment
  Future<Payment> createPayment(
      String token, Map<String, dynamic> data) async {
    try {
      log("PaymentService: Creating payment...");
      final response = await _dio.post(
        '/payments/',
        data: data,
        options: _authOptions(token),
      );
      return Payment.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// GET /api/v1/payments/{id} — Get Payment
  Future<Payment> getPaymentById(String token, int paymentId) async {
    try {
      final response = await _dio.get(
        '/payments/$paymentId',
        options: _authOptions(token),
      );
      return Payment.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE /api/v1/payments/{id} — Delete Payment
  Future<void> deletePayment(String token, int paymentId) async {
    try {
      log("PaymentService: Deleting payment $paymentId...");
      await _dio.delete(
        '/payments/$paymentId',
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
