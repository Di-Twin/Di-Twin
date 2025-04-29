import 'package:client/features/auth/domain/repositories/auth_repository.dart';

class GetAccessTokenUseCase {
  final AuthRepository repository;

  GetAccessTokenUseCase(this.repository);

  String? execute() {
    return repository.getAccessToken();
  }
}
