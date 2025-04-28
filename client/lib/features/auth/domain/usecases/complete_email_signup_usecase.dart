import 'package:client/features/auth/domain/repositories/auth_repository.dart';

class CompleteEmailSignupUseCase {
  final AuthRepository repository;

  CompleteEmailSignupUseCase(this.repository);

  Future<Map<String, dynamic>> execute({
    required String otp,
    required String token,
  }) {
    return repository.completeEmailSignup(
      otp: otp,
      token: token,
    );
  }
}
