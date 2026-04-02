class PropertyModel {
  final String id;
  final String name;
  final String type; // Residential, Commercial, Industrial, Land, Mixed-Use
  final String category; // For Sale, For Rent, For Lease, Sold, Rented
  final String location;
  final String address;
  final double price;
  final String priceDisplay;
  final double size; // in square meters
  final int bedrooms;
  final int bathrooms;
  final int parkingSpaces;
  final String status; // Available, Reserved, Sold, Under Construction, Pending
  final String description;
  final String? owner;
  final String? developer;
  final int? yearBuilt;
  final List<String> features;
  final List<String> amenities;
  final List<String> images;
  final List<PropertyDocument> documents;
  final PropertyAgent? agent;
  final DateTime listedDate;
  final DateTime? lastUpdated;
  final String?
      titleStatus; // Certificate of Occupancy, Deed of Assignment, etc.
  final PropertyLocation? coordinates;

  PropertyModel({
    required this.id,
    required this.name,
    required this.type,
    required this.category,
    required this.location,
    required this.address,
    required this.price,
    required this.priceDisplay,
    required this.size,
    this.bedrooms = 0,
    this.bathrooms = 0,
    this.parkingSpaces = 0,
    required this.status,
    required this.description,
    this.owner,
    this.developer,
    this.yearBuilt,
    this.features = const [],
    this.amenities = const [],
    this.images = const [],
    this.documents = const [],
    this.agent,
    required this.listedDate,
    this.lastUpdated,
    this.titleStatus,
    this.coordinates,
  });

  // Convert PropertyModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'category': category,
      'location': location,
      'address': address,
      'price': price,
      'priceDisplay': priceDisplay,
      'size': size,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'parkingSpaces': parkingSpaces,
      'status': status,
      'description': description,
      'owner': owner,
      'developer': developer,
      'yearBuilt': yearBuilt,
      'features': features,
      'amenities': amenities,
      'images': images,
      'documents': documents.map((doc) => doc.toJson()).toList(),
      'agent': agent?.toJson(),
      'listedDate': listedDate.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
      'titleStatus': titleStatus,
      'coordinates': coordinates?.toJson(),
    };
  }

  // Create PropertyModel from JSON
  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      category: json['category'] as String,
      location: json['location'] as String,
      address: json['address'] as String,
      price: (json['price'] as num).toDouble(),
      priceDisplay: json['priceDisplay'] as String,
      size: (json['size'] as num).toDouble(),
      bedrooms: json['bedrooms'] as int? ?? 0,
      bathrooms: json['bathrooms'] as int? ?? 0,
      parkingSpaces: json['parkingSpaces'] as int? ?? 0,
      status: json['status'] as String,
      description: json['description'] as String,
      owner: json['owner'] as String?,
      developer: json['developer'] as String?,
      yearBuilt: json['yearBuilt'] as int?,
      features: (json['features'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      amenities: (json['amenities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      documents: (json['documents'] as List<dynamic>?)
              ?.map((doc) =>
                  PropertyDocument.fromJson(doc as Map<String, dynamic>))
              .toList() ??
          [],
      agent: json['agent'] != null
          ? PropertyAgent.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
      listedDate: DateTime.parse(json['listedDate'] as String),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : null,
      titleStatus: json['titleStatus'] as String?,
      coordinates: json['coordinates'] != null
          ? PropertyLocation.fromJson(
              json['coordinates'] as Map<String, dynamic>)
          : null,
    );
  }

  // Create a copy with updated fields
  PropertyModel copyWith({
    String? id,
    String? name,
    String? type,
    String? category,
    String? location,
    String? address,
    double? price,
    String? priceDisplay,
    double? size,
    int? bedrooms,
    int? bathrooms,
    int? parkingSpaces,
    String? status,
    String? description,
    String? owner,
    String? developer,
    int? yearBuilt,
    List<String>? features,
    List<String>? amenities,
    List<String>? images,
    List<PropertyDocument>? documents,
    PropertyAgent? agent,
    DateTime? listedDate,
    DateTime? lastUpdated,
    String? titleStatus,
    PropertyLocation? coordinates,
  }) {
    return PropertyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      category: category ?? this.category,
      location: location ?? this.location,
      address: address ?? this.address,
      price: price ?? this.price,
      priceDisplay: priceDisplay ?? this.priceDisplay,
      size: size ?? this.size,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      parkingSpaces: parkingSpaces ?? this.parkingSpaces,
      status: status ?? this.status,
      description: description ?? this.description,
      owner: owner ?? this.owner,
      developer: developer ?? this.developer,
      yearBuilt: yearBuilt ?? this.yearBuilt,
      features: features ?? this.features,
      amenities: amenities ?? this.amenities,
      images: images ?? this.images,
      documents: documents ?? this.documents,
      agent: agent ?? this.agent,
      listedDate: listedDate ?? this.listedDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      titleStatus: titleStatus ?? this.titleStatus,
      coordinates: coordinates ?? this.coordinates,
    );
  }
}

class PropertyDocument {
  final String id;
  final String name;
  final String type; // Title, Survey Plan, Building Approval, etc.
  final String url;
  final String fileSize;
  final DateTime uploadedDate;

  PropertyDocument({
    required this.id,
    required this.name,
    required this.type,
    required this.url,
    required this.fileSize,
    required this.uploadedDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'url': url,
      'fileSize': fileSize,
      'uploadedDate': uploadedDate.toIso8601String(),
    };
  }

  factory PropertyDocument.fromJson(Map<String, dynamic> json) {
    return PropertyDocument(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      url: json['url'] as String,
      fileSize: json['fileSize'] as String,
      uploadedDate: DateTime.parse(json['uploadedDate'] as String),
    );
  }
}

class PropertyAgent {
  final String id;
  final String name;
  final String title;
  final String email;
  final String phone;
  final String? photoUrl;

  PropertyAgent({
    required this.id,
    required this.name,
    required this.title,
    required this.email,
    required this.phone,
    this.photoUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
    };
  }

  factory PropertyAgent.fromJson(Map<String, dynamic> json) {
    return PropertyAgent(
      id: json['id'] as String,
      name: json['name'] as String,
      title: json['title'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      photoUrl: json['photoUrl'] as String?,
    );
  }
}

class PropertyLocation {
  final double latitude;
  final double longitude;
  final String? placeName;

  PropertyLocation({
    required this.latitude,
    required this.longitude,
    this.placeName,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'placeName': placeName,
    };
  }

  factory PropertyLocation.fromJson(Map<String, dynamic> json) {
    return PropertyLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      placeName: json['placeName'] as String?,
    );
  }
}

// Property History Event Model
class PropertyHistoryEvent {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String
      eventType; // Listed, Price Change, Status Change, Viewing, Offer, etc.

  PropertyHistoryEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.eventType,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'eventType': eventType,
    };
  }

  factory PropertyHistoryEvent.fromJson(Map<String, dynamic> json) {
    return PropertyHistoryEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      eventType: json['eventType'] as String,
    );
  }
}
