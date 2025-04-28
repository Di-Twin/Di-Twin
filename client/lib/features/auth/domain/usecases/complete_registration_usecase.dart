import 'package:client/features/auth/domain/repositories/auth_repository.dart';

class CompleteRegistrationUseCase {
  final AuthRepository repository;

  CompleteRegistrationUseCase(this.repository);

  Future<Map<String, dynamic>> execute({
    required String phoneNumber,
    required String firstName,
    required String lastName,
    required String otpCode,
  }) {
    return repository.completeRegistration(
      phoneNumber: phoneNumber,
      firstName: firstName,
      lastName: lastName,
      otpCode: otpCode,
    );
  }
}
