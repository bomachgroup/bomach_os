class Client {
  final int id;
  final int userId;
  final String firstName;
  final String lastName;
  final String email;
  final String? profilePicture;
  final String address;
  final String phoneNumber;
  final String gender;
  final int balance;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Client({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.profilePicture,
    required this.address,
    required this.phoneNumber,
    required this.gender,
    required this.balance,
    this.createdAt,
    this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      profilePicture: json['profile_picture'],
      address: json['address'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      gender: json['gender'] ?? 'male',
      balance: json['balance'] is int
          ? json['balance']
          : int.tryParse(json['balance']?.toString() ?? '0') ?? 0,
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
      'user_id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'profile_picture': profilePicture,
      'address': address,
      'phone_number': phoneNumber,
      'gender': gender,
      'balance': balance,
    };
  }
}
