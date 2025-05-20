import 'package:client/features/auth/domain/repositories/auth_repository.dart';

class UpdateUserProfileUseCase {
  final AuthRepository repository;

  UpdateUserProfileUseCase(this.repository);

  Future<Map<String, dynamic>> execute({
    String? firstName,
    String? lastName,
    String? dob,
    String? location,
    String? userPlan,
  }) {
    return repository.updateUserProfile(
      firstName: firstName,
      lastName: lastName,
      dob: dob,
      location: location,
      userPlan: userPlan,
    );
  }
}
