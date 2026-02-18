class Employee {
  final String id;
  final String email;
  final String? password;
  final String firstName;
  final String lastName;
  final String? gender;
  final String? maritalStatus;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? address;
  final String? profilePicture;
  final String? employmentType;
  final int? branchId;
  final int? departmentId;
  final int? levelId;
  final DateTime? startDate;
  final double? grossSalary;
  final bool isActive;
  final Map<String, dynamic>? allowances;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Employee({
    required this.id,
    required this.email,
    this.password,
    required this.firstName,
    required this.lastName,
    this.gender,
    this.maritalStatus,
    this.phoneNumber,
    this.dateOfBirth,
    this.address,
    this.profilePicture,
    this.employmentType,
    this.branchId,
    this.departmentId,
    this.levelId,
    this.startDate,
    this.grossSalary,
    required this.isActive,
    this.allowances,
    this.createdAt,
    this.updatedAt,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['user_id']?.toString() ?? json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      gender: json['gender'],
      maritalStatus: json['marital_status'],
      phoneNumber: json['phone_number'],
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'])
          : null,
      address: json['address'],
      profilePicture: json['profile_picture'],
      employmentType: json['employment_type'],
      branchId: json['branch_id'],
      departmentId: json['department_id'],
      levelId: json['level_id'],
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'])
          : null,
      grossSalary: json['gross_salary'] is num
          ? (json['gross_salary'] as num).toDouble()
          : 0.0,
      isActive: json['is_active'] ?? true,
      allowances: json['allowances'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'gender': gender ?? 'male',
      'marital_status': maritalStatus ?? 'single',
      'phone_number': phoneNumber ?? '',
      'date_of_birth': dateOfBirth?.toIso8601String().split('T').first,
      'address': address ?? '',
      'profile_picture': profilePicture ?? "string",
      'employment_type': employmentType ?? 'full-time',
      'branch_id': branchId ?? 0,
      'department_id': departmentId ?? 0,
      'level_id': levelId ?? 0,
      'start_date': startDate?.toIso8601String().split('T').first,
      'is_active': isActive,
      'gross_salary': grossSalary ?? 0,
      'allowances': allowances ?? {},
    };

    if (password != null && password!.isNotEmpty) {
      data['password'] = password;
    }

    return data;
  }
}

class Department {
  final String id;
  final String name;
  final String? description;
  final int? count;

  Department({
    required this.id,
    required this.name,
    this.description,
    this.count,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      count: json['count'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
      };
}

class DepartmentUnit {
  final String id;
  final String name;
  final String? description;
  final String departmentId;

  DepartmentUnit({
    required this.id,
    required this.name,
    this.description,
    required this.departmentId,
  });

  factory DepartmentUnit.fromJson(Map<String, dynamic> json) {
    return DepartmentUnit(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      departmentId: json['department_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'department_id': departmentId,
      };
}
