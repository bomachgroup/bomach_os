class Department {
  final int id;
  final String name;
  final String description;
  List<DepartmentEmployee> employees;
  int employeeCount;

  Department({
    required this.id,
    required this.name,
    required this.description,
    this.employees = const [],
    this.employeeCount = 0,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class DepartmentEmployee {
  final int id;
  final int userId;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String? gender;
  final String? phone;
  final String? profilePicture;
  final String employeeId;
  final String employmentType;
  final int departmentId;
  final String departmentName;
  final int? levelId;
  final String? employeeLevel;
  final String? startDate;

  DepartmentEmployee({
    required this.id,
    required this.userId,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.gender,
    this.phone,
    this.profilePicture,
    required this.employeeId,
    required this.employmentType,
    required this.departmentId,
    required this.departmentName,
    this.levelId,
    this.employeeLevel,
    this.startDate,
  });

  factory DepartmentEmployee.fromJson(Map<String, dynamic> json) {
    return DepartmentEmployee(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      gender: json['gender'],
      phone: json['phone_number'],
      profilePicture: json['profile_picture'],
      employeeId: json['employee_id'] ?? '',
      employmentType: json['employment_type'] ?? '',
      departmentId: json['department_id'] ?? 0,
      departmentName: json['department_name'] ?? '',
      levelId: json['level_id'],
      employeeLevel: json['employee_level'],
      startDate: json['start_date'],
    );
  }

  String get fullName => '$firstName $lastName';
}
