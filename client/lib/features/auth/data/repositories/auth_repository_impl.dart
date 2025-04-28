import 'package:client/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:client/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<bool> isLoggedIn() {
    return _remoteDataSource.isLoggedIn();
  }

  @override
  Future<Map<String, dynamic>> signOut() {
    return _remoteDataSource.signOut();
  }

  @override
  Future<Map<String, dynamic>> initiateEmailSignup({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? mobileNumber,
  }) {
    return _remoteDataSource.initiateEmailSignup(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      mobileNumber: mobileNumber,
    );
  }

  @override
  Future<Map<String, dynamic>> completeEmailSignup({
    required String otp,
    required String token,
  }) {
    return _remoteDataSource.completeEmailSignup(
      otp: otp,
      token: token,
    );
  }

  @override
  Future<Map<String, dynamic>> loginWithEmail({
    required String email,
    required String password,
  }) {
    return _remoteDataSource.loginWithEmail(
      email: email,
      password: password,
    );
  }

  @override
  Future<Map<String, dynamic>> oauthSignIn({
    required String email,
    required String provider,
    required String firstName,
    required String lastName,
    String? mobileNumber,
  }) {
    return _remoteDataSource.oauthSignIn(
      email: email,
      provider: provider,
      firstName: firstName,
      lastName: lastName,
      mobileNumber: mobileNumber,
    );
  }

  @override
  Future<Map<String, dynamic>> forgotPassword({required String email}) {
    return _remoteDataSource.forgotPassword(email: email);
  }

  @override
  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String otp,
    required String password,
  }) {
    return _remoteDataSource.resetPassword(
      token: token,
      otp: otp,
      password: password,
    );
  }

  @override
  Future<Map<String, dynamic>> getUserProfile() {
    return _remoteDataSource.getUserProfile();
  }

  @override
  Future<Map<String, dynamic>> updateUserProfile({
    String? firstName,
    String? lastName,
    String? dob,
    String? location,
    String? userPlan,
  }) {
    return _remoteDataSource.updateUserProfile(
      firstName: firstName,
      lastName: lastName,
      dob: dob,
      location: location,
      userPlan: userPlan,
    );
  }

  @override
  Future<Map<String, dynamic>> deleteUserAccount() {
    return _remoteDataSource.deleteUserAccount();
  }

  @override
  Future<Map<String, dynamic>> refreshAccessToken() {
    return _remoteDataSource.refreshAccessToken();
  }

  @override
  String? getAccessToken() {
    return _remoteDataSource.getAccessToken();
  }

  @override
  Future<Map<String, dynamic>> startUserRegistration({required String phoneNumber}) {
    return _remoteDataSource.startUserRegistration(phoneNumber: phoneNumber);
  }

  @override
  Future<Map<String, dynamic>> completeRegistration({
    required String phoneNumber,
    required String firstName,
    required String lastName,
    required String otpCode,
  }) {
    return _remoteDataSource.completeRegistration(
      phoneNumber: phoneNumber,
      firstName: firstName,
      lastName: lastName,
      otpCode: otpCode,
    );
  }

  @override
  Future<Map<String, dynamic>> signInUser({
    required String phoneNumber,
    required String otpCode,
  }) {
    return _remoteDataSource.signInUser(
      phoneNumber: phoneNumber,
      otpCode: otpCode,
    );
  }

  @override
  Future<Map<String, dynamic>> resendOtp(String phoneNumber) {
    return _remoteDataSource.resendOtp(phoneNumber);
  }
}
