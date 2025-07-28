import '../../../../core/errors/failures.dart';
import '../entities/sleep_entry.dart';
import '../../../../core/errors/either.dart';
import '../repositories/sleep_repository.dart';

class GetTodaysSleepUseCase {
  final SleepRepository repository;

  GetTodaysSleepUseCase(this.repository);

  Future<Either<Failure, SleepEntry?>> call() async {
    return await repository.getTodaysSleep();
  }
}
