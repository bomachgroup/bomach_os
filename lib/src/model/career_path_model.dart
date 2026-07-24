class CareerPathStep {
  final int id;
  final int fromRoleId;
  final int toRoleId;
  final String toRoleName; // from nested to_role object
  final String description;
  final String requirements;
  final int? estimatedDurationMonths;
  final int sequence;
  final bool isActive;

  CareerPathStep({
    required this.id,
    required this.fromRoleId,
    required this.toRoleId,
    required this.toRoleName,
    this.description = '',
    this.requirements = '',
    this.estimatedDurationMonths,
    this.sequence = 0,
    this.isActive = true,
  });

  factory CareerPathStep.fromJson(Map<String, dynamic> json) {
    final toRole = json['to_role'] as Map<String, dynamic>?;
    return CareerPathStep(
      id: json['id'] ?? 0,
      fromRoleId: json['from_role_id'] ?? 0,
      toRoleId: json['to_role_id'] ?? 0,
      toRoleName: toRole?['name'] ?? '',
      description: json['description'] ?? '',
      requirements: json['requirements'] ?? '',
      estimatedDurationMonths: json['estimated_duration_months'] as int?,
      sequence: json['sequence'] ?? 0,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'to_role_id': toRoleId,
      'description': description,
      'requirements': requirements,
      if (estimatedDurationMonths != null)
        'estimated_duration_months': estimatedDurationMonths,
      'sequence': sequence,
      'is_active': isActive,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      if (toRoleId != 0) 'to_role_id': toRoleId,
      'description': description,
      'requirements': requirements,
      'estimated_duration_months': estimatedDurationMonths,
      'sequence': sequence,
      'is_active': isActive,
    };
  }

  String get criteriaSummary {
    final parts = <String>[];
    if (estimatedDurationMonths != null) {
      parts.add('~${estimatedDurationMonths}mo');
    }
    if (requirements.isNotEmpty) parts.add('Has requirements');
    return parts.isEmpty ? 'No criteria set' : parts.join(' · ');
  }
}
