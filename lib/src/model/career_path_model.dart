class CareerPathStep {
  final int id;
  final int roleId;
  final int nextRoleId;
  final String nextRoleName;
  final double? minYearsInRole;
  final double? minKpiScore;
  final List<String> requiredCertifications;
  final int sortOrder;
  final bool isActive;

  CareerPathStep({
    required this.id,
    required this.roleId,
    required this.nextRoleId,
    required this.nextRoleName,
    this.minYearsInRole,
    this.minKpiScore,
    this.requiredCertifications = const [],
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory CareerPathStep.fromJson(Map<String, dynamic> json) {
    return CareerPathStep(
      id: json['id'] ?? 0,
      roleId: json['role_id'] ?? 0,
      nextRoleId: json['next_role_id'] ?? 0,
      nextRoleName: json['next_role_name'] ?? '',
      minYearsInRole: (json['min_years_in_role'] as num?)?.toDouble(),
      minKpiScore: (json['min_kpi_score'] as num?)?.toDouble(),
      requiredCertifications: json['required_certifications'] != null
          ? List<String>.from(json['required_certifications'])
          : [],
      sortOrder: json['sort_order'] ?? 0,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role_id': roleId,
      'next_role_id': nextRoleId,
      'min_years_in_role': minYearsInRole,
      'min_kpi_score': minKpiScore,
      'required_certifications': requiredCertifications,
      'sort_order': sortOrder,
      'is_active': isActive,
    };
  }

  String get criteriaSummary {
    final parts = <String>[];
    if (minYearsInRole != null) parts.add('${minYearsInRole!.toStringAsFixed(0)} yrs');
    if (minKpiScore != null) parts.add('KPI ${minKpiScore!.toStringAsFixed(0)}+');
    if (requiredCertifications.isNotEmpty) parts.add('${requiredCertifications.length} cert(s)');
    return parts.isEmpty ? 'No criteria' : parts.join(' · ');
  }
}
