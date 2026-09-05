class RoleDailyRoutineItem {
  final int id;
  final int roleId;
  final String title;
  final String description;
  final int sequence;
  final String? timeOfDay;
  final int? estimatedMinutes;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const RoleDailyRoutineItem({
    required this.id,
    required this.roleId,
    required this.title,
    required this.description,
    required this.sequence,
    required this.timeOfDay,
    required this.estimatedMinutes,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RoleDailyRoutineItem.fromJson(Map<String, dynamic> json) {
    return RoleDailyRoutineItem(
      id: _toInt(json['id']),
      roleId: _toInt(json['role_id']),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      sequence: _toInt(json['sequence']),
      timeOfDay: json['time_of_day']?.toString(),
      estimatedMinutes: json['estimated_minutes'] == null
          ? null
          : _toInt(json['estimated_minutes']),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: _toDateTime(json['created_at']),
      updatedAt: _toDateTime(json['updated_at']),
    );
  }

  static int _toInt(dynamic value) =>
      value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? 0;

  static DateTime? _toDateTime(dynamic value) =>
      value == null ? null : DateTime.tryParse(value.toString());
}
