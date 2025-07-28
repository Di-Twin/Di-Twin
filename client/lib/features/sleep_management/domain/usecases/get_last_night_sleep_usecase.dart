import '../../../../core/errors/failures.dart';
import '../entities/sleep_entry.dart';
import '../repositories/sleep_repository.dart';
import '../../../../core/errors/either.dart';

class GetLastNightSleepUseCase {
  final SleepRepository repository;

  GetLastNightSleepUseCase(this.repository);

  Future<Either<Failure, SleepEntry?>> call() async {
    return await repository.getLastNightSleep();
  }
}
