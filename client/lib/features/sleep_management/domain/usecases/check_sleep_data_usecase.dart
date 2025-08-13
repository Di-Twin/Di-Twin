import '../../../../core/errors/failures.dart';
import '../repositories/sleep_repository.dart';
import '../../../../core/errors/either.dart';

class CheckSleepDataUseCase {
  final SleepRepository repository;

  CheckSleepDataUseCase(this.repository);

  Future<Either<Failure, bool>> call() async {
    return await repository.hasSleepDataForToday();
  }
}
