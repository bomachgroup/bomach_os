class Department {
  final String id;
  final String name;
  final String description;

  Department({
    required this.id,
    required this.name,
    required this.description,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class DepartmentUnit {
  final String? id;
  final String name;
  final String description;
  final String departmentId;
  final String? departmentName; // For display
  final String? hod;
  final String? status;

  DepartmentUnit({
    this.id,
    required this.name,
    required this.description,
    required this.departmentId,
    this.departmentName,
    this.hod,
    this.status,
  });

  factory DepartmentUnit.fromJson(Map<String, dynamic> json) {
    return DepartmentUnit(
      id: json['id']?.toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      departmentId: json['department_id']?.toString() ?? '',
      departmentName: json['department_name'] ?? '',
      hod: json['hod_name'] ?? 'Not Assigned',
      status: json['status'] ?? 'Active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'department_id': departmentId,
    };
  }
}
