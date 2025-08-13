import 'package:client/features/auth/domain/repositories/auth_repository.dart';

class ResendOtpUseCase {
  final AuthRepository repository;

  ResendOtpUseCase(this.repository);

  Future<Map<String, dynamic>> execute(String phoneNumber) {
    return repository.resendOtp(phoneNumber);
  }
}
