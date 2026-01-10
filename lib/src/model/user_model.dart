class User {
  final int id;
  final String email;
  final String username;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? bio;
  final bool isVerified;
  final String createdAt;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.bio,
    required this.isVerified,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      phoneNumber: json['phone_number'],
      bio: json['bio'],
      isVerified: json['is_verified'] ?? false,
      createdAt: json['created_at'] ?? '',
    );
  }
}