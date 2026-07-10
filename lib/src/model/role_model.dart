class Role {
  final int id;
  final String name;
  final String? mission;
  final List<RoleBranch> branches;
  final Map<String, List<String>> permissions;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Keep legacy fields for backwards compat with any UI that references them
  final int? levelId;
  final String? levelName;
  final int? departmentId;
  final String? departmentName;
  final int? unitId;
  final String? unitName;

  Role({
    required this.id,
    required this.name,
    this.mission,
    this.branches = const [],
    required this.permissions,
    required this.createdAt,
    required this.updatedAt,
    this.levelId,
    this.levelName,
    this.departmentId,
    this.departmentName,
    this.unitId,
    this.unitName,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    final rawPermissions = json['permissions'] as Map<String, dynamic>? ?? {};
    final mappedPermissions = <String, List<String>>{};

    rawPermissions.forEach((key, value) {
      if (value is Iterable) {
        mappedPermissions[key] = List<String>.from(value);
      }
    });

    // Parse branches array (new API format)
    List<RoleBranch> branches = [];
    if (json['branches'] is List) {
      branches = (json['branches'] as List)
          .map((b) => RoleBranch.fromJson(b as Map<String, dynamic>))
          .toList();
    }

    return Role(
      id: json['id'],
      name: json['name'] ?? '',
      mission: json['mission'] ?? '',
      branches: branches,
      permissions: mappedPermissions,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      // Legacy fields (may be absent in new API)
      levelId: json['level_id'],
      levelName: json['level_name'],
      departmentId: json['department_id'],
      departmentName: json['department_name'],
      unitId: json['unit_id'],
      unitName: json['unit_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mission': mission,
      'branch_ids': branches.map((b) => b.id).toList(),
      'permissions': permissions,
    };
  }

  /// Total number of permission actions across all resources
  int get totalPermissionCount =>
      permissions.values.fold(0, (sum, actions) => sum + actions.length);
}

class RoleBranch {
  final int id;
  final String branchName;

  RoleBranch({required this.id, required this.branchName});

  factory RoleBranch.fromJson(Map<String, dynamic> json) {
    return RoleBranch(
      id: json['id'],
      branchName: json['branch_name'] ?? '',
    );
  }
}
