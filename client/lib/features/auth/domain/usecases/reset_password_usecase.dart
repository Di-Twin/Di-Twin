import 'package:client/features/auth/domain/repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<Map<String, dynamic>> execute({
    required String token,
    required String otp,
    required String password,
  }) {
    return repository.resetPassword(
      token: token,
      otp: otp,
      password: password,
    );
  }
}
