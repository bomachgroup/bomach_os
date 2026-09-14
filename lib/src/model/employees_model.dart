import 'package:intl/intl.dart';

/// Statuses the backend actively writes (suspend action sets
/// 'employment_status': 'suspended').
const List<String> knownEmploymentStatusOptions = [
  'active',
  'inactive',
  'suspended',
];

/// Audit B6 fix: seed the Edit-Employee status dropdown from the model's
/// REAL employment status instead of collapsing everything through the
/// boolean [isActive]. Unknown/legacy values (e.g. 'on_leave') pass
/// through so a save round-trip can never silently rewrite them.
String resolveEmploymentStatus(String? employmentStatus, bool isActive) {
  if (employmentStatus != null && employmentStatus.trim().isNotEmpty) {
    return employmentStatus.trim().toLowerCase();
  }
  return isActive ? 'active' : 'inactive';
}

/// Build the dropdown option list: known statuses plus the current value
/// when it isn't one of them (so unknown statuses survive editing).
List<String> buildStatusOptions({required String? currentValue}) {
  final options = List<String>.from(knownEmploymentStatusOptions);
  if (currentValue != null &&
      currentValue.isNotEmpty &&
      !options.contains(currentValue)) {
    options.add(currentValue);
  }
  return options;
}

class Employee {
  // Identifiers
  final String id; // Maps to user_id (e.g., 10)
  final String? tableId; // Maps to id (e.g., 3) - kept just in case
  final String? employeeId; // Maps to employee_id (e.g., "MEM-063...")

  // Personal Info
  final String email;
  final String? password; // UI Only (for creation)
  final String firstName;
  final String lastName;
  final String? middleName;
  final String? gender;
  final String? maritalStatus;
  final String? nationality;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? address;
  final String? profilePicture;

  // Status
  final bool isVerified;
  final bool isActive;

  // Contact
  final String? otherPhoneNumber;
  final String? personalEmail;
  final String? streetAddress;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? country;

  // Emergency Contact
  final String? emergencyContactName;
  final String? emergencyContactRelationship;
  final String? emergencyContactPhone;

  // Work Info
  final String? designation;
  final String? employmentType;
  final String? employmentStatus;
  final int? branchId;
  final String? branchName;
  final int? departmentId;
  final String? departmentName;
  final int? departmentUnitId;
  final String? departmentUnitName;
  final int? levelId;
  final String? employeeLevel; // From API (e.g., "head", "ceo")
  final int? roleId;
  final String? roleName;
  final String? location;
  final int? reportingToId;
  final String? reportingToName;
  final DateTime? startDate;
  final String? probationPeriod;
  final String? workSchedule;

  // Compensation
  final double? grossSalary;
  final String? salaryFrequency;
  final Map<String, dynamic>? allowances;
  final String? bankName;
  final String? accountNumber;
  final String? taxId;
  final String? pensionNumber;
  final String? pfaProvider;
  final String? rsaNumber;
  final double? employerContribution;
  final String? hmoPlan;
  final String? hmoIdNumber;
  final int? hmoDependentsCovered;

  // Metadata
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Helper: Role Display Priority
  String get role {
    if (roleName != null && roleName!.trim().isNotEmpty) {
      return roleName!.trim();
    }
    if (employeeLevel != null && employeeLevel!.trim().isNotEmpty) {
      return employeeLevel!.trim();
    }
    return designation ?? 'Staff';
  }
  String get fullName => '$firstName $lastName';

