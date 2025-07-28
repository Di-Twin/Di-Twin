import '../../../../core/errors/failures.dart';
import '../../../../core/errors/either.dart';
import '../repositories/sleep_repository.dart';

class StartSleepUseCase {
  final SleepRepository repository;

  StartSleepUseCase(this.repository);

  Future<Either<Failure, void>> call(DateTime startTime) async {
    return await repository.startSleep(startTime);
  }
}
