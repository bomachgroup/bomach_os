/// Branch as persisted by the backend after the country/state migration:
/// country/state are now free-text names (with ISO codes supplied by a
/// client-side picker), and `city` replaces the old LGA field. Branches also
/// carry their own `default_currency` and `language_preference` strings so
/// each branch can override the company-wide settings.
class Branch {
  final int id;
  final String branchName;
  final String branchId;
  final String country;
  final String countryCode;
  final String state;
  final String stateCode;
  final String city;
  final String officeAddress;
  final String fullAddress;
  final String operationalStatus;
  final String operationalStatusDisplay;
  final String branchRole;
  final String branchRoleDisplay;
  final String contactEmail;
  final String contactPhone;
  final int managerId;
  final String managerName;
  final String? branchFile;
  final String defaultCurrency;
  final String languagePreference;
  final bool isActive;
  final bool isOperational;
  final String notes;
  final String createdAt;
  final String updatedAt;

  Branch({
    required this.id,
    required this.branchName,
    required this.branchId,
    required this.country,
    required this.countryCode,
    required this.state,
    required this.stateCode,
    required this.city,
    required this.officeAddress,
    required this.fullAddress,
    required this.operationalStatus,
    required this.operationalStatusDisplay,
    required this.branchRole,
    required this.branchRoleDisplay,
    required this.contactEmail,
    required this.contactPhone,
    required this.managerId,
    required this.managerName,
    this.branchFile,
    required this.defaultCurrency,
    required this.languagePreference,
    required this.isActive,
    required this.isOperational,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'] ?? 0,
      branchName: json['branch_name'] ?? '',
      branchId: json['branch_id'] ?? '',
      country: json['country'] ?? '',
      countryCode: json['country_code'] ?? '',
      state: json['state'] ?? '',
      stateCode: json['state_code'] ?? '',
      city: json['city'] ?? '',
      officeAddress: json['office_address'] ?? '',
      fullAddress: json['full_address'] ?? '',
      operationalStatus: json['operational_status'] ?? '',
      operationalStatusDisplay: json['operational_status_display'] ?? '',
      branchRole: json['branch_role'] ?? '',
      branchRoleDisplay: json['branch_role_display'] ?? '',
      contactEmail: json['contact_email'] ?? '',
      contactPhone: json['contact_phone'] ?? '',
      managerId: json['manager_id'] ?? 0,
      managerName: json['manager_name'] ?? '',
      branchFile: json['branch_file'],
      defaultCurrency: json['default_currency'] ?? '',
      languagePreference: json['language_preference'] ?? '',
      isActive: json['is_active'] ?? false,
      isOperational: json['is_operational'] ?? false,
      notes: json['notes'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'branch_name': branchName,
      'country': country,
      'country_code': countryCode,
      'state': state,
      'state_code': stateCode,
      'city': city,
      'office_address': officeAddress,
      'operational_status': operationalStatus,
      'branch_role': branchRole,
      'contact_email': contactEmail,
      'contact_phone': contactPhone,
      'manager_id': managerId,
      'default_currency': defaultCurrency,
      'language_preference': languagePreference,
      'is_active': isActive,
      'notes': notes,
    };
  }
}

class BranchFieldChoices {
  final List<FieldOption> operationalStatus;
  final List<FieldOption> branchRole;

  BranchFieldChoices(
      {required this.operationalStatus, required this.branchRole});

  factory BranchFieldChoices.fromJson(Map<String, dynamic> json) {
    return BranchFieldChoices(
      operationalStatus: (json['operational_status'] as List?)
              ?.map((e) => FieldOption.fromJson(e))
              .toList() ??
          [],
      branchRole: (json['branch_role'] as List?)
              ?.map((e) => FieldOption.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class FieldOption {
  final String value;
  final String label;

  FieldOption({required this.value, required this.label});

  factory FieldOption.fromJson(Map<String, dynamic> json) {
    return FieldOption(
      value: json['value'] ?? '',
      label: json['label'] ?? '',
    );
  }
}

class BranchPerformance {
  final Map<String, dynamic> metrics;
  final List<Map<String, dynamic>> keyInsights;
  final List<Map<String, dynamic>> revenueTrend;
  final Map<String, dynamic> branchDetails;

  BranchPerformance({
    required this.metrics,
    required this.keyInsights,
    required this.revenueTrend,
    required this.branchDetails,
  });

  factory BranchPerformance.fromJson(Map<String, dynamic> json) {
    return BranchPerformance(
      metrics: json['metrics'] ?? {},
      keyInsights: List<Map<String, dynamic>>.from(json['key_insights'] ?? []),
      revenueTrend:
          List<Map<String, dynamic>>.from(json['revenue_trend'] ?? []),
      branchDetails: json['branch_details'] ?? {},
    );
  }
}
