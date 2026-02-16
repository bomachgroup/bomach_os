import 'package:dio/dio.dart';
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

  static const String _baseUrl = 'https://bomachhr.bgbot.app/api/v1';

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

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => debugPrint('HR_API: $obj'),
    ));
  }

  Dio get client => _dio;
}
