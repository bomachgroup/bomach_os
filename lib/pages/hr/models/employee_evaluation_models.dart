/// Employee Evaluation data models
class CompetencyRating {
  final String competencyName;
  final int rating; // 1-5 scale
  final String? comment;

  CompetencyRating({
    required this.competencyName,
    required this.rating,
    this.comment,
  });

  /// Get rating color
  String getRatingColor() {
    switch (rating) {
      case 5:
        return '#16A34A'; // Green - Excellent
      case 4:
        return '#3B82F6'; // Blue - Good
      case 3:
        return '#FBBF24'; // Amber - Satisfactory
      case 2:
        return '#F97316'; // Orange - Needs Improvement
      case 1:
        return '#EC2623'; // Red - Poor
      default:
        return '#95A5A6'; // Gray - Not Rated
    }
  }

  /// Get rating label
  String getRatingLabel() {
    switch (rating) {
      case 5:
        return 'Excellent';
      case 4:
        return 'Good';
      case 3:
        return 'Satisfactory';
      case 2:
        return 'Needs Improvement';
      case 1:
        return 'Poor';
      default:
        return 'Not Rated';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'competencyName': competencyName,
      'rating': rating,
      'comment': comment,
    };
  }
}

/// KPI Review
class KPIReview {
  final String kpiName;
  final double? achievedValue;
  final double targetValue;
  final String unit;
  final String status; // On Target, Below Target, Exceeded

  KPIReview({
    required this.kpiName,
    this.achievedValue,
    required this.targetValue,
    required this.unit,
    required this.status,
  });

  /// Get achievement percentage
  double getAchievementPercentage() {
    if (achievedValue == null) return 0;
    return (achievedValue! / targetValue) * 100;
  }

  /// Get status color
  String getStatusColor() {
    switch (status) {
      case 'Exceeded':
        return '#16A34A'; // Green
      case 'On Target':
        return '#3B82F6'; // Blue
      case 'Below Target':
        return '#EC2623'; // Red
      default:
        return '#95A5A6'; // Gray
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'kpiName': kpiName,
      'achievedValue': achievedValue,
      'targetValue': targetValue,
      'unit': unit,
      'status': status,
    };
  }
}

/// Recommendation & Decision
class RecommendationDecision {
  final bool promotionRecommended;
  final bool trainingRequired;
  final bool increaseRequired;
  final String? comments;

  RecommendationDecision({
    required this.promotionRecommended,
    required this.trainingRequired,
    required this.increaseRequired,
    this.comments,
  });

  Map<String, dynamic> toJson() {
    return {
      'promotionRecommended': promotionRecommended,
      'trainingRequired': trainingRequired,
      'increaseRequired': increaseRequired,
      'comments': comments,
    };
  }
}

/// Employee Evaluation Form
class EmployeeEvaluationForm {
  final String evaluationId;
  final String employeeId;
  final String employeeName;
  final String employeeEmail;
  final String department;
  final String role;
  final String branch;
  final String evaluationPeriod; // Q1 2025, Q2 2025, etc.
  final DateTime evaluationDate;
  final String? evaluatorName;
  final double averageScore; // Overall average of competencies
  final int totalScore; // Sum of all ratings
  final List<CompetencyRating> coreCompetencies;
  final List<KPIReview> kpiReviews;
  final String? managerComments;
  final RecommendationDecision recommendation;
  final String status; // Draft, Submitted, Approved

  EmployeeEvaluationForm({
    required this.evaluationId,
    required this.employeeId,
    required this.employeeName,
    required this.employeeEmail,
    required this.department,
    required this.role,
    required this.branch,
    required this.evaluationPeriod,
    required this.evaluationDate,
    this.evaluatorName,
    required this.averageScore,
    required this.totalScore,
    required this.coreCompetencies,
    required this.kpiReviews,
    this.managerComments,
    required this.recommendation,
    required this.status,
  });

  /// Get overall performance rating
  String getPerformanceRating() {
    if (averageScore >= 4.5) return 'Excellent';
    if (averageScore >= 3.5) return 'Good';
    if (averageScore >= 2.5) return 'Satisfactory';
    if (averageScore >= 1.5) return 'Needs Improvement';
    return 'Poor';
  }

  /// Get performance color
  String getPerformanceColor() {
    if (averageScore >= 4.5) return '#16A34A'; // Green
    if (averageScore >= 3.5) return '#3B82F6'; // Blue
    if (averageScore >= 2.5) return '#FBBF24'; // Amber
    if (averageScore >= 1.5) return '#F97316'; // Orange
    return '#EC2623'; // Red
  }

  /// Calculate KPI achievement rate
  double getKPIAchievementRate() {
    if (kpiReviews.isEmpty) return 0;
    final onTargetCount = kpiReviews
        .where((kpi) =>
            kpi.status == 'On Target' || kpi.status == 'Exceeded')
        .length;
    return (onTargetCount / kpiReviews.length) * 100;
  }

  Map<String, dynamic> toJson() {
    return {
      'evaluationId': evaluationId,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'employeeEmail': employeeEmail,
      'department': department,
      'role': role,
      'branch': branch,
      'evaluationPeriod': evaluationPeriod,
      'evaluationDate': evaluationDate.toIso8601String(),
      'evaluatorName': evaluatorName,
      'averageScore': averageScore,
      'totalScore': totalScore,
      'coreCompetencies':
          coreCompetencies.map((c) => c.toJson()).toList(),
      'kpiReviews': kpiReviews.map((k) => k.toJson()).toList(),
      'managerComments': managerComments,
      'recommendation': recommendation.toJson(),
      'status': status,
    };
  }
}

/// Evaluation summary
class EvaluationSummary {
  final int totalEvaluations;
  final int completedEvaluations;
  final int pendingEvaluations;
  final double averagePerformanceScore;
  final Map<String, int> performanceDistribution; // Excellent: 10, Good: 20, etc.

  EvaluationSummary({
    required this.totalEvaluations,
    required this.completedEvaluations,
    required this.pendingEvaluations,
    required this.averagePerformanceScore,
    required this.performanceDistribution,
  });

  double getCompletionRate() {
    if (totalEvaluations == 0) return 0;
    return (completedEvaluations / totalEvaluations) * 100;
  }
}
