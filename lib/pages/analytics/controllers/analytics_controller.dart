import 'dart:developer';
import 'package:dio/dio.dart' hide Response;
import 'package:dio/dio.dart' as dio_pkg show Response;
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AnalyticsController extends GetxController {
  final _storage = const FlutterSecureStorage();
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://bomachauth.bgbot.app/api/v1',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  var isLoading = true.obs;

  // HR Dashboard
  var totalEmployees = 0.obs;
  var newHires30Days = 0.obs;
  var openRoles = 0.obs;
  var headcountByDept = <Map<String, dynamic>>[].obs;

  // Operations Stats
  var totalProjects = 0.obs;
  var totalBudget = '0.00'.obs;
  var budgetUtilization = '0.00'.obs;
  var totalWorksites = 0.obs;
  var totalContracts = 0.obs;
  var totalTimelines = 0.obs;

  // HR Stats
  var trainingPrograms = 0.obs;
  var jobPostings = 0.obs;
  var leaves = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchAll() async {
    try {
      isLoading.value = true;
      final token = await _getToken();
      if (token == null) return;

      final opts = Options(headers: {'Authorization': 'Bearer $token'});

      // Fetch all in parallel
      final results = await Future.wait([
        _dio.get('/dashboard/overview', options: opts).catchError((_) => dio_pkg.Response(
            requestOptions: RequestOptions(path: ''),
            data: {},
            statusCode: 200)),
        _dio.get('/dashboard/stats', options: opts).catchError((_) => dio_pkg.Response(
            requestOptions: RequestOptions(path: ''),
            data: {},
            statusCode: 200)),
      ]);

      // HR Overview
      final overview = results[0].data;
      if (overview is Map) {
        totalEmployees.value = overview['total_employees'] ?? 0;
        newHires30Days.value = overview['new_hires_30_days'] ?? 0;
        openRoles.value = overview['open_roles'] ?? 0;
        if (overview['headcount_by_department'] is List) {
          headcountByDept.assignAll(
              List<Map<String, dynamic>>.from(overview['headcount_by_department']));
        }
      }

      // Stats
      final stats = results[1].data;
      if (stats is Map) {
        trainingPrograms.value = stats['training_programs'] ?? 0;
        jobPostings.value = stats['job_postings'] ?? 0;
        leaves.value = stats['leaves'] ?? 0;
      }
    } catch (e) {
      log("Error fetching analytics: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> _getToken() async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith("Bearer ")) {
      token = token.replaceFirst("Bearer ", "");
    }
    return token.replaceAll('"', '').trim();
  }
}
