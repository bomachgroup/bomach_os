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
  final String id;
  final String action;
  final String description;
  final String ipAddress;
  final String userAgent;
  final String createdAt;
  final String userEmail; // Assuming API returns user info

  AuditLog({
    required this.id,
    required this.action,
    required this.description,
    required this.ipAddress,
    required this.userAgent,
    required this.createdAt,
    required this.userEmail,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      id: json['id']?.toString() ?? '',
      action: json['action'] ?? 'Unknown Action',
      description: json['description'] ?? '',
      ipAddress: json['ip_address'] ?? '',
      userAgent: json['user_agent'] ?? '',
      createdAt: json['created_at'] ?? '',
      userEmail: json['user_email'] ?? 'System',
    );
  }
}