class User {
  final int userId;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? gender;
  final String? maritalStatus;
  final String? dateOfBirth;
  final String? address;
  final String? profilePicture;
  final bool isVerified;
  final bool isActive;
  final int id; // The internal employee record ID
  final String? employeeId; // The formatted ID (e.g., EMP-001)
  final String? employmentType;
  final int branchId;
  final int departmentId;
  final int levelId;
  final String? startDate;
  final String createdAt;
  final String? updatedAt;
  final bool? twoFactorEnabled;
  final String? role;

  User({
    required this.userId,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.gender,
    this.maritalStatus,
    this.dateOfBirth,
    this.address,
    this.profilePicture,
    required this.isVerified,
    required this.isActive,
    required this.id,
    this.employeeId,
    this.employmentType,
    required this.branchId,
    required this.departmentId,
    required this.levelId,
    this.startDate,
    required this.createdAt,
    this.updatedAt,
    this.twoFactorEnabled,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        userId: json['user_id'] ?? 0,
        username: json['username'] ?? '',
        email: json['email'] ?? '',
        firstName: json['first_name'] ?? '',
        lastName: json['last_name'] ?? '',
        phoneNumber: json['phone_number'],
        gender: json['gender'] ?? '',
        maritalStatus: json['marital_status'] ?? '',
        dateOfBirth: json['date_of_birth'] ?? '',
        address: json['address'] ?? '',
        profilePicture: json['profile_picture'] ?? '',
        isVerified: json['is_verified'] ?? false,
        isActive: json['is_active'] ?? false,
        id: json['id'] ?? 0,
        employeeId: json['employee_id'] ?? '',
        employmentType: json['employment_type'] ?? '',
        branchId: json['branch_id'] ?? 0,
        departmentId: json['department_id'] ?? 0,
        levelId: json['level_id'] ?? 0,
        startDate: json['start_date'] ?? '',
        createdAt: json['created_at'] ?? '',
        updatedAt: json['updated_at'] ?? '',
        twoFactorEnabled: json['two_factor_enabled'] ?? false,
        role: json['role'] is String
            ? json['role']
            : (json['role'] is Map
                ? json['role']['name']?.toString()
                : (json['role_name'] ?? json['designation'])?.toString()));
  }
}
