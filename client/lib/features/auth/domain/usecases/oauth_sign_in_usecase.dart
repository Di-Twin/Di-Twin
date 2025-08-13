import 'package:client/features/auth/domain/repositories/auth_repository.dart';

class OAuthSignInUseCase {
  final AuthRepository repository;

  OAuthSignInUseCase(this.repository);

  Future<Map<String, dynamic>> execute({
    required String email,
    required String provider,
    required String firstName,
    required String lastName,
    String? mobileNumber,
  }) {
    return repository.oauthSignIn(
      email: email,
      provider: provider,
      firstName: firstName,
      lastName: lastName,
      mobileNumber: mobileNumber,
    );
  }
}
