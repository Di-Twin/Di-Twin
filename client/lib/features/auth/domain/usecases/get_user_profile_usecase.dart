import 'package:client/features/auth/domain/repositories/auth_repository.dart';

class GetUserProfileUseCase {
  final AuthRepository repository;

  GetUserProfileUseCase(this.repository);

  Future<Map<String, dynamic>> execute() {
    return repository.getUserProfile();
  }
}
