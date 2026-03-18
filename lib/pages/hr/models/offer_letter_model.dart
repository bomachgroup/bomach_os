class OfferLetter {
  final int? id;
  final int applicantId;
  final String template;
  final String annualSalary;
  final String startDate;
  final String letterContent;
  final String status;
  final String? sentAt;
  final String? createdAt;
  final String? updatedAt;

  OfferLetter({
    this.id,
    required this.applicantId,
    required this.template,
    required this.annualSalary,
    required this.startDate,
    required this.letterContent,
    this.status = 'draft',
    this.sentAt,
    this.createdAt,
    this.updatedAt,
  });

  factory OfferLetter.fromJson(Map<String, dynamic> json) {
    return OfferLetter(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      applicantId: json['applicant_id'] is int
          ? json['applicant_id']
          : int.tryParse(json['applicant_id']?.toString() ?? '') ?? 0,
      template: json['template']?.toString() ?? '',
      annualSalary: json['annual_salary']?.toString() ?? '0',
      startDate: json['start_date']?.toString() ?? '',
      letterContent: json['letter_content']?.toString() ?? '',
      status: json['status']?.toString() ?? 'draft',
      sentAt: json['sent_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  /// JSON for creating a new offer letter.
  Map<String, dynamic> toCreateJson() {
    return {
      'template': template,
      'annual_salary': annualSalary,
      'start_date': startDate,
      'letter_content': letterContent,
    };
  }

  /// JSON for updating an offer letter.
  Map<String, dynamic> toUpdateJson() {
    return {
      if (template.isNotEmpty) 'template': template,
      if (annualSalary.isNotEmpty) 'annual_salary': annualSalary,
      if (startDate.isNotEmpty) 'start_date': startDate,
      if (letterContent.isNotEmpty) 'letter_content': letterContent,
    };
  }
}
