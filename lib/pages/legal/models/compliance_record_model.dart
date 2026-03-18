class ComplianceRecord {
  final int id;
  final String fullName;
  final String emailAddress;
  final String phoneNumber;
  final int departmentId;
  final String complianceType;
  final String? referenceNumber;
  final String dateOfIssue;
  final String expiryDate;
  final String issuingAuthority;
  final String status;
  final String? description;
  final String? contactPerson;
  final String? contactEmail;
  final String? cost;
  final String? priorityLevel;
  final bool isExpired;
  final int daysUntilExpiry;
  final String createdAt;
  final String updatedAt;
  final List<String> documents;

  ComplianceRecord({
    required this.id,
    required this.fullName,
    required this.emailAddress,
    required this.phoneNumber,
    required this.departmentId,
    required this.complianceType,
    this.referenceNumber,
    required this.dateOfIssue,
    required this.expiryDate,
    required this.issuingAuthority,
    required this.status,
    this.description,
    this.contactPerson,
    this.contactEmail,
    this.cost,
    this.priorityLevel,
    required this.isExpired,
    required this.daysUntilExpiry,
    required this.createdAt,
    required this.updatedAt,
    required this.documents,
  });

  factory ComplianceRecord.fromJson(Map<String, dynamic> json) {
    return ComplianceRecord(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? '',
      emailAddress: json['email_address'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      departmentId: json['department_id'] ?? 0,
      complianceType: json['compliance_type'] ?? '',
      referenceNumber: json['reference_number'],
      dateOfIssue: json['date_of_issue'] ?? '',
      expiryDate: json['expiry_date'] ?? '',
      issuingAuthority: json['issuing_authority'] ?? '',
      status: json['status'] ?? '',
      description: json['description'],
      contactPerson: json['contact_person'],
      contactEmail: json['contact_email'],
      cost: json['cost']?.toString(),
      priorityLevel: json['priority_level'],
      isExpired: json['is_expired'] ?? false,
      daysUntilExpiry: json['days_until_expiry'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      documents: json['documents'] != null
          ? List<String>.from(json['documents'])
          : [],
    );
  }

  Map<String, dynamic> toCreateJson() {
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

  Map<String, dynamic> toUpdateJson() {
    return {
      'full_name': fullName,
      'email_address': emailAddress,
      'phone_number': phoneNumber,
      'department_id': departmentId,
      'compliance_type': complianceType,
      'reference_number': referenceNumber,
      'issuing_authority': issuingAuthority,
      'status': status,
      'contact_person': contactPerson,
      'contact_email': contactEmail,
      'cost': cost,
      'priority_level': priorityLevel,
      'documents': documents,
    };
  }
}
