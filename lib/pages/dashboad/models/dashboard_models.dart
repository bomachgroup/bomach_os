class Scorecard {
  final double overallScore;
  final double workReportsScore;
  final double punctualityScore;
  final String rankText;

  Scorecard({
    required this.overallScore,
    required this.workReportsScore,
    required this.punctualityScore,
    required this.rankText,
  });

  factory Scorecard.fromJson(Map<String, dynamic> json) {
    return Scorecard(
      overallScore:
          double.tryParse(json['overall_score']?.toString() ?? '0') ?? 0,
      workReportsScore:
          double.tryParse(json['work_reports_score']?.toString() ?? '0') ?? 0,
      punctualityScore:
          double.tryParse(json['punctuality_score']?.toString() ?? '0') ?? 0,
      rankText: json['rank_text']?.toString() ?? '',
    );
  }
}

class Ranking {
  final int rank;
  final int totalMembers;

  Ranking({required this.rank, required this.totalMembers});

  factory Ranking.fromJson(Map<String, dynamic> json) {
    return Ranking(
      rank: int.tryParse(json['rank']?.toString() ?? '0') ?? 0,
      totalMembers:
          int.tryParse(json['total_members']?.toString() ?? '0') ?? 0,
    );
  }
}

class DashboardSummary {
  final String fullName;
  final String jobTitle;
  final String departmentName;
  final Scorecard scorecard;
  final Ranking ranking;

  DashboardSummary({
    required this.fullName,
    required this.jobTitle,
    required this.departmentName,
    required this.scorecard,
    required this.ranking,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      fullName: json['full_name']?.toString() ?? '',
      jobTitle: json['job_title']?.toString() ?? '',
      departmentName: json['department_name']?.toString() ?? '',
      scorecard: Scorecard.fromJson(json['scorecard'] ?? {}),
      ranking: Ranking.fromJson(json['ranking'] ?? {}),
    );
  }
}

class WorkReportStats {
  final double score;
  final int reportsSubmitted;
  final int approved;
  final double averageRating;

  WorkReportStats({
    required this.score,
    required this.reportsSubmitted,
    required this.approved,
    required this.averageRating,
  });

  factory WorkReportStats.fromJson(Map<String, dynamic> json) {
    return WorkReportStats(
      score: double.tryParse(json['score']?.toString() ?? '0') ?? 0,
      reportsSubmitted:
          int.tryParse(json['reports_submitted']?.toString() ?? '0') ?? 0,
      approved: int.tryParse(json['approved']?.toString() ?? '0') ?? 0,
      averageRating:
          double.tryParse(json['average_rating']?.toString() ?? '0') ?? 0,
    );
  }
}

class PunctualityReport {
  final double score;
  final int totalDays;
  final int onTimeDays;
  final int lateDays;
  final int absentDays;

  PunctualityReport({
    required this.score,
    required this.totalDays,
    required this.onTimeDays,
    required this.lateDays,
    required this.absentDays,
  });

  factory PunctualityReport.fromJson(Map<String, dynamic> json) {
    return PunctualityReport(
      score: double.tryParse(json['score']?.toString() ?? '0') ?? 0,
      totalDays: int.tryParse(json['total_days']?.toString() ?? '0') ?? 0,
      onTimeDays: int.tryParse(json['on_time_days']?.toString() ?? '0') ?? 0,
      lateDays: int.tryParse(json['late_days']?.toString() ?? '0') ?? 0,
      absentDays: int.tryParse(json['absent_days']?.toString() ?? '0') ?? 0,
    );
  }
}

class PerformanceCard {
  final String fullName;
  final String jobTitle;
  final String departmentName;
  final double overallScore;
  final String rankText;
  final WorkReportStats workReport;
  final PunctualityReport punctualityReport;

  PerformanceCard({
    required this.fullName,
    required this.jobTitle,
    required this.departmentName,
    required this.overallScore,
    required this.rankText,
    required this.workReport,
    required this.punctualityReport,
  });

  factory PerformanceCard.fromJson(Map<String, dynamic> json) {
    return PerformanceCard(
      fullName: json['full_name']?.toString() ?? '',
      jobTitle: json['job_title']?.toString() ?? '',
      departmentName: json['department_name']?.toString() ?? '',
      overallScore:
          double.tryParse(json['overall_score']?.toString() ?? '0') ?? 0,
      rankText: json['rank_text']?.toString() ?? '',
      workReport: WorkReportStats.fromJson(json['work_report'] ?? {}),
      punctualityReport:
          PunctualityReport.fromJson(json['punctuality_report'] ?? {}),
    );
  }
}

class DepartmentHeadcount {
  final String department;
  final int count;

  DepartmentHeadcount({required this.department, required this.count});

  factory DepartmentHeadcount.fromJson(Map<String, dynamic> json) {
    return DepartmentHeadcount(
      department: json['department']?.toString() ?? '',
      count: int.tryParse(json['count']?.toString() ?? '0') ?? 0,
    );
  }
}

class DashboardOverview {
  final int totalEmployees;
  final int newHires30Days;
  final int newHiresToday;
  final int openRoles;
  final List<DepartmentHeadcount> headcountByDepartment;

  DashboardOverview({
    required this.totalEmployees,
    required this.newHires30Days,
    required this.newHiresToday,
    required this.openRoles,
    required this.headcountByDepartment,
  });

  factory DashboardOverview.fromJson(Map<String, dynamic> json) {
    return DashboardOverview(
      totalEmployees:
          int.tryParse(json['total_employees']?.toString() ?? '0') ?? 0,
      newHires30Days:
          int.tryParse(json['new_hires_30_days']?.toString() ?? '0') ?? 0,
      newHiresToday:
          int.tryParse(json['new_hires_today']?.toString() ?? '0') ?? 0,
      openRoles: int.tryParse(json['open_roles']?.toString() ?? '0') ?? 0,
      headcountByDepartment:
          (json['headcount_by_department'] as List<dynamic>?)
                  ?.map((e) =>
                      DepartmentHeadcount.fromJson(e as Map<String, dynamic>))
                  .toList() ??
              [],
    );
  }
}

class EmployeeDashboardStats {
  final int totalProjects;
  final double totalBudget;
  final double budgetUtilization;
  final int totalWorksites;
  final int totalContracts;
  final int totalTimelines;

  EmployeeDashboardStats({
    required this.totalProjects,
    required this.totalBudget,
    required this.budgetUtilization,
    required this.totalWorksites,
    required this.totalContracts,
    required this.totalTimelines,
  });

  factory EmployeeDashboardStats.fromJson(Map<String, dynamic> json) {
    return EmployeeDashboardStats(
      totalProjects:
          int.tryParse(json['total_projects']?.toString() ?? '0') ?? 0,
      totalBudget:
          double.tryParse(json['total_budget']?.toString() ?? '0') ?? 0,
      budgetUtilization:
          double.tryParse(json['budget_utilization']?.toString() ?? '0') ?? 0,
      totalWorksites:
          int.tryParse(json['total_worksites']?.toString() ?? '0') ?? 0,
      totalContracts:
          int.tryParse(json['total_contracts']?.toString() ?? '0') ?? 0,
      totalTimelines:
          int.tryParse(json['total_timelines']?.toString() ?? '0') ?? 0,
    );
  }
}
