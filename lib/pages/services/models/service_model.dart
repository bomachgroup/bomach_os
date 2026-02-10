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
      'category': category.toJson(),
      'description': description,
      'base_price': basePrice,
      'delivery_time': deliveryTime,
      'status': status,
      'created_by': createdBy,
    };
  }
}
