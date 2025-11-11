/// Monthly Scorecard data models for performance tracking
class MonthlyScorecardMetric {
  final String id;
  final String metricName;
  final double currentValue;
  final double targetValue;
  final String unit; // %, hours, count, etc.
  final List<double> historyData; // Last 12 months data
  final String category; // Attendance, Delivery, Accuracy, etc.
  final DateTime lastUpdated;
  final String trend; // UP, DOWN, STABLE

  MonthlyScorecardMetric({
    required this.id,
    required this.metricName,
    required this.currentValue,
    required this.targetValue,
    required this.unit,
    required this.historyData,
    required this.category,
    required this.lastUpdated,
    this.trend = 'STABLE',
  });

  /// Calculate achievement percentage
  double getAchievementPercentage() {
    if (targetValue == 0) return 0;
    return (currentValue / targetValue) * 100;
  }

  /// Check if target is met
  bool isTargetMet() {
    return currentValue >= targetValue;
  }

  /// Get metric status color
  String getStatusColor() {
    final achievement = getAchievementPercentage();
    if (achievement >= 100) return '#16A34A'; // Green
    if (achievement >= 75) return '#FBBF24'; // Amber
    return '#EC2623'; // Red
  }

  /// Copy with method
  MonthlyScorecardMetric copyWith({
    String? id,
    String? metricName,
    double? currentValue,
    double? targetValue,
    String? unit,
    List<double>? historyData,
    String? category,
    DateTime? lastUpdated,
    String? trend,
  }) {
    return MonthlyScorecardMetric(
      id: id ?? this.id,
      metricName: metricName ?? this.metricName,
      currentValue: currentValue ?? this.currentValue,
      targetValue: targetValue ?? this.targetValue,
      unit: unit ?? this.unit,
      historyData: historyData ?? this.historyData,
      category: category ?? this.category,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      trend: trend ?? this.trend,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'metricName': metricName,
      'currentValue': currentValue,
      'targetValue': targetValue,
      'unit': unit,
      'historyData': historyData,
      'category': category,
      'lastUpdated': lastUpdated.toIso8601String(),
      'trend': trend,
    };
  }
}

/// Monthly scorecard for an employee
class MonthlyScorecard {
  final String id;
  final String employeeId;
  final String employeeName;
  final String employeeEmail;
  final String employeeRole;
  final String department;
  final DateTime month;
  final double overallScore; // 0-100
  final String scoreGrade; // A, B, C, D, F
  final List<MonthlyScorecardMetric> metrics;
  final String? managerName;
  final String status; // Draft, Submitted, Approved
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final String? feedback;

  MonthlyScorecard({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.employeeEmail,
    required this.employeeRole,
    required this.department,
    required this.month,
    required this.overallScore,
    required this.scoreGrade,
    required this.metrics,
    this.managerName,
    required this.status,
    this.reviewedAt,
    this.reviewedBy,
    this.feedback,
  });

  /// Calculate metrics achievement summary
  int getMetricsOnTarget() {
    return metrics.where((m) => m.isTargetMet()).length;
  }

  /// Get overall score color
  String getScoreColor() {
    if (overallScore >= 85) return '#16A34A'; // Green
    if (overallScore >= 70) return '#FBBF24'; // Amber
    return '#EC2623'; // Red
  }

  /// Get achievement metrics grouped by category
  Map<String, List<MonthlyScorecardMetric>> getMetricsByCategory() {
    final map = <String, List<MonthlyScorecardMetric>>{};
    for (var metric in metrics) {
      if (!map.containsKey(metric.category)) {
        map[metric.category] = [];
      }
      map[metric.category]!.add(metric);
    }
    return map;
  }

  /// Copy with method
  MonthlyScorecard copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    String? employeeEmail,
    String? employeeRole,
    String? department,
    DateTime? month,
    double? overallScore,
    String? scoreGrade,
    List<MonthlyScorecardMetric>? metrics,
    String? managerName,
    String? status,
    DateTime? reviewedAt,
    String? reviewedBy,
    String? feedback,
  }) {
    return MonthlyScorecard(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      employeeEmail: employeeEmail ?? this.employeeEmail,
      employeeRole: employeeRole ?? this.employeeRole,
      department: department ?? this.department,
      month: month ?? this.month,
      overallScore: overallScore ?? this.overallScore,
      scoreGrade: scoreGrade ?? this.scoreGrade,
      metrics: metrics ?? this.metrics,
      managerName: managerName ?? this.managerName,
      status: status ?? this.status,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      feedback: feedback ?? this.feedback,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'employeeEmail': employeeEmail,
      'employeeRole': employeeRole,
      'department': department,
      'month': month.toIso8601String(),
      'overallScore': overallScore,
      'scoreGrade': scoreGrade,
      'metrics': metrics.map((m) => m.toJson()).toList(),
      'managerName': managerName,
      'status': status,
      'reviewedAt': reviewedAt?.toIso8601String(),
      'reviewedBy': reviewedBy,
      'feedback': feedback,
    };
  }
}

/// Scorecard status enum
enum ScorecardStatus {
  draft('Draft', '📝'),
  submitted('Submitted', '✅'),
  approved('Approved', '👍'),
  rejected('Rejected', '❌');

  final String displayName;
  final String emoji;

  const ScorecardStatus(this.displayName, this.emoji);

  String getColor() {
    switch (this) {
      case ScorecardStatus.draft:
        return '#64748B';
      case ScorecardStatus.submitted:
        return '#3B82F6';
      case ScorecardStatus.approved:
        return '#16A34A';
      case ScorecardStatus.rejected:
        return '#EC2623';
    }
  }
}

/// Score grade
enum ScoreGrade {
  a('A', 'Excellent', '#16A34A'),
  b('B', 'Good', '#3B82F6'),
  c('C', 'Satisfactory', '#FBBF24'),
  d('D', 'Needs Improvement', '#F97316'),
  f('F', 'Unsatisfactory', '#EC2623');

  final String grade;
  final String description;
  final String color;

  const ScoreGrade(this.grade, this.description, this.color);
}

/// Summary of scorecard performance
class ScorecardSummary {
  final int totalEmployees;
  final int completedScorecards;
  final double averageScore;
  final Map<String, int> gradeDistribution; // A: 5, B: 10, etc.
  final List<MonthlyScorecard> topPerformers;
  final List<MonthlyScorecard> needsImprovement;

  ScorecardSummary({
    required this.totalEmployees,
    required this.completedScorecards,
    required this.averageScore,
    required this.gradeDistribution,
    required this.topPerformers,
    required this.needsImprovement,
  });

  double getCompletionPercentage() {
    if (totalEmployees == 0) return 0;
    return (completedScorecards / totalEmployees) * 100;
  }
}
