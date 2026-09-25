import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../../../src/services/dashboard_service.dart';
import '../models/dashboard_models.dart';

class DashboardController extends GetxController {
  final DashboardService _service = DashboardService();
  final _storage = const FlutterSecureStorage();

  var isLoading = true.obs;
  var errorMessage = ''.obs;

  Rxn<DashboardSummary> summary = Rxn<DashboardSummary>();
  Rxn<PerformanceCard> performanceCard = Rxn<PerformanceCard>();
  Rxn<DashboardOverview> overview = Rxn<DashboardOverview>();
  Rxn<EmployeeDashboardStats> stats = Rxn<EmployeeDashboardStats>();

  Future<String?> _getToken() async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith("Bearer ")) {
      token = token.replaceFirst("Bearer ", "");
    }
    return token.replaceAll('"', '').trim();
  }

  Future<void> fetchAll() async {
    try {
      isLoading(true);
      errorMessage('');

      final token = await _getToken();
      if (token == null) {
        errorMessage('Authentication token not found');
        return;
      }

      final results = await Future.wait<Object?>([
        _load(_service.getSummary(token)),
        _load(_service.getPerformanceCard(token)),
        _load(_service.getOverview(token)),
        _load(_service.getStats(token)),
      ]);

      if (results[0] is DashboardSummary) {
        summary.value = results[0] as DashboardSummary;
      }
      if (results[1] is PerformanceCard) {
        performanceCard.value = results[1] as PerformanceCard;
      }
      if (results[2] is DashboardOverview) {
        overview.value = results[2] as DashboardOverview;
      }
      if (results[3] is EmployeeDashboardStats) {
        stats.value = results[3] as EmployeeDashboardStats;
      }

      final failures = results.whereType<Object>().where((result) =>
          result is! DashboardSummary &&
          result is! PerformanceCard &&
          result is! DashboardOverview &&
          result is! EmployeeDashboardStats);
      if (failures.isNotEmpty) {
        errorMessage('Some dashboard data could not be refreshed.');
      }
    } catch (e) {
      errorMessage('Failed to load dashboard: $e');
      debugPrint("Dashboard fetch error: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<Object?> _load<T>(Future<T> request) async {
    try {
      return await request;
    } catch (error) {
      return error;
    }
  }
}
