class UserData {
  final String userId;
  final String? email;
  final String? location;
  final String firstName;
  final String lastName;
  final DateTime? dob;
  final bool isVerified;
  final String? userPlan;
  final String mobileNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserData({
    required this.userId,
    this.email,
    this.location,
    required this.firstName,
    required this.lastName,
    this.dob,
    required this.isVerified,
    this.userPlan,
    required this.mobileNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      userId: json['userId'],
      email: json['email'],
      location: json['location'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      dob: json['dob'] != null ? DateTime.parse(json['dob']) : null,
      isVerified: json['isVerified'],
      userPlan: json['user_plan'],
      mobileNumber: json['mobile_number'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class UserResponse {
  final bool success;
  final String message;
  final UserData data;

  UserResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      success: json['success'],
      message: json['message'],
      data: UserData.fromJson(json['data']),
    );
  }
}