class RoleRiskProfile {
  final int id;
  final int roleId;
  final String obligation;
  final String? description;
  final String category;
  final String priority;
  final String status;
  final String? deadline;
  final String? assignedTo;
  final String createdAt;
  final String updatedAt;

  RoleRiskProfile({
    required this.id,
    required this.roleId,
    required this.obligation,
    this.description,
    this.category = 'Regulatory',
    this.priority = 'Medium',
    this.status = 'pending',
    this.deadline,
    this.assignedTo,
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory RoleRiskProfile.fromJson(Map<String, dynamic> json) {
    return RoleRiskProfile(
      id: json['id'] ?? 0,
      roleId: json['role_id'] ?? 0,
      obligation: json['obligation'] ?? '',
      description: json['description'],
      category: json['category'] ?? 'Regulatory',
      priority: json['priority'] ?? 'Medium',
      status: json['status'] ?? 'pending',
      deadline: json['deadline'],
      assignedTo: json['assigned_to'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role_id': roleId,
      'obligation': obligation,
      'description': description,
      'category': category,
      'priority': priority,
      'status': status,
      'deadline': deadline,
      'assigned_to': assignedTo,
    };
  }

  static const List<String> categoryOptions = [
    'Regulatory',
    'Legal',
    'Financial',
    'Safety',
    'Operational',
    'Environmental',
  ];

  static const List<String> priorityOptions = [
    'Critical',
    'High',
    'Medium',
    'Low',
  ];

  static const List<String> statusOptions = [
    'pending',
    'compliant',
    'expired',
    'at_risk',
    'overdue',
  ];
}
