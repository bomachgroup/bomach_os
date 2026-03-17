class Role {
  final int id;
  final String name;
  final int? levelId;
  final int? departmentId;
  final int? unitId;
  final Map<String, List<String>> permissions;
  final DateTime createdAt;
  final DateTime updatedAt;

  Role({
    required this.id,
    required this.name,
    this.levelId,
    this.departmentId,
    this.unitId,
    required this.permissions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    final rawPermissions = json['permissions'] as Map<String, dynamic>? ?? {};
    final mappedPermissions = <String, List<String>>{};
    
    rawPermissions.forEach((key, value) {
      if (value is Iterable) {
        mappedPermissions[key] = List<String>.from(value);
      }
    });

    return Role(
      id: json['id'],
      name: json['name'],
      levelId: json['level_id'],
      departmentId: json['department_id'],
      unitId: json['unit_id'],
      permissions: mappedPermissions,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'level_id': levelId,
      'department_id': departmentId,
      'unit_id': unitId,
      'permissions': permissions,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
