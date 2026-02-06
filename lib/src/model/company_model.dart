class CompanySettings {
  final int id;
  final String companyName;
  final String companyEmail;
  final String companyPhone;
  final String companyAddresses;
  final String? companyLogo; 
  final String rcNumber;
  final String primaryColorCode;
  final String secondaryColorCode;
  final String companySlogan;
  final String defaultCurrency;
  final String languagePreference;
  final String businessRules;
  final String createdAt;
  final String updatedAt;

  CompanySettings({
    required this.id,
    required this.companyName,
    required this.companyEmail,
    required this.companyPhone,
    required this.companyAddresses,
    this.companyLogo,
    required this.rcNumber,
    required this.primaryColorCode,
    required this.secondaryColorCode,
    required this.companySlogan,
    required this.defaultCurrency,
    required this.languagePreference,
    required this.businessRules,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CompanySettings.fromJson(Map<String, dynamic> json) {
    return CompanySettings(
      id: json['id'] ?? 0,
      companyName: json['company_name'] ?? '',
      companyEmail: json['company_email'] ?? '',
      companyPhone: json['company_phone'] ?? '',
      companyAddresses: json['company_addresses'] ?? '',
      companyLogo: json['company_logo'],
      rcNumber: json['rc_number'] ?? '',
      primaryColorCode: json['primary_color_code'] ?? '',
      secondaryColorCode: json['secondary_color_code'] ?? '',
      companySlogan: json['company_slogan'] ?? '',
      defaultCurrency: json['default_currency'] ?? '',
      languagePreference: json['language_preference'] ?? '',
      businessRules: json['business_rules'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'company_name': companyName,
      'company_email': companyEmail,
      'company_phone': companyPhone,
      'company_addresses': companyAddresses,
      'company_logo': companyLogo,
      'rc_number': rcNumber,
      'primary_color_code': primaryColorCode,
      'secondary_color_code': secondaryColorCode,
      'company_slogan': companySlogan,
      'default_currency': defaultCurrency,
      'language_preference': languagePreference,
      'business_rules': businessRules,
    };
  }
}