class RoleSuccessPlaybook {
  final int? id;
  final int roleId;
  final String roleName;
  final String title;
  final String? description;
  final List<PlaybookPhase> phases;
  final List<String> metrics;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const RoleSuccessPlaybook({
    this.id,
    required this.roleId,
    this.roleName = '',
    required this.title,
    this.description,
    this.phases = const [],
    this.metrics = const [],
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory RoleSuccessPlaybook.fromJson(Map<String, dynamic> json) {
    return RoleSuccessPlaybook(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      roleId: json['role_id'] is int ? json['role_id'] : int.tryParse(json['role_id']?.toString() ?? '0') ?? 0,
      roleName: json['role_name'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      phases: (json['phases'] as List?)?.map((p) => PlaybookPhase.fromJson(p as Map<String, dynamic>)).toList() ?? const [],
      metrics: (json['metrics'] as List?)?.cast<String>() ?? const [],
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
      'phases': phases.map((p) => p.toJson()).toList(),
      'metrics': metrics,
      'is_active': isActive,
    };
  }

  RoleSuccessPlaybook copyWith({
    int? id,
    int? roleId,
    String? roleName,
    String? title,
    String? description,
    List<PlaybookPhase>? phases,
    List<String>? metrics,
    bool? isActive,
  }) {
    return RoleSuccessPlaybook(
      id: id ?? this.id,
      roleId: roleId ?? this.roleId,
      roleName: roleName ?? this.roleName,
      title: title ?? this.title,
      description: description ?? this.description,
      phases: phases ?? this.phases,
      metrics: metrics ?? this.metrics,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class PlaybookPhase {
  final String phaseName;
  final int order;
  final String? description;
  final List<PlaybookStep> steps;

  const PlaybookPhase({
    required this.phaseName,
    this.order = 0,
    this.description,
    this.steps = const [],
  });

  factory PlaybookPhase.fromJson(Map<String, dynamic> json) {
    return PlaybookPhase(
      phaseName: json['phase_name'] ?? '',
      order: json['order'] ?? 0,
      description: json['description'],
      steps: (json['steps'] as List?)?.map((s) => PlaybookStep.fromJson(s as Map<String, dynamic>)).toList() ?? const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phase_name': phaseName,
      'order': order,
      'description': description,
      'steps': steps.map((s) => s.toJson()).toList(),
    };
  }
}

class PlaybookStep {
  final int stepNumber;
  final String title;
  final String? description;
  final String? owner;

  const PlaybookStep({
    this.stepNumber = 1,
    required this.title,
    this.description,
    this.owner,
  });

  factory PlaybookStep.fromJson(Map<String, dynamic> json) {
    return PlaybookStep(
      stepNumber: json['step_number'] ?? 1,
      title: json['title'] ?? '',
      description: json['description'],
      owner: json['owner'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'step_number': stepNumber,
      'title': title,
      'description': description,
      'owner': owner,
    };
  }
}
