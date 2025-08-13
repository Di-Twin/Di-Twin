abstract class AuthRepository {
  Future<bool> isLoggedIn();
  Future<Map<String, dynamic>> signOut();

  // Token validation
  Future<Map<String, dynamic>> validateToken();

  // Email Authentication
  Future<Map<String, dynamic>> initiateEmailSignup({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? mobileNumber,
  });
  Future<Map<String, dynamic>> completeEmailSignup({
    required String otp,
    required String token,
  });
  Future<Map<String, dynamic>> loginWithEmail({
    required String email,
    required String password,
  });

  // OAuth Authentication
  Future<Map<String, dynamic>> oauthSignIn({
    required String email,
    required String provider,
    required String firstName,
    required String lastName,
    String? mobileNumber,
  });

  // Password Reset
  Future<Map<String, dynamic>> forgotPassword({required String email});
  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String otp,
    required String password,
  });

  // User Profile
  Future<Map<String, dynamic>> getUserProfile();
  Future<Map<String, dynamic>> updateUserProfile({
    String? firstName,
    String? lastName,
    String? dob,
    String? location,
    String? userPlan,
  });
  Future<Map<String, dynamic>> deleteUserAccount();

  // Token Management
  Future<Map<String, dynamic>> refreshAccessToken();
  String? getAccessToken();

  // Legacy Phone Authentication
  Future<Map<String, dynamic>> startUserRegistration({required String phoneNumber});
  Future<Map<String, dynamic>> completeRegistration({
    required String phoneNumber,
    required String firstName,
    required String lastName,
    required String otpCode,
  });
  Future<Map<String, dynamic>> signInUser({
    required String phoneNumber,
    required String otpCode,
  });
  Future<Map<String, dynamic>> resendOtp(String phoneNumber);
}
