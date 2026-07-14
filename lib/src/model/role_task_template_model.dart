class RoleTaskTemplate {
  final int? id;
  final int roleId;
  final String roleName;
  final String taskName;
  final String? description;
  final int estimatedDuration; // minutes
  final String frequency; // once | daily | weekly | monthly | quarterly
  final String priority; // low | medium | high | critical
  final String? category;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const RoleTaskTemplate({
    this.id,
    required this.roleId,
    this.roleName = '',
    required this.taskName,
    this.description,
    this.estimatedDuration = 30,
    this.frequency = 'weekly',
    this.priority = 'medium',
    this.category,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory RoleTaskTemplate.fromJson(Map<String, dynamic> json) {
    return RoleTaskTemplate(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      roleId: json['role_id'] is int
          ? json['role_id']
          : int.tryParse(json['role_id']?.toString() ?? '0') ?? 0,
      roleName: json['role_name'] ?? '',
      taskName: json['task_name'] ?? '',
      description: json['description'],
      estimatedDuration:
          int.tryParse(json['estimated_duration']?.toString() ?? '30') ?? 30,
      frequency: json['frequency'] ?? 'weekly',
      priority: json['priority'] ?? 'medium',
      category: json['category'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role_id': roleId,
      'task_name': taskName,
      'description': description,
      'estimated_duration': estimatedDuration,
      'frequency': frequency,
      'priority': priority,
      'category': category,
      'is_active': isActive,
    };
  }

  RoleTaskTemplate copyWith({
    int? id,
    int? roleId,
    String? roleName,
    String? taskName,
    String? description,
    int? estimatedDuration,
    String? frequency,
    String? priority,
    String? category,
    bool? isActive,
  }) {
    return RoleTaskTemplate(
      id: id ?? this.id,
      roleId: roleId ?? this.roleId,
      roleName: roleName ?? this.roleName,
      taskName: taskName ?? this.taskName,
      description: description ?? this.description,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      frequency: frequency ?? this.frequency,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static const List<String> frequencyOptions = [
    'once',
    'daily',
    'weekly',
    'monthly',
    'quarterly',
  ];

  static const List<String> priorityOptions = [
    'low',
    'medium',
    'high',
    'critical',
  ];
}
