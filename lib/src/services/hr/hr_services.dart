import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'applicants_service.dart';
import 'asset_services.dart';
import 'awards_service.dart';
import 'disciplinary_cases_services.dart';
import 'employee_evaluation_service.dart';
import 'jobposting_service.dart';
import 'leave_request_services.dart';
import 'monthly_scorecard_service.dart';
import 'payroll_service.dart';
import 'performance_review.dart';
import 'training_program_services.dart';
import 'work_report_service.dart';

class HRServices {
  final Dio _dio;

  late final JobPostingService jobs;
  late final ApplicantService applicants;
  late final LeaveRequestService leaves;
  late final PerformanceReviewService reviews;
  late final PayrollService payroll;
  late final TrainingProgramService training;
  late final AssetService assets;
  late final AwardService awards;
  late final WorkReportService reports;
  late final DisciplinaryCaseService disciplinary;
  late final MonthlyScorecardService scorecards;
  late final EmployeeEvaluationService evaluations;

  static final String _baseUrl = '${ApiConstants.baseUrl}/api/v1';

  HRServices({Dio? dioOverride})
      : _dio = dioOverride ??
            Dio(BaseOptions(
              baseUrl: _baseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            )) {
    jobs = JobPostingService(dioOverride: _dio);
    applicants = ApplicantService(dioOverride: _dio);
    leaves = LeaveRequestService(dioOverride: _dio);
    reviews = PerformanceReviewService(dioOverride: _dio);
    payroll = PayrollService(dioOverride: _dio);
    training = TrainingProgramService(dioOverride: _dio);
    assets = AssetService(dioOverride: _dio);
    awards = AwardService(dioOverride: _dio);
    reports = WorkReportService(dioOverride: _dio);
    disciplinary = DisciplinaryCaseService(dioOverride: _dio);
    scorecards = MonthlyScorecardService(dioOverride: _dio);
    evaluations = EmployeeEvaluationService(dioOverride: _dio);

    // Audit V6: the custom logPrint wrapper bypasses Dio's assert-gated
    // default printer, so this interceptor printed Authorization headers
    // and response bodies even in release builds. Debug-only now.
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint('HR_API: $obj'),
      ));
    }
  }

  Options _authOptions(String token) {
    return Options(headers: {
      'Authorization': 'Bearer $token',
    });
  }

  Future<DashboardStatsModel> getDashboardStats(String token) async {
    try {
      final response = await _dio.get(
        '/api/v1/dashboard/stats',
        options: _authOptions(token),
      );

      if (response.statusCode == 200) {
        return DashboardStatsModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load stats: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      // Handle Dio specific errors (timeouts, 400s, 500s)
      throw Exception('Network Error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching dashboard stats: $e');
    }
  }

  Dio get client => _dio;
}

class DashboardStatsModel {
  final int totalEmployees;
  final int newEmployeesCount;
  final int trainingPrograms;
  final int jobPostings;
  final int leaves;
  final int disciplinaryProcess;

  DashboardStatsModel({
    required this.totalEmployees,
    required this.newEmployeesCount,
    required this.trainingPrograms,
    required this.jobPostings,
    required this.leaves,
    required this.disciplinaryProcess,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalEmployees: json['total_employees'] ?? 0,
      newEmployeesCount: json['new_employees_count'] ?? 0,
      trainingPrograms: json['training_programs'] ?? 0,
      jobPostings: json['job_postings'] ?? 0,
      leaves: json['leaves'] ?? 0,
      disciplinaryProcess: json['disciplinary_process'] ?? 0,
    );
  }
}
