class RoleTaskTemplate {
  final int? id;
  final int roleId;
  final String title;
  final String description;
  final int sequence;
  final String defaultPriority;
  final int? estimatedMinutes;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const RoleTaskTemplate({
    this.id,
    required this.roleId,
    required this.title,
    this.description = '',
    this.sequence = 1,
    this.defaultPriority = 'medium',
    this.estimatedMinutes = 30,
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
      title: json['title'] ?? json['task_name'] ?? '',
      description: json['description'] ?? '',
      sequence: json['sequence'] is int
          ? json['sequence']
          : int.tryParse(json['sequence']?.toString() ?? '1') ?? 1,
      defaultPriority: json['default_priority'] ?? json['priority'] ?? 'medium',
      estimatedMinutes: json['estimated_minutes'] is int
          ? json['estimated_minutes']
          : int.tryParse(json['estimated_minutes']?.toString() ??
              json['estimated_duration']?.toString() ??
              '30'),
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'title': title,
      if (description.isNotEmpty) 'description': description,
      'sequence': sequence,
      'default_priority': defaultPriority,
      if (estimatedMinutes != null) 'estimated_minutes': estimatedMinutes,
      'is_active': isActive,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'title': title,
      'description': description,
      'sequence': sequence,
      'default_priority': defaultPriority,
      'estimated_minutes': estimatedMinutes,
      'is_active': isActive,
    };
  }

  static const List<String> priorityOptions = [
    'low',
    'medium',
    'high',
    'critical',
  ];
}
