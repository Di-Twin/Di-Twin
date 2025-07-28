import '../../../../core/errors/failures.dart';
import '../entities/sleep_entry.dart';
import '../repositories/sleep_repository.dart';
import '../../../../core/errors/either.dart';

class EndSleepUseCase {
  final SleepRepository repository;

  EndSleepUseCase(this.repository);

  Future<Either<Failure, void>> call(DateTime endTime) async {
    return await repository.endSleep(endTime);
  }
}
