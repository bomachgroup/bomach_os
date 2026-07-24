class RoleSop {
  final int id;
  final int roleId;
  final int sopId;
  final String title;
  final String description;
  final String version;
  final String priority;
  final bool isUpToDate;
  final bool isActive;
  final int? departmentId;
  final int? unitId;

  const RoleSop({
    required this.id,
    required this.roleId,
    required this.sopId,
    required this.title,
    this.description = '',
    this.version = 'v1.0',
    this.priority = 'Medium',
    this.isUpToDate = true,
    this.isActive = true,
    this.departmentId,
    this.unitId,
  });

  factory RoleSop.fromJson(Map<String, dynamic> json) {
    final sopMap = json['sop'] as Map<String, dynamic>?;
    return RoleSop(
      id: json['id'] ?? 0,
      roleId: json['role_id'] ?? 0,
      sopId: json['sop_id'] ?? sopMap?['id'] ?? 0,
      title: sopMap?['title'] ?? '',
      description: sopMap?['description'] ?? '',
      version: sopMap?['version'] ?? 'v1.0',
      priority: sopMap?['priority'] ?? 'Medium',
      isUpToDate: sopMap?['is_up_to_date'] ?? true,
      isActive: json['is_active'] ?? true,
      departmentId: sopMap?['department_id'],
      unitId: sopMap?['unit_id'],
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'sop_id': sopId,
      'is_active': isActive,
    };
  }
}
