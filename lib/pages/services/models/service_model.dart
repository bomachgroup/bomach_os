class ServiceCategory {
  final int id;
  final String name;
  final String description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ServiceCategory({
    required this.id,
    required this.name,
    required this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
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
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class Service {
  final int id;
  final String name;
  final ServiceCategory category;
  final String description;
  final String basePrice;
  final String deliveryTime;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String createdBy;

  Service({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.basePrice,
    required this.deliveryTime,
    required this.status,
    this.createdAt,
    this.updatedAt,
    required this.createdBy,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? '',
      category: ServiceCategory.fromJson(json['category'] ?? {}),
      description: json['description'] ?? '',
      basePrice: json['base_price'] ?? '0.00',
      deliveryTime: json['delivery_time'] ?? '',
      status: json['status'] ?? 'active',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      createdBy: json['created_by']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category_id': category.id,
      'description': description,
      'base_price': basePrice,
      'delivery_time': deliveryTime,
      'status': status,
      'created_by': createdBy,
    };
  }

  /// Create a Service instance for API submission
  /// Used when creating a new service with just the category ID
  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      'category_id': category.id,
      'description': description,
      'base_price': basePrice,
      'delivery_time': deliveryTime,
      'status': status,
      'created_by': createdBy,
    };
  }
}

class Quote {
  final int id;
  final String quoteNumber;
  final String clientId;
  final Service service;
  final String description;
  final String amount;
  final String validUntil;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String createdBy;

  Quote({
    required this.id,
    required this.quoteNumber,
    required this.clientId,
    required this.service,
    required this.description,
    required this.amount,
    required this.validUntil,
    required this.status,
    this.createdAt,
    this.updatedAt,
    required this.createdBy,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      quoteNumber: json['quote_number'] ?? '',
      clientId: json['client_id']?.toString() ?? '',
      service: Service.fromJson(json['service'] ?? {}),
      description: json['description'] ?? '',
      amount: json['amount'] ?? '0.00',
      validUntil: json['valid_until'] ?? '',
      status: json['status'] ?? 'draft',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      createdBy: json['created_by']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quote_number': quoteNumber,
      'client_id': clientId,
      'service_id': service.id,
      'description': description,
      'amount': amount,
      'valid_until': validUntil,
      'status': status,
      'created_by': createdBy,
    };
  }
}
