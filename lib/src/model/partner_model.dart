class Partner {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String category;
  final String categoryDisplay;
  final String status;
  final String statusDisplay;
  final String notes;
  final int agreementCount;
  final String createdAt;
  final String updatedAt;

  Partner({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.category,
    required this.categoryDisplay,
    required this.status,
    required this.statusDisplay,
    required this.notes,
    required this.agreementCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Partner.fromJson(Map<String, dynamic> json) {
    return Partner(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      category: json['category'] ?? '',
      categoryDisplay: json['category_display'] ?? '',
      status: json['status'] ?? '',
      statusDisplay: json['status_display'] ?? '',
      notes: json['notes'] ?? '',
      agreementCount: json['agreement_count'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class PartnerAgreement {
  final int id;
  final int partnerId;
  final String title;
  final String document;
  final String? documentName;
  final String? documentSize;
  final String date;
  final String createdAt;
  final String updatedAt;

  PartnerAgreement({
    required this.id,
    required this.partnerId,
    required this.title,
    required this.document,
    this.documentName,
    this.documentSize,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PartnerAgreement.fromJson(Map<String, dynamic> json) {
    return PartnerAgreement(
      id: json['id'] ?? 0,
      partnerId: json['partner_id'] ?? 0,
      title: json['title'] ?? '',
      document: json['document'] ?? '',
      documentName: json['document_name'],
      documentSize: json['document_size'],
      date: json['date'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}
