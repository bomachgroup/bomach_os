class Role {
  final int id;
  final String name;
  final String? mission;
  final String? jobDescription;
  final List<String>? responsibilities;
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

  // C5: Reporting Structure
  final int? reportsToRoleId;
  final String? reportsToRoleName;
  final List<int> directReportRoleIds;

  Role({
    required this.id,
    required this.name,
    this.mission,
    this.jobDescription,
    this.responsibilities,
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
    this.reportsToRoleId,
    this.reportsToRoleName,
    this.directReportRoleIds = const [],
  });

  Role copyWith({
    String? mission,
    String? jobDescription,
    List<String>? responsibilities,
  }) {
    return Role(
      id: id,
      name: name,
      mission: mission ?? this.mission,
      jobDescription: jobDescription ?? this.jobDescription,
      responsibilities: responsibilities ?? this.responsibilities,
      branches: branches,
      permissions: permissions,
      createdAt: createdAt,
      updatedAt: updatedAt,
      levelId: levelId,
      levelName: levelName,
      departmentId: departmentId,
      departmentName: departmentName,
      unitId: unitId,
      unitName: unitName,
      reportsToRoleId: reportsToRoleId,
      reportsToRoleName: reportsToRoleName,
      directReportRoleIds: directReportRoleIds,
    );
  }

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

    // Parse direct reports list safely
    List<int> directReports = [];
    if (json['direct_report_role_ids'] is List) {
      directReports = List<int>.from(json['direct_report_role_ids']);
    } else if (json['direct_reports'] is List) {
      directReports = List<int>.from(json['direct_reports']);
    }

    return Role(
      id: json['id'],
      name: json['name'] ?? '',
      mission: json['mission'] ?? '',
      jobDescription: json['job_description'] ?? '',
      responsibilities: json['responsibilities'] != null
          ? List<String>.from(json['responsibilities'])
          : null,
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
      // C5: Reporting Structure
      reportsToRoleId: json['reports_to_role_id'] ?? json['reports_to_id'],
      reportsToRoleName:
          json['reports_to_role_name'] ?? json['reports_to_name'],
      directReportRoleIds: directReports,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mission': mission,
      'job_description': jobDescription,
      'responsibilities': responsibilities,
      'branch_ids': branches.map((b) => b.id).toList(),
      'permissions': permissions,
      'reports_to_role_id': reportsToRoleId,
      'direct_report_role_ids': directReportRoleIds,
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
