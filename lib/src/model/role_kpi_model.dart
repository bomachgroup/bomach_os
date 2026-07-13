/// Role-level KPI definition (C12).
/// A KPI is a standard measurable indicator attached to a role template,
/// distinct from per-employee scorecard entries.
class RoleKpi {
  final int? id;
  final int roleId;
  final String roleName;
  final String metricName;
  final String? description;
  final String unit; // e.g. '%', 'NGN', 'count', 'days'
  final double target;
  final String frequency; // 'daily' | 'weekly' | 'monthly' | 'quarterly' | 'annual'
  final String? category; // e.g. 'Revenue', 'Attendance', 'Quality'
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const RoleKpi({
    this.id,
    required this.roleId,
    this.roleName = '',
    required this.metricName,
    this.description,
    required this.unit,
    required this.target,
    this.frequency = 'monthly',
    this.category,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory RoleKpi.fromJson(Map<String, dynamic> json) {
    return RoleKpi(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      roleId: json['role_id'] is int
          ? json['role_id']
          : int.tryParse(json['role_id']?.toString() ?? '0') ?? 0,
      roleName: json['role_name'] ?? '',
      metricName: json['metric_name'] ?? '',
      description: json['description'],
      unit: json['unit'] ?? '%',
      target: double.tryParse(json['target']?.toString() ?? '0') ?? 0,
      frequency: json['frequency'] ?? 'monthly',
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
      'metric_name': metricName,
      'description': description,
      'unit': unit,
      'target': target,
      'frequency': frequency,
      'category': category,
      'is_active': isActive,
    };
  }

  RoleKpi copyWith({
    int? id,
    int? roleId,
    String? roleName,
    String? metricName,
    String? description,
    String? unit,
    double? target,
    String? frequency,
    String? category,
    bool? isActive,
  }) {
    return RoleKpi(
      id: id ?? this.id,
      roleId: roleId ?? this.roleId,
      roleName: roleName ?? this.roleName,
      metricName: metricName ?? this.metricName,
      description: description ?? this.description,
      unit: unit ?? this.unit,
      target: target ?? this.target,
      frequency: frequency ?? this.frequency,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static const List<String> frequencyOptions = [
    'daily',
    'weekly',
    'monthly',
    'quarterly',
    'annual',
  ];

  static const List<String> unitOptions = [
    '%',
    'NGN',
    'count',
    'days',
    'hours',
    'score',
    'ratio',
  ];
}
