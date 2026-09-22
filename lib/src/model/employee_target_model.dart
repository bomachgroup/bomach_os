class EmployeeTarget {
  final int id;
  final String title;
  final String description;
  final String targetValue;
  final String unit;
  final String period;
  final bool isActive;

  const EmployeeTarget({
    required this.id,
    required this.title,
    required this.description,
    required this.targetValue,
    required this.unit,
    required this.period,
    required this.isActive,
  });

  factory EmployeeTarget.fromJson(Map<String, dynamic> json) {
    return EmployeeTarget(
      id: _toInt(json['id']),
      title: json['title']?.toString().trim() ?? '',
      description: json['description']?.toString().trim() ?? '',
      targetValue: json['target_value']?.toString().trim() ?? '',
      unit: json['unit']?.toString().trim() ?? '',
      period: json['period']?.toString().trim() ?? '',
      isActive: json['is_active'] == true,
    );
  }

  String get optionLabel {
    final goal = [targetValue, unit].where((part) => part.isNotEmpty).join(' ');
    return [
      title.isEmpty ? 'Assigned target' : title,
      if (goal.isNotEmpty) 'Goal: $goal',
      if (period.isNotEmpty) period,
    ].join(' · ');
  }

  static int _toInt(dynamic value) =>
      value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? 0;
}
