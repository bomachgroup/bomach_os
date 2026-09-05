// src/model/company_model.dart

/// Flat view model that merges the three backend resources the Company
/// module edits: profile (name/email/phone/address/rc), branding (logo,
/// colors, slogan) and preferences (currency, language, business rules).
///
/// The backend stopped storing country/state/city and date_of_registration
/// on the company profile — source those from a client-side picker if the
/// UI needs them, or plumb them through a custom field.
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

  factory CompanySettings.merge({
    required Map<String, dynamic> profile,
    required Map<String, dynamic> branding,
    required Map<String, dynamic> preferences,
  }) {
    return CompanySettings(
      id: profile['id']?.toString() ?? '',
      companyName: profile['company_name'] ?? '',
      companyEmail: profile['company_email'] ?? '',
      companyPhone: profile['company_phone'] ?? '',
      companyAddresses: profile['company_addresses'] ?? '',
      rcNumber: profile['rc_number'] ?? '',
      primaryColorCode: branding['primary_color_code'] ?? '',
      secondaryColorCode: branding['secondary_color_code'] ?? '',
      companySlogan: branding['company_slogan'] ?? '',
      companyLogo: branding['company_logo'],
      defaultCurrency: preferences['default_currency'] ?? '',
      languagePreference: preferences['language_preference'] ?? '',
      businessRules: preferences['business_rules'] ?? '',
      createdAt: profile['created_at'] ?? '',
      updatedAt: profile['updated_at'],
    );
  }

  Map<String, dynamic> toProfileUpdateJson() => {
        'company_name': companyName,
        'company_email': companyEmail,
        'company_phone': companyPhone,
        'company_addresses': companyAddresses,
        'rc_number': rcNumber,
      };

  Map<String, dynamic> toBrandingUpdateJson() => {
        if (companyLogo != null) 'company_logo': companyLogo,
        'primary_color_code': primaryColorCode,
        'secondary_color_code': secondaryColorCode,
        'company_slogan': companySlogan,
      };

  Map<String, dynamic> toPreferencesUpdateJson() => {
        'default_currency': defaultCurrency,
        'language_preference': languagePreference,
        'business_rules': businessRules,
      };
}

class Compliance {
  final String id;
  final String fullName;
  final String emailAddress;
  final String phoneNumber;
  final String departmentId;
  final String complianceType;
  final String referenceNumber;
  final String dateOfIssue;
  final String expiryDate;
  final String issuingAuthority;
  final String status;
  final String description;
  final String contactPerson;
  final String contactEmail;
  final num cost;
  final String priorityLevel;
  final List<String> documents;

  Compliance({
    required this.id,
    this.fullName = '',
    this.emailAddress = '',
    this.phoneNumber = '',
    this.departmentId = '',
    required this.complianceType,
    this.referenceNumber = '',
    required this.dateOfIssue,
    required this.expiryDate,
    this.issuingAuthority = '',
    required this.status,
    this.description = '',
    this.contactPerson = '',
    this.contactEmail = '',
    this.cost = 0,
    this.priorityLevel = 'medium',
    this.documents = const [],
  });

  factory Compliance.fromJson(Map<String, dynamic> json) {
    return Compliance(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name'] ?? '',
      emailAddress: json['email_address'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      departmentId: json['department_id']?.toString() ?? '',
      complianceType: json['compliance_type'] ?? '',
      referenceNumber: json['reference_number'] ?? '',
      dateOfIssue: json['date_of_issue'] ?? '',
      expiryDate: json['expiry_date'] ?? '',
      issuingAuthority: json['issuing_authority'] ?? '',
      status: json['status'] ?? 'pending',
      description: json['description'] ?? '',
      contactPerson: json['contact_person'] ?? '',
      contactEmail: json['contact_email'] ?? '',
      cost: num.tryParse(json['cost']?.toString() ?? '') ?? 0,
      priorityLevel: json['priority_level'] ?? 'medium',
      documents: (json['documents'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'email_address': emailAddress,
      'phone_number': phoneNumber,
      'department_id': departmentId,
      'compliance_type': complianceType,
      'reference_number': referenceNumber,
      'date_of_issue': dateOfIssue,
      'expiry_date': expiryDate,
      'issuing_authority': issuingAuthority,
      'status': status,
      'description': description,
      'contact_person': contactPerson,
      'contact_email': contactEmail,
      'cost': cost,
      'priority_level': priorityLevel,
      'documents': documents,
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

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone_number': phoneNumber,
      'title': title,
      'share_percentage': sharePercentage,
      'share_count': shareCount,
      'is_board_member': isBoardMember,
      'is_active': isActive,
      if (notes != null) 'notes': notes,
    };
  }
}

class EquityInfo {
  final int authorizedShares;
  final int issuedShares;
  final int unissuedShares;

  EquityInfo({
    required this.authorizedShares,
    required this.issuedShares,
    required this.unissuedShares,
  });

  factory EquityInfo.fromJson(Map<String, dynamic> json) {
    return EquityInfo(
      authorizedShares:
          int.tryParse(json['authorized_shares']?.toString() ?? '') ?? 0,
      issuedShares: int.tryParse(json['issued_shares']?.toString() ?? '') ?? 0,
      unissuedShares:
          int.tryParse(json['unissued_shares']?.toString() ?? '') ?? 0,
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
  final int? userId;
  final String activity;
  final String auditType;
  final String auditTypeDisplay;
  final String auditStatus;
  final String auditStatusDisplay;
  final String ipAddress;
  final String userEmail;
  final String userFullName;
  final String createdAt;
  final Map<String, dynamic>? metadata;

  AuditLog({
    required this.id,
    this.userId,
    required this.activity,
    required this.auditType,
    required this.auditTypeDisplay,
    required this.auditStatus,
    required this.auditStatusDisplay,
    required this.ipAddress,
    required this.userEmail,
    required this.userFullName,
    required this.createdAt,
    this.metadata,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    return AuditLog(
      id: json['id'] ?? 0,
      userId: user['id'] is int ? user['id'] as int : null,
      activity: json['activity'] ?? '',
      auditType: json['audit_type'] ?? '',
      auditTypeDisplay: json['audit_type_display'] ?? '',
      auditStatus: json['audit_status'] ?? '',
      auditStatusDisplay: json['audit_status_display'] ?? '',
      ipAddress: json['ip_address'] ?? '',
      userEmail: user['email'] ?? '',
      userFullName: user['full_name'] ?? '',
      createdAt: json['created_at'] ?? '',
      metadata: json['metadata'] is Map
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
    );
  }
}

class CompanyFieldOption {
  final String value;
  final String label;

  CompanyFieldOption({required this.value, required this.label});

  factory CompanyFieldOption.fromJson(Map<String, dynamic> json) {
    return CompanyFieldOption(
      value: json['value'] ?? '',
      label: json['label'] ?? '',
    );
  }
}

class CompanyFieldChoices {
  final List<CompanyFieldOption> currencies;
  final List<CompanyFieldOption> languages;

  CompanyFieldChoices({
    required this.currencies,
    required this.languages,
  });

  factory CompanyFieldChoices.fromJson(Map<String, dynamic> json) {
    return CompanyFieldChoices(
      currencies: (json['currencies'] as List?)
              ?.map((e) => CompanyFieldOption.fromJson(e))
              .toList() ??
          [],
      languages: (json['languages'] as List?)
              ?.map((e) => CompanyFieldOption.fromJson(e))
              .toList() ??
          [],
    );
  }
}
