class RoleTargetTemplate {
  final int id;
  final int roleId;
  final String title;
  final String description;
  final dynamic targetValue; // number or string
  final String unit;
  final String period;
  final int sequence;
  final bool isActive;

  RoleTargetTemplate({
    required this.id,
    required this.roleId,
    required this.title,
    this.description = '',
    required this.targetValue,
    this.unit = '',
    required this.period,
    this.sequence = 0,
    this.isActive = true,
  });

  factory RoleTargetTemplate.fromJson(Map<String, dynamic> json) {
    return RoleTargetTemplate(
      id: json['id'] ?? 0,
      roleId: json['role_id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      targetValue: json['target_value'],
      unit: json['unit'] ?? '',
      period: json['period'] ?? '',
      sequence: json['sequence'] ?? 0,
      isActive: json['is_active'] ?? true,
    );
  }

  String get targetDisplay {
    if (targetValue == null) return '—';
    final val = targetValue.toString();
    return unit.isNotEmpty ? '$val $unit' : val;
  }

  String get periodDisplay {
    if (period.isEmpty) return '';
    return period[0].toUpperCase() + period.substring(1);
  }
}
