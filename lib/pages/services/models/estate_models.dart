class Estate {
  final String id;
  final String name;
  final String location;
  final String description;
  final String developer;
  final double totalArea; // in sqm
  final int totalPlots;
  final int availablePlots;
  final int soldPlots;
  final int reservedPlots;
  final String status; // 'Active', 'Completed', 'Under Development', 'Planning'
  final DateTime createdDate;
  final List<String> images;
  final List<String> documents;
  final Map<String, dynamic>? amenities;
  final String? contactPerson;
  final String? contactPhone;
  final String? contactEmail;

  Estate({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.developer,
    required this.totalArea,
    required this.totalPlots,
    required this.availablePlots,
    required this.soldPlots,
    required this.reservedPlots,
    required this.status,
    required this.createdDate,
    this.images = const [],
    this.documents = const [],
    this.amenities,
    this.contactPerson,
    this.contactPhone,
    this.contactEmail,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'description': description,
      'developer': developer,
      'totalArea': totalArea,
      'totalPlots': totalPlots,
      'availablePlots': availablePlots,
      'soldPlots': soldPlots,
      'reservedPlots': reservedPlots,
      'status': status,
      'createdDate': createdDate.toIso8601String(),
      'images': images,
      'documents': documents,
      'amenities': amenities,
      'contactPerson': contactPerson,
      'contactPhone': contactPhone,
      'contactEmail': contactEmail,
    };
  }

  factory Estate.fromJson(Map<String, dynamic> json) {
    return Estate(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      description: json['description'],
      developer: json['developer'],
      totalArea: json['totalArea'],
      totalPlots: json['totalPlots'],
      availablePlots: json['availablePlots'],
      soldPlots: json['soldPlots'],
      reservedPlots: json['reservedPlots'],
      status: json['status'],
      createdDate: DateTime.parse(json['createdDate']),
      images: List<String>.from(json['images'] ?? []),
      documents: List<String>.from(json['documents'] ?? []),
      amenities: json['amenities'],
      contactPerson: json['contactPerson'],
      contactPhone: json['contactPhone'],
      contactEmail: json['contactEmail'],
    );
  }

  Estate copyWith({
    String? id,
    String? name,
    String? location,
    String? description,
    String? developer,
    double? totalArea,
    int? totalPlots,
    int? availablePlots,
    int? soldPlots,
    int? reservedPlots,
    String? status,
    DateTime? createdDate,
    List<String>? images,
    List<String>? documents,
    Map<String, dynamic>? amenities,
    String? contactPerson,
    String? contactPhone,
    String? contactEmail,
  }) {
    return Estate(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      description: description ?? this.description,
      developer: developer ?? this.developer,
      totalArea: totalArea ?? this.totalArea,
      totalPlots: totalPlots ?? this.totalPlots,
      availablePlots: availablePlots ?? this.availablePlots,
      soldPlots: soldPlots ?? this.soldPlots,
      reservedPlots: reservedPlots ?? this.reservedPlots,
      status: status ?? this.status,
      createdDate: createdDate ?? this.createdDate,
      images: images ?? this.images,
      documents: documents ?? this.documents,
      amenities: amenities ?? this.amenities,
      contactPerson: contactPerson ?? this.contactPerson,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
    );
  }
}

class EstatePlot {
  final String id;
  final String estateId;
  final String estateName;
  final String plotNumber;
  final double size; // in sqm
  final String plotType; // 'Residential', 'Commercial', 'Mixed-Use'
  final String status; // 'Available', 'Reserved', 'Sold', 'Under Offer'
  final double price;
  final String? description;
  final String? blockNumber;
  final Map<String, dynamic>? dimensions; // length, width, etc.
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'estateId': estateId,
      'estateName': estateName,
      'plotNumber': plotNumber,
      'size': size,
      'plotType': plotType,
      'status': status,
      'price': price,
      'description': description,
      'blockNumber': blockNumber,
      'dimensions': dimensions,
      'buyerName': buyerName,
      'buyerPhone': buyerPhone,
      'buyerEmail': buyerEmail,
      'reservationDate': reservationDate?.toIso8601String(),
      'saleDate': saleDate?.toIso8601String(),
      'surveyPlanNumber': surveyPlanNumber,
      'documents': documents,
      'createdDate': createdDate.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  factory EstatePlot.fromJson(Map<String, dynamic> json) {
    return EstatePlot(
      id: json['id'],
      estateId: json['estateId'],
      estateName: json['estateName'],
      plotNumber: json['plotNumber'],
      size: json['size'],
      plotType: json['plotType'],
      status: json['status'],
      price: json['price'],
      description: json['description'],
      blockNumber: json['blockNumber'],
      dimensions: json['dimensions'],
      buyerName: json['buyerName'],
      buyerPhone: json['buyerPhone'],
      buyerEmail: json['buyerEmail'],
      reservationDate: json['reservationDate'] != null
          ? DateTime.parse(json['reservationDate'])
          : null,
      saleDate:
          json['saleDate'] != null ? DateTime.parse(json['saleDate']) : null,
      surveyPlanNumber: json['surveyPlanNumber'],
      documents: List<String>.from(json['documents'] ?? []),
      createdDate: DateTime.parse(json['createdDate']),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : null,
    );
  }

  EstatePlot copyWith({
    String? id,
    String? estateId,
    String? estateName,
    String? plotNumber,
    double? size,
    String? plotType,
    String? status,
    double? price,
    String? description,
    String? blockNumber,
    Map<String, dynamic>? dimensions,
    String? buyerName,
    String? buyerPhone,
    String? buyerEmail,
    DateTime? reservationDate,
    DateTime? saleDate,
    String? surveyPlanNumber,
    List<String>? documents,
    DateTime? createdDate,
    DateTime? lastUpdated,
  }) {
    return EstatePlot(
      id: id ?? this.id,
      estateId: estateId ?? this.estateId,
      estateName: estateName ?? this.estateName,
      plotNumber: plotNumber ?? this.plotNumber,
      size: size ?? this.size,
      plotType: plotType ?? this.plotType,
      status: status ?? this.status,
      price: price ?? this.price,
      description: description ?? this.description,
      blockNumber: blockNumber ?? this.blockNumber,
      dimensions: dimensions ?? this.dimensions,
      buyerName: buyerName ?? this.buyerName,
      buyerPhone: buyerPhone ?? this.buyerPhone,
      buyerEmail: buyerEmail ?? this.buyerEmail,
      reservationDate: reservationDate ?? this.reservationDate,
      saleDate: saleDate ?? this.saleDate,
      surveyPlanNumber: surveyPlanNumber ?? this.surveyPlanNumber,
      documents: documents ?? this.documents,
      createdDate: createdDate ?? this.createdDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
