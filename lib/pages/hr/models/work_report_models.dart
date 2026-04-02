/// Daily Work Report data model
class DailyWorkReport {
  final String id;
  final String employeeId;
  final String employeeName;
  final String employeeEmail;
  final DateTime reportDate;
  final List<WorkActivity> activities;
  final double hoursWorked;
  final String mood; // Happy, Neutral, Tired
  final String challenges;
  final String achievements;
  final String nextDayPlan;
  final bool submitted;
  final DateTime? submittedAt;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String status; // Draft, Submitted, Approved, Rejected

  DailyWorkReport({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.employeeEmail,
    required this.reportDate,
    required this.activities,
    required this.hoursWorked,
    required this.mood,
    required this.challenges,
    required this.achievements,
    required this.nextDayPlan,
    this.submitted = false,
    this.submittedAt,
    this.approvedBy,
    this.approvedAt,
    this.status = 'Draft',
  });

  /// Calculate total hours from activities
  double getTotalHours() {
    return activities.fold(0.0, (sum, activity) => sum + activity.hoursSpent);
  }

  /// Check if report is complete (all required fields filled)
  bool isComplete() {
    return activities.isNotEmpty &&
        challenges.isNotEmpty &&
        achievements.isNotEmpty &&
        nextDayPlan.isNotEmpty;
  }

  /// Copy with method for immutability
  DailyWorkReport copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    String? employeeEmail,
    DateTime? reportDate,
    List<WorkActivity>? activities,
    double? hoursWorked,
    String? mood,
    String? challenges,
    String? achievements,
    String? nextDayPlan,
    bool? submitted,
    DateTime? submittedAt,
    String? approvedBy,
    DateTime? approvedAt,
    String? status,
  }) {
    return DailyWorkReport(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      employeeEmail: employeeEmail ?? this.employeeEmail,
      reportDate: reportDate ?? this.reportDate,
      activities: activities ?? this.activities,
      hoursWorked: hoursWorked ?? this.hoursWorked,
      mood: mood ?? this.mood,
      challenges: challenges ?? this.challenges,
      achievements: achievements ?? this.achievements,
      nextDayPlan: nextDayPlan ?? this.nextDayPlan,
      submitted: submitted ?? this.submitted,
      submittedAt: submittedAt ?? this.submittedAt,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      status: status ?? this.status,
    );
  }

  /// Convert to JSON for API calls
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'employeeEmail': employeeEmail,
      'reportDate': reportDate.toIso8601String(),
      'activities': activities.map((a) => a.toJson()).toList(),
      'hoursWorked': hoursWorked,
      'mood': mood,
      'challenges': challenges,
      'achievements': achievements,
      'nextDayPlan': nextDayPlan,
      'submitted': submitted,
      'submittedAt': submittedAt?.toIso8601String(),
      'approvedBy': approvedBy,
      'approvedAt': approvedAt?.toIso8601String(),
      'status': status,
    };
  }
}

/// Individual work activity/task
class WorkActivity {
  final String id;
  final String taskTitle;
  final String description;
  final String
      taskCategory; // Development, Testing, Bug Fix, Documentation, Meeting, etc.
  final double hoursSpent;
  final bool completed;
  final List<String> tags; // Optional tags for categorization

  WorkActivity({
    required this.id,
    required this.taskTitle,
    required this.description,
    required this.taskCategory,
    required this.hoursSpent,
    required this.completed,
    this.tags = const [],
  });

  /// Copy with method
  WorkActivity copyWith({
    String? id,
    String? taskTitle,
    String? description,
    String? taskCategory,
    double? hoursSpent,
    bool? completed,
    List<String>? tags,
  }) {
    return WorkActivity(
      id: id ?? this.id,
      taskTitle: taskTitle ?? this.taskTitle,
      description: description ?? this.description,
      taskCategory: taskCategory ?? this.taskCategory,
      hoursSpent: hoursSpent ?? this.hoursSpent,
      completed: completed ?? this.completed,
      tags: tags ?? this.tags,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskTitle': taskTitle,
      'description': description,
      'taskCategory': taskCategory,
      'hoursSpent': hoursSpent,
      'completed': completed,
      'tags': tags,
    };
  }
}

/// Work Report Summary for dashboard
class WorkReportSummary {
  final int totalReports;
  final int submittedReports;
  final int approvedReports;
  final int pendingReports;
  final double averageHoursPerDay;
  final double totalHoursWorked;
  final List<String> commonCategories;
  final String mostProductiveDay;

  WorkReportSummary({
    required this.totalReports,
    required this.submittedReports,
    required this.approvedReports,
    required this.pendingReports,
    required this.averageHoursPerDay,
    required this.totalHoursWorked,
    required this.commonCategories,
    required this.mostProductiveDay,
  });

  /// Calculate completion percentage
  double getCompletionPercentage() {
    if (totalReports == 0) return 0;
    return (submittedReports / totalReports) * 100;
  }

  /// Calculate approval percentage
  double getApprovalPercentage() {
    if (submittedReports == 0) return 0;
    return (approvedReports / submittedReports) * 100;
  }
}

/// Task categories for work activities
enum WorkTaskCategory {
  development('Development', '💻'),
  testing('Testing', '🧪'),
  bugFix('Bug Fix', '🐛'),
  documentation('Documentation', '📝'),
  meeting('Meeting', '👥'),
  research('Research', '🔍'),
  codeReview('Code Review', '👀'),
  deployment('Deployment', '🚀'),
  other('Other', '📌');

  final String displayName;
  final String emoji;

  const WorkTaskCategory(this.displayName, this.emoji);

  /// Get color for category
  String getColor() {
    switch (this) {
      case WorkTaskCategory.development:
        return '#0055FF'; // Blue
      case WorkTaskCategory.testing:
        return '#9B59B6'; // Purple
      case WorkTaskCategory.bugFix:
        return '#EC2623'; // Red
      case WorkTaskCategory.documentation:
        return '#F39C12'; // Orange
      case WorkTaskCategory.meeting:
        return '#16A34A'; // Green
      case WorkTaskCategory.research:
        return '#3B82F6'; // Light Blue
      case WorkTaskCategory.codeReview:
        return '#8B5CF6'; // Violet
      case WorkTaskCategory.deployment:
        return '#D97706'; // Amber
      case WorkTaskCategory.other:
        return '#6B7280'; // Gray
    }
  }
}

/// Mood emoji and display
enum EmployeeMood {
  happy('Happy', '😊'),
  neutral('Neutral', '😐'),
  tired('Tired', '😴'),
  frustrated('Frustrated', '😞');

  final String displayName;
  final String emoji;

  const EmployeeMood(this.displayName, this.emoji);
}

/// Work Report Status
enum WorkReportStatus {
  draft('Draft', '📝'),
  submitted('Submitted', '✅'),
  approved('Approved', '👍'),
  rejected('Rejected', '❌');

  final String displayName;
  final String emoji;

  const WorkReportStatus(this.displayName, this.emoji);

  /// Get status color
  String getColor() {
    switch (this) {
      case WorkReportStatus.draft:
        return '#64748B'; // Gray
      case WorkReportStatus.submitted:
        return '#3B82F6'; // Blue
      case WorkReportStatus.approved:
        return '#16A34A'; // Green
      case WorkReportStatus.rejected:
        return '#EC2623'; // Red
    }
  }
}
