import 'package:client/features/auth/domain/repositories/auth_repository.dart';

class ValidateTokenUseCase {
  final AuthRepository repository;

  ValidateTokenUseCase(this.repository);

  Future<Map<String, dynamic>> execute() {
    return repository.validateToken();
  }
}
