class DisciplinaryCase {
  final String id;
  final String employeeId;
  final String violationType; // e.g., "Misconduct", "Lateness"
  final String violationCategory; // e.g., "Minor", "Major"
  final String violationTitle;
  final String violationDescription;
  final DateTime? actionDate;
  final String actionType; // e.g., "Warning", "Suspension"
  final String? investigationDetails;
  final bool severancePaymentDue;
  final double? severanceAmount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? actionTypeColor; // e.g., for UI display

  DisciplinaryCase({
    required this.id,
    required this.employeeId,
    required this.violationType,
    required this.violationCategory,
    required this.violationTitle,
    required this.violationDescription,
    this.actionDate,
    required this.actionType,
    this.investigationDetails,
    required this.severancePaymentDue,
    this.severanceAmount,
    this.createdAt,
    this.updatedAt,
    this.actionTypeColor,
  });

  factory DisciplinaryCase.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse doubles
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    return DisciplinaryCase(
      id: json['id']?.toString() ?? '',
      employeeId: json['employee_id']?.toString() ?? '',
      violationType: json['violation_type'] ?? '',
      violationCategory: json['violation_category'] ?? '',
      violationTitle: json['violation_title'] ?? '',
      violationDescription: json['violation_description'] ?? '',
      actionDate: json['action_date'] != null
          ? DateTime.tryParse(json['action_date'])
          : null,
      actionType: json['action_type'] ?? '',
      investigationDetails: json['investigation_details'],
      severancePaymentDue: json['severance_payment_due'] ?? false,
      severanceAmount: parseDouble(json['severance_amount']),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      actionTypeColor: json['action_type_color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employee_id': employeeId,
      'violation_type': violationType,
      'violation_category': violationCategory,
      'violation_title': violationTitle,
      'violation_description': violationDescription,
      'action_date':
          actionDate?.toIso8601String().split('T').first, // Format YYYY-MM-DD
      'action_type': actionType,
      'investigation_details': investigationDetails,
      'severance_payment_due': severancePaymentDue,
      'severance_amount': severanceAmount,
      'action_type_color': actionTypeColor,
    };
  }
}
