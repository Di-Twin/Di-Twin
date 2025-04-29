import 'package:client/features/auth/domain/repositories/auth_repository.dart';

class SignInUserUseCase {
  final AuthRepository repository;

  SignInUserUseCase(this.repository);

  Future<Map<String, dynamic>> execute({
    required String phoneNumber,
    required String otpCode,
  }) {
    return repository.signInUser(
      phoneNumber: phoneNumber,
      otpCode: otpCode,
    );
  }
}
