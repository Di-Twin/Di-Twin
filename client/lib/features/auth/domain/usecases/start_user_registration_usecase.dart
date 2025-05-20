import 'package:client/features/auth/domain/repositories/auth_repository.dart';

class StartUserRegistrationUseCase {
  final AuthRepository repository;

  StartUserRegistrationUseCase(this.repository);

  Future<Map<String, dynamic>> execute({required String phoneNumber}) {
    return repository.startUserRegistration(phoneNumber: phoneNumber);
  }
}
