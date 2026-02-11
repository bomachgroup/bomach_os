class Lead {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String gender;
  final String maritalStatus;
  final String address;
  final String phoneNumber;
  final String? profilePicture;
  final String source;
  final String status;
  final String companyName;
  final String interestedServices;
  final String assignedToName;
  final String notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Lead({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.maritalStatus,
    required this.address,
    required this.phoneNumber,
    this.profilePicture,
    required this.source,
    required this.status,
    required this.companyName,
    required this.interestedServices,
    required this.assignedToName,
    required this.notes,
    this.createdAt,
    this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      gender: json['gender'] ?? 'male',
      maritalStatus: json['marital_status'] ?? 'single',
      address: json['address'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      profilePicture: json['profile_picture'],
      source: json['source'] ?? 'other',
      status: json['status'] ?? 'new',
      companyName: json['company_name'] ?? '',
      interestedServices: json['interested_services'] ?? '',
      assignedToName: json['assigned_to_name'] ?? '',
      notes: json['notes'] ?? '',
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
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'interested_services': interestedServices,
    };
  }

  Map<String, dynamic> toCreateJson(int assignedToId) {
    return {
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'interested_services': interestedServices,
      'assigned_to_id': assignedToId,
    };
  }
}
