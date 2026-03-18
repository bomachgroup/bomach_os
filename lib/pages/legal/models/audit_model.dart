class Audit {
  final int id;
  final String auditName;
  final String auditType;
  final String auditTypeDisplay;
  final String auditorName;
  final String auditorTitle;
  final String status;
  final String statusDisplay;
  final int? score;
  final String scorePercentage;
  final bool? isPassed;
  final String scoreCategory;
  final String auditDate;
  final String? auditNumber;
  final String description;
  final String findings;
  final String recommendations;
  final String? startDate;
  final String? endDate;
  final String auditorOrganization;
  final String department;
  final String createdAt;
  final String updatedAt;

  Audit({
    required this.id,
    required this.auditName,
    required this.auditType,
    required this.auditTypeDisplay,
    required this.auditorName,
    required this.auditorTitle,
    required this.status,
    required this.statusDisplay,
    this.score,
    required this.scorePercentage,
    this.isPassed,
    required this.scoreCategory,
    required this.auditDate,
    this.auditNumber,
    required this.description,
    required this.findings,
    required this.recommendations,
    this.startDate,
    this.endDate,
    required this.auditorOrganization,
    required this.department,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Audit.fromJson(Map<String, dynamic> json) {
    return Audit(
      id: json['id'] ?? 0,
      auditName: json['audit_name'] ?? '',
      auditType: json['audit_type'] ?? '',
      auditTypeDisplay: json['audit_type_display'] ?? json['audit_type'] ?? '',
      auditorName: json['auditor_name'] ?? '',
      auditorTitle: json['auditor_title'] ?? '',
      status: json['status'] ?? '',
      statusDisplay: json['status_display'] ?? json['status'] ?? '',
      score: json['score'],
      scorePercentage: json['score_percentage']?.toString() ?? '0%',
      isPassed: json['is_passed'],
      scoreCategory: json['score_category'] ?? '',
      auditDate: json['audit_date'] ?? '',
      auditNumber: json['audit_number'],
      description: json['description'] ?? '',
      findings: json['findings'] ?? '',
      recommendations: json['recommendations'] ?? '',
      startDate: json['start_date'],
      endDate: json['end_date'],
      auditorOrganization: json['auditor_organization'] ?? '',
      department: json['department'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'audit_name': auditName,
      'audit_type': auditType,
      'auditor_name': auditorName,
      if (auditorTitle.isNotEmpty) 'auditor_title': auditorTitle,
      if (status.isNotEmpty) 'status': status,
      if (score != null) 'score': score,
      if (auditDate.isNotEmpty) 'audit_date': auditDate,
      if (auditNumber != null && auditNumber!.isNotEmpty)
        'audit_number': auditNumber,
      if (description.isNotEmpty) 'description': description,
      if (findings.isNotEmpty) 'findings': findings,
      if (recommendations.isNotEmpty) 'recommendations': recommendations,
      if (startDate != null && startDate!.isNotEmpty) 'start_date': startDate,
      if (endDate != null && endDate!.isNotEmpty) 'end_date': endDate,
      if (auditorOrganization.isNotEmpty)
        'auditor_organization': auditorOrganization,
      if (department.isNotEmpty) 'department': department,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'audit_name': auditName,
      'audit_type': auditType,
      'auditor_name': auditorName,
      'auditor_title': auditorTitle,
      'status': status,
      'score': score,
      'audit_date': auditDate,
      'audit_number': auditNumber,
      'description': description,
      'findings': findings,
      'recommendations': recommendations,
      'start_date': startDate,
      'end_date': endDate,
      'auditor_organization': auditorOrganization,
      'department': department,
    };
  }
}

class AuditStatistics {
  final int totalAudits;
  final int completedAudits;
  final int inProgressAudits;
  final int scheduledAudits;
  final int cancelledAudits;
  final int passedAudits;
  final int failedAudits;
  final double averageScore;
  final Map<String, int> auditsByType;
  final Map<String, int> auditsByDepartment;

  AuditStatistics({
    required this.totalAudits,
    required this.completedAudits,
    required this.inProgressAudits,
    required this.scheduledAudits,
    required this.cancelledAudits,
    required this.passedAudits,
    required this.failedAudits,
    required this.averageScore,
    required this.auditsByType,
    required this.auditsByDepartment,
  });

  factory AuditStatistics.fromJson(Map<String, dynamic> json) {
    Map<String, int> parseMap(dynamic raw) {
      final Map<String, int> result = {};
      if (raw is Map) {
        raw.forEach((key, value) {
          result[key.toString()] =
              value is int ? value : int.tryParse(value.toString()) ?? 0;
        });
      }
      return result;
    }

    return AuditStatistics(
      totalAudits: json['total_audits'] ?? 0,
      completedAudits: json['completed_audits'] ?? 0,
      inProgressAudits: json['in_progress_audits'] ?? 0,
      scheduledAudits: json['scheduled_audits'] ?? 0,
      cancelledAudits: json['cancelled_audits'] ?? 0,
      passedAudits: json['passed_audits'] ?? 0,
      failedAudits: json['failed_audits'] ?? 0,
      averageScore: (json['average_score'] is num)
          ? (json['average_score'] as num).toDouble()
          : double.tryParse(json['average_score']?.toString() ?? '') ?? 0.0,
      auditsByType: parseMap(json['audits_by_type']),
      auditsByDepartment: parseMap(json['audits_by_department']),
    );
  }
}
