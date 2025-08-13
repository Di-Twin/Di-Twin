import 'package:client/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:client/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:client/features/auth/domain/repositories/auth_repository.dart';
import 'package:client/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:client/features/auth/domain/usecases/complete_email_signup_usecase.dart';
import 'package:client/features/auth/domain/usecases/complete_registration_usecase.dart';
import 'package:client/features/auth/domain/usecases/get_access_token_usecase.dart';
import 'package:client/features/auth/domain/usecases/initiate_email_signup_usecase.dart';
import 'package:client/features/auth/domain/usecases/login_with_email_usecase.dart';
import 'package:client/features/auth/domain/usecases/resend_otp_usecase.dart';
import 'package:client/features/auth/domain/usecases/sign_in_user_usecase.dart';
import 'package:client/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:client/features/auth/domain/usecases/start_user_registration_usecase.dart';
import 'package:client/features/auth/domain/usecases/validate_token_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/features/auth/domain/usecases/oauth_sign_in_usecase.dart';
import 'package:client/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:client/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:client/features/auth/domain/usecases/get_user_profile_usecase.dart';
import 'package:client/features/auth/domain/usecases/update_user_profile_usecase.dart';
import 'package:client/features/auth/domain/usecases/delete_user_account_usecase.dart';

// Data Source provider - Make it a singleton to ensure the same instance is used throughout the app
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
 return AuthRemoteDataSourceImpl();
});

// Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
 final remoteDataSource = ref.read(authRemoteDataSourceProvider);
 return AuthRepositoryImpl(remoteDataSource);
});

// Use case providers
final checkAuthStatusUseCaseProvider = Provider<CheckAuthStatusUseCase>((ref) {
 final repository = ref.read(authRepositoryProvider);
 return CheckAuthStatusUseCase(repository);
});

final validateTokenUseCaseProvider = Provider<ValidateTokenUseCase>((ref) {
 final repository = ref.read(authRepositoryProvider);
 return ValidateTokenUseCase(repository);
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
 final repository = ref.read(authRepositoryProvider);
 return SignOutUseCase(repository);
});

final initiateEmailSignupUseCaseProvider = Provider<InitiateEmailSignupUseCase>((ref) {
 final repository = ref.read(authRepositoryProvider);
 return InitiateEmailSignupUseCase(repository);
});

final completeEmailSignupUseCaseProvider = Provider<CompleteEmailSignupUseCase>((ref) {
 final repository = ref.read(authRepositoryProvider);
 return CompleteEmailSignupUseCase(repository);
});

final loginWithEmailUseCaseProvider = Provider<LoginWithEmailUseCase>((ref) {
 final repository = ref.read(authRepositoryProvider);
 return LoginWithEmailUseCase(repository);
});

final startUserRegistrationUseCaseProvider = Provider<StartUserRegistrationUseCase>((ref) {
 final repository = ref.read(authRepositoryProvider);
 return StartUserRegistrationUseCase(repository);
});

final completeRegistrationUseCaseProvider = Provider<CompleteRegistrationUseCase>((ref) {
 final repository = ref.read(authRepositoryProvider);
 return CompleteRegistrationUseCase(repository);
});

final signInUserUseCaseProvider = Provider<SignInUserUseCase>((ref) {
 final repository = ref.read(authRepositoryProvider);
 return SignInUserUseCase(repository);
});

final resendOtpUseCaseProvider = Provider<ResendOtpUseCase>((ref) {
 final repository = ref.read(authRepositoryProvider);
 return ResendOtpUseCase(repository);
});

final getAccessTokenUseCaseProvider = Provider<GetAccessTokenUseCase>((ref) {
 final repository = ref.read(authRepositoryProvider);
 return GetAccessTokenUseCase(repository);
});

// Add the new use case providers to the existing file
final oauthSignInUseCaseProvider = Provider<OAuthSignInUseCase>((ref) {
 final repository = ref.read(authRepositoryProvider);
 return OAuthSignInUseCase(repository);
});

final forgotPasswordUseCaseProvider = Provider<ForgotPasswordUseCase>((ref) {
 final repository = ref.read(authRepositoryProvider);
 return ForgotPasswordUseCase(repository);
});

final resetPasswordUseCaseProvider = Provider<ResetPasswordUseCase>((ref) {
 final repository = ref.read(authRepositoryProvider);
 return ResetPasswordUseCase(repository);
});

final getUserProfileUseCaseProvider = Provider<GetUserProfileUseCase>((ref) {
 final repository = ref.read(authRepositoryProvider);
 return GetUserProfileUseCase(repository);
});

final updateUserProfileUseCaseProvider = Provider<UpdateUserProfileUseCase>((ref) {
 final repository = ref.read(authRepositoryProvider);
 return UpdateUserProfileUseCase(repository);
});

final deleteUserAccountUseCaseProvider = Provider<DeleteUserAccountUseCase>((ref) {
 final repository = ref.read(authRepositoryProvider);
 return DeleteUserAccountUseCase(repository);
});

// State providers for form data
final emailProvider = StateProvider<String>((ref) => '');
final passwordProvider = StateProvider<String>((ref) => '');
final firstNameProvider = StateProvider<String>((ref) => '');
final lastNameProvider = StateProvider<String>((ref) => '');
final phoneProvider = StateProvider<String>((ref) => '');
final otpProvider = StateProvider<String>((ref) => '');
final loadingProvider = StateProvider<bool>((ref) => false);
final authErrorProvider = StateProvider<String?>((ref) => null);

// Add state providers for the new functionality
final resetTokenProvider = StateProvider<String?>((ref) => null);
final providerTypeProvider = StateProvider<String>((ref) => 'email'); // 'email', 'google', 'facebook', 'apple'

// Add a provider for the signup token to persist it across screens
final signupTokenProvider = StateProvider<String?>((ref) => null);

// Authentication state with token validation
final isAuthenticatedProvider = FutureProvider<bool>((ref) async {
 final validateTokenUseCase = ref.read(validateTokenUseCaseProvider);
 final result = await validateTokenUseCase.execute();
 return result["isValid"] == true;
});

// Auth service provider for settings page
final authServiceProvider = Provider((ref) => ref.read(authRepositoryProvider));
