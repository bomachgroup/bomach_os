class RoleSop {
  final int? id;
  final int roleId;
  final String roleName;
  final String title;
  final String? description;
  final List<SopStep> steps;
  final int version;
  final bool isLatest;
  final String? category;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const RoleSop({
    this.id,
    required this.roleId,
    this.roleName = '',
    required this.title,
    this.description,
    this.steps = const [],
    this.version = 1,
    this.isLatest = true,
    this.category,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory RoleSop.fromJson(Map<String, dynamic> json) {
    return RoleSop(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      roleId: json['role_id'] is int ? json['role_id'] : int.tryParse(json['role_id']?.toString() ?? '0') ?? 0,
      roleName: json['role_name'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      steps: (json['steps'] as List?)?.map((s) => SopStep.fromJson(s as Map<String, dynamic>)).toList() ?? const [],
      version: json['version'] ?? 1,
      isLatest: json['is_latest'] ?? true,
      category: json['category'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role_id': roleId,
      'title': title,
      'description': description,
      'steps': steps.map((s) => s.toJson()).toList(),
      'version': version,
      'is_latest': isLatest,
      'category': category,
      'is_active': isActive,
    };
  }

  RoleSop copyWith({
    int? id,
    int? roleId,
    String? roleName,
    String? title,
    String? description,
    List<SopStep>? steps,
    int? version,
    bool? isLatest,
    String? category,
    bool? isActive,
  }) {
    return RoleSop(
      id: id ?? this.id,
      roleId: roleId ?? this.roleId,
      roleName: roleName ?? this.roleName,
      title: title ?? this.title,
      description: description ?? this.description,
      steps: steps ?? this.steps,
      version: version ?? this.version,
      isLatest: isLatest ?? this.isLatest,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static const List<String> categoryOptions = [
    'Administrative',
    'Technical',
    'Safety',
    'Quality',
    'Onboarding',
    'Compliance',
  ];
}

class SopStep {
  final int stepNumber;
  final String title;
  final String? description;
  final String? mediaUrl;

  const SopStep({
    this.stepNumber = 1,
    required this.title,
    this.description,
    this.mediaUrl,
  });

  factory SopStep.fromJson(Map<String, dynamic> json) {
    return SopStep(
      stepNumber: json['step_number'] ?? 1,
      title: json['title'] ?? '',
      description: json['description'],
      mediaUrl: json['media_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'step_number': stepNumber,
      'title': title,
      'description': description,
      'media_url': mediaUrl,
    };
  }
}
