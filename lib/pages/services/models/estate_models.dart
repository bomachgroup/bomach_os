class Estate {
  final int id;
  final bool isOurEstate;
  final double? legalFee;
  final double? developmentFee;
  final double? receiptFee;
  final String estateName;
  final String estateCode;
  final String estateType;
  final String estateTypeDisplay;
  final String developerCompanyName;
  final String estateDescription;
  final int countryId;
  final String countryName;
  final String state;
  final String cityTown;
  final String preciseAddress;
  final String estateStatus;
  final String estateStatusDisplay;
  final double? totalArea;
  final String areaUnit;
  final double pricePerSqm;
  final String availablePlotSizes;
  final double? minPriceOtherProperties;
  final double? maxPriceOtherProperties;
  final bool isActive;
  final List<String> amenities;
  final List<dynamic> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  Estate({
    required this.id,
    required this.isOurEstate,
    this.legalFee,
    this.developmentFee,
    this.receiptFee,
    required this.estateName,
    required this.estateCode,
    required this.estateType,
    required this.estateTypeDisplay,
    required this.developerCompanyName,
    required this.estateDescription,
    required this.countryId,
    required this.countryName,
    required this.state,
    required this.cityTown,
    required this.preciseAddress,
    required this.estateStatus,
    required this.estateStatusDisplay,
    this.totalArea,
    required this.areaUnit,
    required this.pricePerSqm,
    required this.availablePlotSizes,
    this.minPriceOtherProperties,
    this.maxPriceOtherProperties,
    required this.isActive,
    this.amenities = const [],
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Estate.fromJson(Map<String, dynamic> json) {
    return Estate(
      id: json['id'],
      isOurEstate: json['is_our_estate'] ?? false,
      legalFee: _toDouble(json['legal_fee']),
      developmentFee: _toDouble(json['development_fee']),
      receiptFee: _toDouble(json['receipt_fee']),
      estateName: json['estate_name'] ?? '',
      estateCode: json['estate_code'] ?? '',
      estateType: json['estate_type'] ?? '',
      estateTypeDisplay: json['estate_type_display'] ?? '',
      developerCompanyName: json['developer_company_name'] ?? '',
      estateDescription: json['estate_description'] ?? '',
      countryId: json['country_id'] ?? 0,
      countryName: json['country_name'] ?? '',
      state: json['state'] ?? '',
      cityTown: json['city_town'] ?? '',
      preciseAddress: json['precise_address'] ?? '',
      estateStatus: json['estate_status'] ?? '',
      estateStatusDisplay: json['estate_status_display'] ?? '',
      totalArea: _toDouble(json['total_area']),
      areaUnit: json['area_unit'] ?? '',
      pricePerSqm: _toDouble(json['price_per_sqm']) ?? 0,
      availablePlotSizes: json['available_plot_sizes'] ?? '',
      minPriceOtherProperties: _toDouble(json['min_price_other_properties']),
      maxPriceOtherProperties: _toDouble(json['max_price_other_properties']),
      isActive: json['is_active'] ?? true,
      amenities: List<String>.from(json['amenities'] ?? []),
      tags: List<dynamic>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  /// Helper: location string for display
  String get location => '$cityTown, $state';

  // Legacy getters used by detail/dialog pages
  String get name => estateName;
  String get description => estateDescription;
  String get developer => developerCompanyName;
  String get status => estateStatusDisplay;

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

/// Plot model — used by estate detail page.
/// Will be connected to the properties API later.
class EstatePlot {
  final String id;
  final String estateId;
  final String estateName;
  final String plotNumber;
  final double size;
  final String plotType;
  final String status;
  final double price;
  final String? description;
  final String? blockNumber;
  final Map<String, dynamic>? dimensions;
  final String? buyerName;
  final String? buyerPhone;
  final String? buyerEmail;
  final DateTime? reservationDate;
  final DateTime? saleDate;
  final String? surveyPlanNumber;
  final List<String> documents;
  final DateTime createdDate;
  final DateTime? lastUpdated;

  EstatePlot({
    required this.id,
    required this.estateId,
    required this.estateName,
    required this.plotNumber,
    required this.size,
    required this.plotType,
    required this.status,
    required this.price,
    this.description,
    this.blockNumber,
    this.dimensions,
    this.buyerName,
    this.buyerPhone,
    this.buyerEmail,
    this.reservationDate,
    this.saleDate,
    this.surveyPlanNumber,
    this.documents = const [],
    required this.createdDate,
    this.lastUpdated,
  });
}