  Employee({
    required this.id,
    this.tableId,
    this.employeeId,
    required this.email,
    this.password,
    required this.firstName,
    required this.lastName,
    this.middleName,
    this.gender,
    this.maritalStatus,
    this.nationality,
    this.phoneNumber,
    this.dateOfBirth,
    this.address,
    this.profilePicture,
    this.isVerified = false,
    this.isActive = true,
    this.otherPhoneNumber,
    this.personalEmail,
    this.streetAddress,
    this.city,
    this.state,
    this.zipCode,
    this.country,
    this.emergencyContactName,
    this.emergencyContactRelationship,
    this.emergencyContactPhone,
    this.designation,
    this.employmentType,
    this.employmentStatus,
    this.branchId,
    this.branchName,
    this.departmentId,
    this.departmentName,
    this.departmentUnitId,
    this.departmentUnitName,
    this.levelId,
    this.employeeLevel,
    this.roleId,
    this.roleName,
    this.location,
    this.reportingToId,
    this.reportingToName,
    this.startDate,
    this.probationPeriod,
    this.workSchedule,
    this.grossSalary,
    this.salaryFrequency,
    this.allowances,
    this.bankName,
    this.accountNumber,
    this.taxId,
    this.pensionNumber,
    this.pfaProvider,
    this.rsaNumber,
    this.employerContribution,
    this.hmoPlan,
    this.hmoIdNumber,
    this.hmoDependentsCovered,
    this.createdAt,
    this.updatedAt,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      // CRITICAL FIX: Map user_id to main id for app logic
      id: json['user_id']?.toString() ?? '',
      tableId: json['id']?.toString(),
      employeeId: json['employee_id']?.toString(),

      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      middleName: json['middle_name'],
      gender: json['gender'],
      maritalStatus: json['marital_status'],
      nationality: json['nationality'],

      phoneNumber: json['phone_number'],
      otherPhoneNumber: json['other_phone'],
      personalEmail: json['personal_email'],

      // Date Parsing
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'])
          : null,

      address: json['address'],
      profilePicture: json['profile_picture'],
      isVerified: json['is_verified'] ?? false,
      isActive: json['is_active'] ?? true,

      // Contact Address
      streetAddress: json['street_address'],
      city: json['city'],
      state: json['state'],
      zipCode: json['zip_code'],
      country: json['country'],

      // Emergency Contact
      emergencyContactName: json['emergency_contact_name'],
      emergencyContactRelationship: json['emergency_contact_relationship'],
      emergencyContactPhone: json['emergency_contact_phone'],

      // Work Info
      designation: json['designation'],
      employmentType: json['employment_type'],
      employmentStatus: json['employment_status'],

      // Branch/Dept (Handle nulls safely)
      branchId: json['branch_id'] is String
          ? int.tryParse(json['branch_id'])
          : json['branch_id'],
      branchName: json['branch_name'],

      departmentId: json['department_id'] is String
          ? int.tryParse(json['department_id'])
          : json['department_id'],
      departmentName: json['department_name'],

      departmentUnitId: json['department_unit_id'] is String
          ? int.tryParse(json['department_unit_id'])
          : json['department_unit_id'],
      departmentUnitName: json['department_unit_name'],

      levelId: json['level_id'] is String
          ? int.tryParse(json['level_id'])
          : json['level_id'],
      employeeLevel: json['employee_level'],
      roleId: json['role_id'] is String
          ? int.tryParse(json['role_id'])
          : json['role_id'],
      roleName: json['role_name']?.toString() ??
          (json['role'] is String
              ? json['role']?.toString()
              : (json['role'] is Map
                  ? json['role']['name']?.toString()
                  : null)) ??
          json['role_title']?.toString(),

      location: json['location'],
      reportingToId: json['reporting_to_id'] is String
          ? int.tryParse(json['reporting_to_id'])
          : json['reporting_to_id'],
      reportingToName: json['reporting_to_name'],

      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'])
          : null,
      probationPeriod: json['probation_period']?.toString(),
      workSchedule: json['work_schedule'],

      // Compensation
      grossSalary: json['gross_salary'] != null
          ? (json['gross_salary'] is num
              ? (json['gross_salary'] as num).toDouble()
              : double.tryParse(json['gross_salary'].toString()))
          : 0.0,
      salaryFrequency: json['salary_frequency'],
      allowances:
          json['allowances'] is Map<String, dynamic> ? json['allowances'] : {},
      bankName: json['bank_name'],
      accountNumber: json['account_number'],
      taxId: json['tax_id'],
      pensionNumber: json['pension_number'],
      pfaProvider: json['pfa_provider'],
      rsaNumber: json['rsa_number'],
      employerContribution: json['employer_contribution'] != null
          ? (json['employer_contribution'] is num
              ? (json['employer_contribution'] as num).toDouble()
              : double.tryParse(json['employer_contribution'].toString()))
          : null,
      hmoPlan: json['hmo_current_plan'],
      hmoIdNumber: json['hmo_id_number'],
      hmoDependentsCovered: json['hmo_dependents_covered'] is String
          ? int.tryParse(json['hmo_dependents_covered'])
          : json['hmo_dependents_covered'],

      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  // Strictly maps to what the CREATE/UPDATE API expects
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'middle_name': middleName ?? '',
      'gender': gender ?? 'male',
      'marital_status': maritalStatus ?? 'single',
      'nationality': nationality ?? 'Nigerian',
      'date_of_birth': dateOfBirth?.toIso8601String().split('T').first ??
          DateFormat('yyyy-MM-dd').format(DateTime.now()),
      'profile_picture': (profilePicture != null && profilePicture != 'string')
          ? profilePicture
          : '',
      'phone_number': phoneNumber ?? '',
      'other_phone': otherPhoneNumber ?? '',
      'personal_email': personalEmail ?? '',
      'address': address ?? '',
      'city': city ?? '',
      'state': state ?? '',
      'zip_code': zipCode ?? '',
      'country': country ?? '',
      'emergency_contact_name': emergencyContactName ?? '',
      'emergency_contact_relationship': emergencyContactRelationship ?? '',
      'emergency_contact_phone': emergencyContactPhone ?? '',
      'designation': designation ?? '',
      'employment_type': employmentType ?? 'full-time',
      'employment_status': employmentStatus ?? 'active',
      'branch_id': branchId ?? 0,
      'department_id': departmentId ?? 0,
      'department_unit_id': departmentUnitId ?? 0,
      'level_id': levelId ?? 0,
      'location': location ?? '',
      'reporting_to_id': reportingToId ?? 0,
      'start_date': startDate?.toIso8601String().split('T').first ??
          DateFormat('yyyy-MM-dd').format(DateTime.now()),
      'probation_period': int.tryParse(probationPeriod ?? '0') ?? 0,
      'work_schedule': workSchedule ?? '',
      'is_active': isActive,
      'gross_salary': grossSalary ?? 0,
      'salary_frequency': salaryFrequency ?? 'monthly',
      'allowances': allowances ?? {},
      'bank_name': bankName ?? '',
      'account_number': accountNumber ?? '',
      'tax_id': taxId ?? '',
      'pension_number': pensionNumber ?? '',
      'pfa_provider': pfaProvider ?? '',
      'rsa_number': rsaNumber ?? '',
      'employer_contribution': employerContribution ?? 0,
      'hmo_current_plan': hmoPlan ?? '',
      'hmo_id_number': hmoIdNumber ?? '',
      'hmo_dependents_covered': hmoDependentsCovered ?? 0,
    };

    if (password != null && password!.isNotEmpty) {
      data['password'] = password;
    }

    return data;
  }
}
