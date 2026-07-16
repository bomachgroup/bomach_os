class KPIMetricMinimal {
  final int id;
  final String name;
  final String description;
  final String unit;

  const KPIMetricMinimal({
    required this.id,
    required this.name,
    required this.description,
    required this.unit,
  });

  factory KPIMetricMinimal.fromJson(Map<String, dynamic> json) => KPIMetricMinimal(
    id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    unit: json['unit'] ?? 'percentage',
  );
}

class RoleKpi {
  final int? id;
  final int roleId;
  final int metricId;
  final KPIMetricMinimal? metric;
  final String trackingMode;
  final double? targetValue;
  final double? weight;
  final String period;
  final int? sequence;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const RoleKpi({
    this.id,
    required this.roleId,
    required this.metricId,
    this.metric,
    required this.trackingMode,
    this.targetValue,
    this.weight,
    required this.period,
    this.sequence,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory RoleKpi.fromJson(Map<String, dynamic> json) => RoleKpi(
    id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
    roleId: json['role_id'] is int ? json['role_id'] : int.tryParse(json['role_id']?.toString() ?? '0') ?? 0,
    metricId: json['metric_id'] is int ? json['metric_id'] : int.tryParse(json['metric_id']?.toString() ?? '0') ?? 0,
    metric: json['metric'] != null ? KPIMetricMinimal.fromJson(json['metric']) : null,
    trackingMode: json['tracking_mode'] ?? '',
    targetValue: json['target_value'] != null ? double.tryParse(json['target_value'].toString()) : null,
    weight: json['weight'] != null ? double.tryParse(json['weight'].toString()) : null,
    period: json['period'] ?? '',
    sequence: json['sequence'] is int ? json['sequence'] : int.tryParse(json['sequence']?.toString() ?? ''),
    isActive: json['is_active'] ?? true,
    createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'role_id': roleId,
    'metric_id': metricId,
    'tracking_mode': trackingMode,
    if (targetValue != null) 'target_value': targetValue,
    if (weight != null) 'weight': weight,
    'period': period,
    if (sequence != null) 'sequence': sequence,
    'is_active': isActive,
  };

  static const List<String> trackingModeOptions = ['manual', 'automatic', 'semi_automatic'];
  static const List<String> periodOptions = ['weekly', 'monthly', 'quarterly', 'semi_annual', 'annual'];
}
