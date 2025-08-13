import '../../../../core/errors/failures.dart';
import '../../../../core/errors/either.dart';
import '../entities/sleep_entry.dart';

abstract class SleepRepository {
  Future<Either<Failure, void>> startSleep(DateTime startTime);
  Future<Either<Failure, void>> endSleep(DateTime endTime);
  Future<Either<Failure, SleepEntry?>> getTodaysSleep();
  Future<Either<Failure, SleepEntry?>> getLastNightSleep();
  Future<Either<Failure, bool>> hasSleepDataForToday();
  Future<Either<Failure, List<SleepEntry>>> getSleepHistory();
}
