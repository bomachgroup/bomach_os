/// Disciplinary Process data models
class DisciplinaryAction {
  final String id;
  final String
      actionType; // Verbal Warning, Written Warning, Suspension, Termination, etc.
  final String severity; // Low, Medium, High, Critical
  final String icon;
  final String color;

  DisciplinaryAction({
    required this.id,
    required this.actionType,
    required this.severity,
    required this.icon,
    required this.color,
  });

  String getSeverityColor() {
    switch (severity) {
      case 'Low':
        return '#3B82F6'; // Blue
      case 'Medium':
        return '#FBBF24'; // Amber
      case 'High':
        return '#F97316'; // Orange
      case 'Critical':
        return '#EC2623'; // Red
      default:
        return '#95A5A6'; // Gray
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'actionType': actionType,
      'severity': severity,
      'icon': icon,
      'color': color,
    };
  }
}

/// Disciplinary case record
class DisciplinaryCaseRecord {
  final String caseId;
  final String employeeId;
  final String employeeName;
  final String employeeEmail;
  final String department;
  final String position;
  final String branch;
  final DisciplinaryActionType actionType;
  final String violation; // Reason for disciplinary action
  final String description; // Detailed explanation
  final DateTime dateOfViolation;
  final DateTime dateInitiated;
  final DateTime? effectiveDate;
  final String status; // Pending, In Progress, Approved, Completed, Appealed
  final String? suspensionStartDate;
  final String? suspensionEndDate;
  final int? suspensionDays;
  final String? terminationReason; // For termination cases
  final bool severancePaymentDue;
  final double? severanceAmount;
  final String? investigationDetails;
  final String? investigatedBy;
  final String? approvedBy;
  final DateTime? approvalDate;
  final String? employeeStatement;
  final String? witnessStatements;
  final bool appealFiled;
  final String? appealReason;
  final String? appealStatus; // Pending, Approved, Rejected

  DisciplinaryCaseRecord({
    required this.caseId,
    required this.employeeId,
    required this.employeeName,
    required this.employeeEmail,
    required this.department,
    required this.position,
    required this.branch,
    required this.actionType,
    required this.violation,
    required this.description,
    required this.dateOfViolation,
    required this.dateInitiated,
    this.effectiveDate,
    required this.status,
    this.suspensionStartDate,
    this.suspensionEndDate,
    this.suspensionDays,
    this.terminationReason,
    required this.severancePaymentDue,
    this.severanceAmount,
    this.investigationDetails,
    this.investigatedBy,
    this.approvedBy,
    this.approvalDate,
    this.employeeStatement,
    this.witnessStatements,
    required this.appealFiled,
    this.appealReason,
    this.appealStatus,
  });

  /// Get case status color
  String getStatusColor() {
    switch (status) {
      case 'Pending':
        return '#FBBF24'; // Amber
      case 'In Progress':
        return '#3B82F6'; // Blue
      case 'Approved':
        return '#16A34A'; // Green
      case 'Completed':
        return '#6B7280'; // Gray
      case 'Appealed':
        return '#F97316'; // Orange
      default:
        return '#95A5A6'; // Gray
    }
  }

  /// Calculate days remaining for suspension
  int getDaysRemaining() {
    if (suspensionEndDate == null) return 0;
    final endDate = DateTime.parse(suspensionEndDate!);
    final diff = endDate.difference(DateTime.now()).inDays;
    return diff > 0 ? diff : 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'caseId': caseId,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'employeeEmail': employeeEmail,
      'department': department,
      'position': position,
      'branch': branch,
      'actionType': actionType.displayName,
      'violation': violation,
      'description': description,
      'dateOfViolation': dateOfViolation.toIso8601String(),
      'dateInitiated': dateInitiated.toIso8601String(),
      'effectiveDate': effectiveDate?.toIso8601String(),
      'status': status,
      'suspensionStartDate': suspensionStartDate,
      'suspensionEndDate': suspensionEndDate,
      'suspensionDays': suspensionDays,
      'terminationReason': terminationReason,
      'severancePaymentDue': severancePaymentDue,
      'severanceAmount': severanceAmount,
      'investigationDetails': investigationDetails,
      'investigatedBy': investigatedBy,
      'approvedBy': approvedBy,
      'approvalDate': approvalDate?.toIso8601String(),
      'employeeStatement': employeeStatement,
      'witnessStatements': witnessStatements,
      'appealFiled': appealFiled,
      'appealReason': appealReason,
      'appealStatus': appealStatus,
    };
  }
}

/// Disciplinary action types enum
enum DisciplinaryActionType {
  verbalWarning('Verbal Warning', '⚠️', '#3B82F6', 'Low'),
  writtenWarning('Written Warning', '📝', '#FBBF24', 'Medium'),
  suspension('Suspension', '🚫', '#F97316', 'High'),
  termination('Termination', '❌', '#EC2623', 'Critical'),
  finalWarning('Final Warning', '⚠️', '#F97316', 'High'),
  demotion('Demotion', '📉', '#FBBF24', 'Medium');

  final String displayName;
  final String icon;
  final String color;
  final String severity;

  const DisciplinaryActionType(
      this.displayName, this.icon, this.color, this.severity);
}

/// Violation categories
enum ViolationCategory {
  attendance('Attendance Issues', '⏰'),
  conduct('Misconduct', '😠'),
  performance('Poor Performance', '📊'),
  insubordination('Insubordination', '🙅'),
  dishonesty('Dishonesty', '🤥'),
  safety('Safety Violation', '⚠️'),
  confidentiality('Confidentiality Breach', '🔐'),
  harassment('Harassment/Discrimination', '😡'),
  other('Other', '📋');

  final String displayName;
  final String icon;

  const ViolationCategory(this.displayName, this.icon);
}

/// Disciplinary process summary
class DisciplinaryProcessSummary {
  final int totalCases;
  final int pendingCases;
  final int inProgressCases;
  final int completedCases;
  final int appealedCases;
  final Map<String, int> casesByType; // Verbal Warning: 5, Suspension: 2, etc.
  final Map<String, int> casesByStatus;
  final List<DisciplinaryCaseRecord> recentCases;

  DisciplinaryProcessSummary({
    required this.totalCases,
    required this.pendingCases,
    required this.inProgressCases,
    required this.completedCases,
    required this.appealedCases,
    required this.casesByType,
    required this.casesByStatus,
    required this.recentCases,
  });

  double getCompletionRate() {
    if (totalCases == 0) return 0;
    return (completedCases / totalCases) * 100;
  }

  double getAppealRate() {
    if (completedCases == 0) return 0;
    return (appealedCases / completedCases) * 100;
  }
}
