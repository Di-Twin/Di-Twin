import 'package:client/features/auth/domain/repositories/auth_repository.dart';

class DeleteUserAccountUseCase {
  final AuthRepository repository;

  DeleteUserAccountUseCase(this.repository);

  Future<Map<String, dynamic>> execute() {
    return repository.deleteUserAccount();
  }
}
