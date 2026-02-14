class Property {
  final int id;
  final String name;
  final String propertyType;
  final String category;
  final String location;
  final String price;
  final String size;
  final int bedrooms;
  final int bathrooms;
  final int parkingSpaces;
  final String description;
  final List<String> images;
  final String status;
  final String clientId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Property({
    required this.id,
    required this.name,
    required this.propertyType,
    required this.category,
    required this.location,
    required this.price,
    required this.size,
    required this.bedrooms,
    required this.bathrooms,
    required this.parkingSpaces,
    required this.description,
    required this.images,
    required this.status,
    required this.clientId,
    this.createdAt,
    this.updatedAt,
  });

  String get formattedPrice {
    final numPrice = double.tryParse(price) ?? 0;
    final formatted = numPrice.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
    return '₦$formatted';
  }

  String get formattedCategory {
    switch (category.toLowerCase()) {
      case 'sale':
        return 'For Sale';
      case 'rent':
        return 'For Rent';
      case 'lease':
        return 'For Lease';
      default:
        return category;
    }
  }

  String get formattedType {
    if (propertyType.isEmpty) return '';
    return propertyType[0].toUpperCase() + propertyType.substring(1);
  }

  String get formattedStatus {
    if (status.isEmpty) return '';
    return status[0].toUpperCase() + status.substring(1);
  }

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? '',
      propertyType: json['property_type'] ?? '',
      category: json['category'] ?? '',
      location: json['location'] ?? '',
      price: json['price']?.toString() ?? '0',
      size: json['size']?.toString() ?? '0',
      bedrooms: json['bedrooms'] is int
          ? json['bedrooms']
          : int.tryParse(json['bedrooms']?.toString() ?? '0') ?? 0,
      bathrooms: json['bathrooms'] is int
          ? json['bathrooms']
          : int.tryParse(json['bathrooms']?.toString() ?? '0') ?? 0,
      parkingSpaces: json['parking_spaces'] is int
          ? json['parking_spaces']
          : int.tryParse(json['parking_spaces']?.toString() ?? '0') ?? 0,
      description: json['description'] ?? '',
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      status: json['status'] ?? '',
      clientId: json['client_id']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'property_type': propertyType,
      'category': category,
      'location': location,
      'price': price,
      'size': size,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'parking_spaces': parkingSpaces,
      'description': description,
      'images': images,
      'status': status,
      'client_id': clientId,
    };
  }
}
