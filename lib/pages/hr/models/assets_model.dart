class Asset {
  final String id;
  final String name;
  final String assetType; // e.g., "Laptop", "Vehicle"
  final String branch;
  final String? assignedToId; // Nullable if currently unassigned
  final String? departmentId;
  final String status; // e.g., "active", "maintenance"
  final DateTime? purchaseDate;
  final double value;
  final String? invoiceNumber;
  final DateTime? warrantyExpiryDate;
  final String? serialNumber;
  final String? manufacturer;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Asset({
    required this.id,
    required this.name,
    required this.assetType,
    required this.branch,
    this.assignedToId,
    this.departmentId,
    required this.status,
    this.purchaseDate,
    required this.value,
    this.invoiceNumber,
    this.warrantyExpiryDate,
    this.serialNumber,
    this.manufacturer,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse doubles
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    return Asset(
      // The API docs show 'asset_id' in paths but often 'id' in JSON bodies. 
      // We handle potential variations or missing IDs gracefully.
      id: json['id']?.toString() ?? json['asset_id']?.toString() ?? '',
      name: json['name'] ?? '',
      assetType: json['asset_type'] ?? '',
      branch: json['branch'] ?? '',
      assignedToId: json['assigned_to_id']?.toString(),
      departmentId: json['department_id']?.toString(),
      status: json['status'] ?? 'active',
      purchaseDate: json['purchase_date'] != null 
          ? DateTime.tryParse(json['purchase_date']) 
          : null,
      value: parseDouble(json['value']),
      invoiceNumber: json['invoice_number'],
      warrantyExpiryDate: json['warranty_expiry_date'] != null 
          ? DateTime.tryParse(json['warranty_expiry_date']) 
          : null,
      serialNumber: json['serial_number'],
      manufacturer: json['manufacturer'],
      notes: json['notes'],
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
      'purchase_date': purchaseDate?.toIso8601String().split('T').first,
      'value': value,
      'invoice_number': invoiceNumber,
      'warranty_expiry_date': warrantyExpiryDate?.toIso8601String().split('T').first,
      'serial_number': serialNumber,
      'manufacturer': manufacturer,
      'notes': notes,
    };
  }
}