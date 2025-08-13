class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? mobileNumber;
  final String? location;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.mobileNumber,
    this.location,
    required this.createdAt,
  });
}
