import 'package:client/features/auth/domain/repositories/auth_repository.dart';

class LoginWithEmailUseCase {
  final AuthRepository repository;

  LoginWithEmailUseCase(this.repository);

  Future<Map<String, dynamic>> execute({
    required String email,
    required String password,
  }) {
    return repository.loginWithEmail(
      email: email,
      password: password,
    );
  }
}
