// src/model/company_model.dart

class CompanySettings {
  final String id;
  final String companyName;
  final String companyEmail;
  final String companyPhone;
  final String companyAddresses;
  final String rcNumber;
  final String primaryColorCode;
  final String secondaryColorCode;
  final String companySlogan;
  final String defaultCurrency;
  final String languagePreference;
  final String businessRules;
  final String? companyLogo;
  final String createdAt;
  final String? updatedAt;

  CompanySettings({
    required this.id,
    required this.companyName,
    required this.companyEmail,
    required this.companyPhone,
    required this.companyAddresses,
    required this.rcNumber,
    required this.primaryColorCode,
    required this.secondaryColorCode,
    required this.companySlogan,
    required this.defaultCurrency,
    required this.languagePreference,
    required this.businessRules,
    this.companyLogo,
    required this.createdAt,
    this.updatedAt,
  });

  factory CompanySettings.fromJson(Map<String, dynamic> json) {
    return CompanySettings(
      id: json['id']?.toString() ?? '',
      companyName: json['company_name'] ?? '',
      companyEmail: json['company_email'] ?? '',
      companyPhone: json['company_phone'] ?? '',
      companyAddresses: json['company_addresses'] ?? '',
      rcNumber: json['rc_number'] ?? '',
      primaryColorCode: json['primary_color_code'] ?? '',
      secondaryColorCode: json['secondary_color_code'] ?? '',
      companySlogan: json['company_slogan'] ?? '',
      defaultCurrency: json['default_currency'] ?? '',
      languagePreference: json['language_preference'] ?? '',
      businessRules: json['business_rules'] ?? '',
      companyLogo: json['company_logo'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'company_name': companyName,
      'company_email': companyEmail,
      'company_phone': companyPhone,
      'company_addresses': companyAddresses,
      'company_slogan': companySlogan,
      'primary_color_code': primaryColorCode,
      'secondary_color_code': secondaryColorCode,
      'default_currency': defaultCurrency,
      'language_preference': languagePreference,
      'business_rules': businessRules,
    };
  }
}

class Compliance {
  final String id;
  final String type; // e.g., "Tax", "CAC"
  final String registrationItem;
  final String number;
  final String dateRegistered;
  final String expirationDate;
  final String status; // "active", "expired", "pending"
  final String? documentUrl;

  Compliance({
    required this.id,
    required this.type,
    required this.registrationItem,
    required this.number,
    required this.dateRegistered,
    required this.expirationDate,
    required this.status,
    this.documentUrl,
  });

  factory Compliance.fromJson(Map<String, dynamic> json) {
    return Compliance(
      id: json['id']?.toString() ?? '',
      type: json['compliance_type'] ?? '', // Adjusted to match likely API key
      registrationItem: json['registration_item'] ?? '',
      number: json['number'] ?? '',
      dateRegistered: json['date_registered'] ?? '',
      expirationDate: json['expiration_date'] ?? '',
      status: json['status'] ?? 'pending',
      documentUrl: json['document_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'compliance_type': type,
      'registration_item': registrationItem,
      'number': number,
      'date_registered': dateRegistered,
      'expiration_date': expirationDate,
      'status': status,
    };
  }
}

class Shareholder {
  final int id;
  final String shareholderId;
  final int? userId;
  final int? employeeId;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String? profilePicture;
  final String title;
  final String titleDisplay;
  final String sharePercentage;
  final int shareCount;
  final bool isBoardMember;
  final bool isActive;
  final String? notes;
  final String createdAt;
  final String updatedAt;

  Shareholder({
    required this.id,
    required this.shareholderId,
    this.userId,
    this.employeeId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    this.profilePicture,
    required this.title,
    required this.titleDisplay,
    required this.sharePercentage,
    required this.shareCount,
    required this.isBoardMember,
    required this.isActive,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  factory Shareholder.fromJson(Map<String, dynamic> json) {
    return Shareholder(
      id: json['id'] ?? 0,
      shareholderId: json['shareholder_id'] ?? '',
      userId: json['user_id'],
      employeeId: json['employee_id'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      profilePicture: json['profile_picture'],
      title: json['title'] ?? '',
      titleDisplay: json['title_display'] ?? '',
      sharePercentage: json['share_percentage'] ?? '0.00',
      shareCount: json['share_count'] ?? 0,
      isBoardMember: json['is_board_member'] ?? false,
      isActive: json['is_active'] ?? true,
      notes: json['notes'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class DashboardStats {
  final int totalEmployees;
  final int newEmployeesCount;
  final int totalBranches;
  final int removedBranchesCount;
  final int pendingApprovals;
  final int overdueTasksCount;
  final int assetInventory;
  final int newInventoryCount;

  DashboardStats({
    required this.totalEmployees,
    required this.newEmployeesCount,
    required this.totalBranches,
    required this.removedBranchesCount,
    required this.pendingApprovals,
    required this.overdueTasksCount,
    required this.assetInventory,
    required this.newInventoryCount,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalEmployees: json['total_employees'] ?? 0,
      newEmployeesCount: json['new_employees_count'] ?? 0,
      totalBranches: json['total_branches'] ?? 0,
      removedBranchesCount: json['removed_branches_count'] ?? 0,
      pendingApprovals: json['pending_approvals'] ?? 0,
      overdueTasksCount: json['overdue_tasks_count'] ?? 0,
      assetInventory: json['asset_inventory'] ?? 0,
      newInventoryCount: json['new_inventory_count'] ?? 0,
    );
  }
}

class AuditLog {
  final int id;
  final String activity;
  final String auditType;
  final String auditTypeDisplay;
  final String auditStatus;
  final String auditStatusDisplay;
  final String ipAddress;
  final String userEmail;
  final String userFullName;
  final String createdAt;

  AuditLog({
    required this.id,
    required this.activity,
    required this.auditType,
    required this.auditTypeDisplay,
    required this.auditStatus,
    required this.auditStatusDisplay,
    required this.ipAddress,
    required this.userEmail,
    required this.userFullName,
    required this.createdAt,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    return AuditLog(
      id: json['id'] ?? 0,
      activity: json['activity'] ?? '',
      auditType: json['audit_type'] ?? '',
      auditTypeDisplay: json['audit_type_display'] ?? '',
      auditStatus: json['audit_status'] ?? '',
      auditStatusDisplay: json['audit_status_display'] ?? '',
      ipAddress: json['ip_address'] ?? '',
      userEmail: user['email'] ?? '',
      userFullName: user['full_name'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}