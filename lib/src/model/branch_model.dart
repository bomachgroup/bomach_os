class Branch {
  final int id;
  final String branchName;
  final String branchId; 
  final int countryId;
  final String countryName;
  final int stateId;
  final String stateName;
  final String lga;
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
  final bool isActive;
  final bool isOperational;
  final String notes;
  final String createdAt;
  final String updatedAt;

  Branch({
    required this.id,
    required this.branchName,
    required this.branchId,
    required this.countryId,
    required this.countryName,
    required this.stateId,
    required this.stateName,
    required this.lga,
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
      countryId: json['country_id'] ?? 0,
      countryName: json['country_name'] ?? '',
      stateId: json['state_id'] ?? 0,
      stateName: json['state_name'] ?? '',
      lga: json['lga'] ?? '',
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
      'country_id': countryId,
      'state_id': stateId,
      'lga': lga,
      'office_address': officeAddress,
      'operational_status': operationalStatus,
      'branch_role': branchRole,
      'contact_email': contactEmail,
      'contact_phone': contactPhone,
      'manager_id': managerId,
      'is_active': isActive,
      'notes': notes,
    };
  }
}

class Country { 
  final int id;
  final String name;
  final String code;
  final bool isActive;

  Country({required this.id, required this.name, required this.code, required this.isActive});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      isActive: json['is_active'] ?? false,
    );
  }
}

class StateModel { 
  final int id;
  final int countryId;
  final String name;
  final String code;

  StateModel({required this.id, required this.countryId, required this.name, required this.code});

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      id: json['id'] ?? 0,
      countryId: json['country_id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
    );
  }
}

class BranchFieldChoices { 
  final List<FieldOption> operationalStatus;
  final List<FieldOption> branchRole;

  BranchFieldChoices({required this.operationalStatus, required this.branchRole});

  factory BranchFieldChoices.fromJson(Map<String, dynamic> json) {
    return BranchFieldChoices(
      operationalStatus: (json['operational_status'] as List?)
              ?.map((e) => FieldOption.fromJson(e))
              .toList() ?? [],
      branchRole: (json['branch_role'] as List?)
              ?.map((e) => FieldOption.fromJson(e))
              .toList() ?? [],
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
      revenueTrend: List<Map<String, dynamic>>.from(json['revenue_trend'] ?? []),
      branchDetails: json['branch_details'] ?? {},
    );
  }
}