class SuccessionPlan {
  final int id;
  final int roleId;
  final String? primarySuccessorName;
  final String? primarySuccessorEmployeeId;
  final String? backupSuccessorName;
  final String? backupSuccessorEmployeeId;
  final String readiness;
  final String? developmentPlan;
  final String? notes;
  final String createdAt;
  final String updatedAt;

  SuccessionPlan({
    required this.id,
    required this.roleId,
    this.primarySuccessorName,
    this.primarySuccessorEmployeeId,
    this.backupSuccessorName,
    this.backupSuccessorEmployeeId,
    this.readiness = 'pipeline',
    this.developmentPlan,
    this.notes,
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory SuccessionPlan.fromJson(Map<String, dynamic> json) {
    return SuccessionPlan(
      id: json['id'] ?? 0,
      roleId: json['role_id'] ?? 0,
      primarySuccessorName: json['primary_successor_name'],
      primarySuccessorEmployeeId: json['primary_successor_employee_id'],
      backupSuccessorName: json['backup_successor_name'],
      backupSuccessorEmployeeId: json['backup_successor_employee_id'],
      readiness: json['readiness'] ?? 'pipeline',
      developmentPlan: json['development_plan'],
      notes: json['notes'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role_id': roleId,
      'primary_successor_name': primarySuccessorName,
      'primary_successor_employee_id': primarySuccessorEmployeeId,
      'backup_successor_name': backupSuccessorName,
      'backup_successor_employee_id': backupSuccessorEmployeeId,
      'readiness': readiness,
      'development_plan': developmentPlan,
      'notes': notes,
    };
  }

  static const List<String> readinessOptions = [
    'ready_now',
    'ready_1yr',
    'pipeline',
  ];

  String get readinessLabel {
    switch (readiness) {
      case 'ready_now':
        return 'Ready Now';
      case 'ready_1yr':
        return 'Ready in 1yr';
      case 'pipeline':
        return 'Pipeline';
      default:
        return readiness;
    }
  }
}
