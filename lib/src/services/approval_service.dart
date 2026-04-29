import 'dart:developer';
import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:dio/dio.dart';

import '../model/approval_model.dart';

class ApprovalService {
  final Dio _dio;
  static final baseUrl = ApiConstants.baseUrl;

  ApprovalService({
    Dio? dioOverride,
  }) : _dio = dioOverride ??
            Dio(BaseOptions(
              baseUrl: baseUrl,
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

  // ─── FLOW CHOICES ──────────────────────────────────────────────────

  /// GET /api/v1/approvals/flows/choices
  Future<ApprovalFlowChoices> getFlowChoices({
    required String accessToken,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/approvals/flows/choices',
        options: _authOptions(accessToken),
      );
      return ApprovalFlowChoices.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── APPROVAL FLOWS CRUD ───────────────────────────────────────────

  /// GET /api/v1/approvals/flows — List Approval Flows
  Future<({List<ApprovalFlow> items, int total})> getFlows({
    required String accessToken,
    String? search,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'limit': limit,
        'offset': offset,
      };
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _dio.get(
        '/api/v1/approvals/flows',
        queryParameters: queryParams,
        options: _authOptions(accessToken),
      );

      final data = response.data;
      if (data != null && data['items'] is List) {
        final items = (data['items'] as List)
            .map((item) => ApprovalFlow.fromJson(item))
            .toList();
        final total = data['count'] ?? data['total'] ?? items.length;
        return (items: items, total: total as int);
      }
      return (items: <ApprovalFlow>[], total: 0);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST /api/v1/approvals/flows — Create Approval Flow
  Future<ApprovalFlow> createFlow({
    required String accessToken,
    required Map<String, dynamic> data,
  }) async {
    try {
      log("ApprovalService: Creating flow...");
      final response = await _dio.post(
        '/api/v1/approvals/flows',
        data: data,
        options: _authOptions(accessToken),
      );
      return ApprovalFlow.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// GET /api/v1/approvals/flows/{flow_id} — Get Approval Flow
  Future<ApprovalFlow> getFlow({
    required String accessToken,
    required int flowId,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/approvals/flows/$flowId',
        options: _authOptions(accessToken),
      );
      return ApprovalFlow.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT /api/v1/approvals/flows/{flow_id} — Update Approval Flow
  Future<ApprovalFlow> updateFlow({
    required String accessToken,
    required int flowId,
    required Map<String, dynamic> data,
  }) async {
    try {
      log("ApprovalService: Updating flow $flowId...");
      final response = await _dio.put(
        '/api/v1/approvals/flows/$flowId',
        data: data,
        options: _authOptions(accessToken),
      );
      return ApprovalFlow.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE /api/v1/approvals/flows/{flow_id} — Deactivate Approval Flow
  Future<void> deleteFlow({
    required String accessToken,
    required int flowId,
  }) async {
    try {
      log("ApprovalService: Deactivating flow $flowId...");
      await _dio.delete(
        '/api/v1/approvals/flows/$flowId',
        options: _authOptions(accessToken),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── APPROVAL REQUESTS ─────────────────────────────────────────────

  /// GET /api/v1/approvals/requests — List Approval Requests
  Future<({List<ApprovalRequest> items, int total})> getRequests({
    required String accessToken,
    String? search,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'limit': limit,
        'offset': offset,
      };
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _dio.get(
        '/api/v1/approvals/requests',
        queryParameters: queryParams,
        options: _authOptions(accessToken),
      );

      final data = response.data;
      if (data != null && data['items'] is List) {
        final items = (data['items'] as List)
            .map((item) => ApprovalRequest.fromJson(item))
            .toList();
        final total = data['count'] ?? data['total'] ?? items.length;
        return (items: items, total: total as int);
      }
      return (items: <ApprovalRequest>[], total: 0);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST /api/v1/approvals/requests — Create Approval Request
  Future<ApprovalRequest> createRequest({
    required String accessToken,
    required Map<String, dynamic> data,
  }) async {
    try {
      log("ApprovalService: Creating request...");
      final response = await _dio.post(
        '/api/v1/approvals/requests',
        data: data,
        options: _authOptions(accessToken),
      );
      return ApprovalRequest.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// GET /api/v1/approvals/requests/{request_id} — Get Approval Request
  Future<ApprovalRequest> getRequest({
    required String accessToken,
    required int requestId,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/approvals/requests/$requestId',
        options: _authOptions(accessToken),
      );
      return ApprovalRequest.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE /api/v1/approvals/requests/{request_id} — Cancel Approval Request
  Future<void> cancelRequest({
    required String accessToken,
    required int requestId,
  }) async {
    try {
      log("ApprovalService: Cancelling request $requestId...");
      await _dio.delete(
        '/api/v1/approvals/requests/$requestId',
        options: _authOptions(accessToken),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST /api/v1/approvals/requests/{request_id}/approve
  Future<void> approveRequest({
    required String accessToken,
    required int requestId,
    Map<String, dynamic>? data,
  }) async {
    try {
      log("ApprovalService: Approving request $requestId...");
      await _dio.post(
        '/api/v1/approvals/requests/$requestId/approve',
        data: data ?? {},
        options: _authOptions(accessToken),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST /api/v1/approvals/requests/{request_id}/reject
  Future<void> rejectRequest({
    required String accessToken,
    required int requestId,
    Map<String, dynamic>? data,
  }) async {
    try {
      log("ApprovalService: Rejecting request $requestId...");
      await _dio.post(
        '/api/v1/approvals/requests/$requestId/reject',
        data: data ?? {},
        options: _authOptions(accessToken),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── ERROR HANDLER ─────────────────────────────────────────────────

  Exception _handleError(DioException e) {
    String msg = "An unexpected error occurred";

    if (e.response != null) {
      final data = e.response?.data;
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
    return Exception(msg);
  }
}
