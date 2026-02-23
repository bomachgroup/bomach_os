class Asset {
  final String id;
  final String name;
  final String assetType;
  final String branch;
  final String assignedToId; // Changed to non-nullable based on "must be filled up"
  final String departmentId; // Changed to non-nullable
  final String status;
  final DateTime purchaseDate; // Changed to non-nullable
  final double value;
  final String vendor; // Added field
  final String invoiceNumber; // Changed to non-nullable
  final DateTime warrantyExpiryDate; // Changed to non-nullable
  final String serialNumber; // Changed to non-nullable
  final String manufacturer; // Changed to non-nullable
  final String notes; // Changed to non-nullable
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Asset({
    required this.id,
    required this.name,
    required this.assetType,
    required this.branch,
    required this.assignedToId,
    required this.departmentId,
    required this.status,
    required this.purchaseDate,
    required this.value,
    required this.vendor,
    required this.invoiceNumber,
    required this.warrantyExpiryDate,
    required this.serialNumber,
    required this.manufacturer,
    required this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    return Asset(
      id: json['id']?.toString() ?? json['asset_id']?.toString() ?? '',
      name: json['name'] ?? '',
      assetType: json['asset_type'] ?? '',
      branch: json['branch'] ?? '',
      assignedToId: json['assigned_to_id']?.toString() ?? '',
      departmentId: json['department_id']?.toString() ?? '',
      status: json['status'] ?? 'available',
      purchaseDate: json['purchase_date'] != null 
          ? DateTime.tryParse(json['purchase_date']) ?? DateTime.now()
          : DateTime.now(),
      value: parseDouble(json['value']),
      vendor: json['vendor'] ?? '',
      invoiceNumber: json['invoice_number'] ?? '',
      warrantyExpiryDate: json['warranty_expiry_date'] != null 
          ? DateTime.tryParse(json['warranty_expiry_date']) ?? DateTime.now()
          : DateTime.now(),
      serialNumber: json['serial_number'] ?? '',
      manufacturer: json['manufacturer'] ?? '',
      notes: json['notes'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'asset_type': assetType,
      'branch': branch,
      'assigned_to_id': assignedToId,
      'department_id': departmentId,
      'status': status,
      'purchase_date': purchaseDate.toIso8601String().split('T').first,
      'value': value,
      'vendor': vendor,
      'invoice_number': invoiceNumber,
      'warranty_expiry_date': warrantyExpiryDate.toIso8601String().split('T').first,
      'serial_number': serialNumber,
      'manufacturer': manufacturer,
      'notes': notes,
    };
  }
}