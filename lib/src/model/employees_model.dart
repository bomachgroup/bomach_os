import 'package:intl/intl.dart';

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
  final String? gender;
  final String? maritalStatus;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? address;
  final String? profilePicture;
  
  // Status
  final bool isVerified;
  final bool isActive;
  
  // Work Info
  final String? employmentType;
  final int? branchId;
  final String? branchName; // From API
  final int? departmentId;
  final String? departmentName; // From API
  final int? levelId;
  final String? employeeLevel; // From API (e.g., "head", "ceo")
  final DateTime? startDate;
  
  // Compensation
  final double? grossSalary;
  final Map<String, dynamic>? allowances;

  // Metadata
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // --- UI ONLY Fields (Not in API response yet) ---
  // These are needed for the Add Employee form logic
  final String? middleName;
  final String? nationality;
  final String? otherPhoneNumber;
  final String? personalEmail;
  final String? streetAddress;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? country;
  final String? emergencyContactName;
  final String? emergencyContactRelationship;
  final String? emergencyContactPhone;
  final String? designation;
  final String? probationPeriod;
  final String? workSchedule;
  final String? paymentFrequency;
  final String? bankName;
  final String? accountNumber;
  final String? taxId;
  final String? pensionNumber;

  // Helper: Role Display Priority
  String get role => employeeLevel ?? designation ?? 'Staff';
  String get fullName => '$firstName $lastName';

  Employee({
    required this.id,
    this.tableId,
    this.employeeId,
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
    this.isVerified = false,
    this.isActive = true,
    this.employmentType,
    this.branchId,
    this.branchName,
    this.departmentId,
    this.departmentName,
    this.levelId,
    this.employeeLevel,
    this.startDate,
    this.grossSalary,
    this.allowances,
    this.createdAt,
    this.updatedAt,
    
    // UI fields
    this.middleName,
    this.nationality,
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
    this.probationPeriod,
    this.workSchedule,
    this.paymentFrequency,
    this.bankName,
    this.accountNumber,
    this.taxId,
    this.pensionNumber,
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
      gender: json['gender'],
      maritalStatus: json['marital_status'],
      
      // Phone can be null in JSON
      phoneNumber: json['phone_number'], 
      
      // Date Parsing
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'])
          : null,
          
      address: json['address'],
      profilePicture: json['profile_picture'],
      isVerified: json['is_verified'] ?? false,
      isActive: json['is_active'] ?? true,
      
      employmentType: json['employment_type'],
      
      // Branch/Dept (Handle nulls safely)
      branchId: json['branch_id'] is String ? int.tryParse(json['branch_id']) : json['branch_id'],
      branchName: json['branch_name'],
      
      departmentId: json['department_id'] is String ? int.tryParse(json['department_id']) : json['department_id'],
      departmentName: json['department_name'],
      
      levelId: json['level_id'] is String ? int.tryParse(json['level_id']) : json['level_id'],
      employeeLevel: json['employee_level'], // e.g. "head", "ceo"
      
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'])
          : null,
      
      // Handle null gross_salary
      grossSalary: json['gross_salary'] != null 
          ? (json['gross_salary'] is num ? (json['gross_salary'] as num).toDouble() : double.tryParse(json['gross_salary'].toString())) 
          : 0.0,
      
      allowances: json['allowances'] is Map<String, dynamic> ? json['allowances'] : {},
      
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,

      // Initialize UI-only fields to null (since API doesn't send them yet)
      middleName: null,
      nationality: null,
      otherPhoneNumber: null,
      personalEmail: null,
      streetAddress: null,
      city: null,
      state: null,
      zipCode: null,
      country: null,
      emergencyContactName: null,
      emergencyContactRelationship: null,
      emergencyContactPhone: null,
      designation: null,
      probationPeriod: null,
      workSchedule: null,
      paymentFrequency: null,
      bankName: null,
      accountNumber: null,
      taxId: null,
      pensionNumber: null,
    );
  }

  // Strictly maps to what the CREATE/UPDATE API expects
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'gender': gender ?? 'male',
      'marital_status': maritalStatus ?? 'single',
      'phone_number': phoneNumber ?? '',
      'date_of_birth': dateOfBirth?.toIso8601String().split('T').first ?? DateFormat('yyyy-MM-dd').format(DateTime.now()),
      'address': address ?? '',
      'profile_picture': profilePicture ?? "string",
      'employment_type': employmentType ?? 'full-time',
      'branch_id': branchId ?? 0,
      'department_id': departmentId ?? 0,
      'level_id': levelId ?? 0,
      'start_date': startDate?.toIso8601String().split('T').first ?? DateFormat('yyyy-MM-dd').format(DateTime.now()),
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