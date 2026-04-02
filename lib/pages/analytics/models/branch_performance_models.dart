/// Branch Performance Analytics Models
library branch_performance_models;

class BranchPerformanceMetric {
  final String branchId;
  final String branchName;
  final String location;
  final double revenueGenerated;
  final double revenueTarget;
  final int employeeCount;
  final double employeeProductivity;
  final int projectsCompleted;
  final int activeProjects;
  final double customerSatisfaction;
  final int customerCount;
  final double operationalEfficiency;
  final double costPerProjection;
  final int trainingSessionsCompleted;
  final double employeeRetentionRate;
  final DateTime lastReportDate;

  BranchPerformanceMetric({
    required this.branchId,
    required this.branchName,
    required this.location,
    required this.revenueGenerated,
    required this.revenueTarget,
    required this.employeeCount,
    required this.employeeProductivity,
    required this.projectsCompleted,
    required this.activeProjects,
    required this.customerSatisfaction,
    required this.customerCount,
    required this.operationalEfficiency,
    required this.costPerProjection,
    required this.trainingSessionsCompleted,
    required this.employeeRetentionRate,
    required this.lastReportDate,
  });

  double getRevenueAchievementPercentage() {
    if (revenueTarget == 0) return 0;
    return (revenueGenerated / revenueTarget) * 100;
  }

  String getPerformanceRating() {
    final avgMetrics = (getRevenueAchievementPercentage() +
            customerSatisfaction +
            operationalEfficiency) /
        3;
    if (avgMetrics >= 90) return 'Excellent';
    if (avgMetrics >= 75) return 'Good';
    if (avgMetrics >= 60) return 'Satisfactory';
    return 'Needs Improvement';
  }

  String getPerformanceColor() {
    final rating = getPerformanceRating();
    switch (rating) {
      case 'Excellent':
        return '#16A34A'; // Green
      case 'Good':
        return '#0891B2'; // Cyan
      case 'Satisfactory':
        return '#FBBF24'; // Amber
      default:
        return '#EF4444'; // Red
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'branchId': branchId,
      'branchName': branchName,
      'location': location,
      'revenueGenerated': revenueGenerated,
      'revenueTarget': revenueTarget,
      'employeeCount': employeeCount,
      'employeeProductivity': employeeProductivity,
      'projectsCompleted': projectsCompleted,
      'activeProjects': activeProjects,
      'customerSatisfaction': customerSatisfaction,
      'customerCount': customerCount,
      'operationalEfficiency': operationalEfficiency,
      'costPerProjection': costPerProjection,
      'trainingSessionsCompleted': trainingSessionsCompleted,
      'employeeRetentionRate': employeeRetentionRate,
      'lastReportDate': lastReportDate.toIso8601String(),
    };
  }
}

/// Monthly revenue trend data
class BranchRevenueTrend {
  final String month;
  final double revenue;
  final double target;

  BranchRevenueTrend({
    required this.month,
    required this.revenue,
    required this.target,
  });
}

/// Branch comparison data
class BranchComparison {
  final String branchName;
  final double revenue;
  final double efficiency;
  final double satisfaction;
  final int projects;

  BranchComparison({
    required this.branchName,
    required this.revenue,
    required this.efficiency,
    required this.satisfaction,
    required this.projects,
  });
}

/// Department performance within a branch
class DepartmentPerformance {
  final String departmentName;
  final int headCount;
  final double productivity;
  final double satisfaction;
  final int projects;
  final double budget;

  DepartmentPerformance({
    required this.departmentName,
    required this.headCount,
    required this.productivity,
    required this.satisfaction,
    required this.projects,
    required this.budget,
  });
}

/// Top performer in a branch
class BranchTopPerformer {
  final String employeeId;
  final String employeeName;
  final String position;
  final String department;
  final double performanceScore;
  final int projectsCompleted;
  final String achievementHighlight;

  BranchTopPerformer({
    required this.employeeId,
    required this.employeeName,
    required this.position,
    required this.department,
    required this.performanceScore,
    required this.projectsCompleted,
    required this.achievementHighlight,
  });
}

/// Branch performance summary
class BranchPerformanceSummary {
  final int totalBranches;
  final int topPerformingBranchRank;
  final String topPerformingBranch;
  final List<BranchPerformanceMetric> allBranches;
  final double averageRevenuePerBranch;
  final double averageEmployeeProductivity;
  final double averageCustomerSatisfaction;
  final int totalProjects;
  final int totalEmployees;

  BranchPerformanceSummary({
    required this.totalBranches,
    required this.topPerformingBranchRank,
    required this.topPerformingBranch,
    required this.allBranches,
    required this.averageRevenuePerBranch,
    required this.averageEmployeeProductivity,
    required this.averageCustomerSatisfaction,
    required this.totalProjects,
    required this.totalEmployees,
  });

  double getNetworkEfficiency() {
    return (averageRevenuePerBranch +
            (averageEmployeeProductivity * 100) +
            averageCustomerSatisfaction) /
        3;
  }
}

/// Key insights enum
enum BranchInsightType {
  revenue,
  efficiency,
  growth,
  performance,
  risk,
}

class BranchInsight {
  final BranchInsightType type;
  final String title;
  final String description;
  final String recommendation;
  final String priority; // High, Medium, Low
  final String icon;

  BranchInsight({
    required this.type,
    required this.title,
    required this.description,
    required this.recommendation,
    required this.priority,
    required this.icon,
  });
}
