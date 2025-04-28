import 'package:client/features/auth/domain/repositories/auth_repository.dart';

class InitiateEmailSignupUseCase {
  final AuthRepository repository;

  InitiateEmailSignupUseCase(this.repository);

  Future<Map<String, dynamic>> execute({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? mobileNumber,
  }) async {
    try {
      final result = await repository.initiateEmailSignup(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        mobileNumber: mobileNumber,
      );
      
      print("📊 Raw API response: $result");
      return result;
    } catch (e) {
      print("❌ Error in InitiateEmailSignupUseCase: $e");
      return {
        "success": false,
        "message": "Error: $e",
      };
    }
  }
}
