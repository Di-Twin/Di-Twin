import 'package:client/features/auth/domain/repositories/auth_repository.dart';

class ForgotPasswordUseCase {
  final AuthRepository repository;

  ForgotPasswordUseCase(this.repository);

  Future<Map<String, dynamic>> execute({required String email}) {
    return repository.forgotPassword(email: email);
  }
}
