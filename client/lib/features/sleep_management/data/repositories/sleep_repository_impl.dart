import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/sleep_entry.dart';
import '../../domain/repositories/sleep_repository.dart';
import '../datasources/sleep_local_datasource.dart';
import '../datasources/sleep_remote_datasource.dart';
import '../models/sleep_entry_model.dart';
import 'dart:developer' as developer;
import '../../../../core/errors/either.dart';

class SleepRepositoryImpl implements SleepRepository {
  final SleepLocalDataSource localDataSource;
  final SleepRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  SleepRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, void>> startSleep(DateTime startTime) async {
    try {
      final sleepEntry = SleepEntryModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(),
        startTime: startTime,
        sourceDevice: 'Manual Entry',
        isCompleted: false,
      );

      await localDataSource.saveSleepEntry(sleepEntry);
      developer.log('✅ Sleep started and saved locally', name: 'SleepRepository');

      return const Right(null);
    } catch (e) {
      developer.log('❌ Error starting sleep: $e', name: 'SleepRepository');
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> endSleep(DateTime endTime) async {
    try {
      final currentSleep = await localDataSource.getTodaysSleepEntry();

      if (currentSleep == null || currentSleep.isCompleted) {
        return Left(CacheFailure());
      }

      final durationSeconds = endTime.difference(currentSleep.startTime).inSeconds;

      final completedSleep = currentSleep.copyWith(
        endTime: endTime,
        durationSeconds: durationSeconds,
        isCompleted: true,
      );

      // Save locally first
      await localDataSource.saveSleepEntry(completedSleep);
      developer.log('✅ Sleep ended and saved locally', name: 'SleepRepository');

      // Try to submit to server if connected
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.submitSleepData(completedSleep);
          developer.log('✅ Sleep data submitted to server', name: 'SleepRepository');
        } catch (e) {
          developer.log('⚠️ Failed to submit to server, kept locally: $e', name: 'SleepRepository');
          // Don't fail the operation if server submission fails
        }
      }

      return const Right(null);
    } catch (e) {
      developer.log('❌ Error ending sleep: $e', name: 'SleepRepository');
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, SleepEntry?>> getTodaysSleep() async {
    try {
      final sleepEntryModel = await localDataSource.getTodaysSleepEntry();

      if (sleepEntryModel == null) {
        return const Right(null);
      }

      final sleepEntry = SleepEntry(
        id: sleepEntryModel.id,
        date: sleepEntryModel.date,
        startTime: sleepEntryModel.startTime,
        endTime: sleepEntryModel.endTime,
        sourceDevice: sleepEntryModel.sourceDevice,
        durationSeconds: sleepEntryModel.durationSeconds,
        isCompleted: sleepEntryModel.isCompleted,
      );

      return Right(sleepEntry);
    } catch (e) {
      developer.log('❌ Error getting today\'s sleep: $e', name: 'SleepRepository');
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, SleepEntry?>> getLastNightSleep() async {
    try {
      final sleepEntryModel = await localDataSource.getLastNightSleepEntry();

      if (sleepEntryModel == null) {
        return const Right(null);
      }

      final sleepEntry = SleepEntry(
        id: sleepEntryModel.id,
        date: sleepEntryModel.date,
        startTime: sleepEntryModel.startTime,
        endTime: sleepEntryModel.endTime,
        sourceDevice: sleepEntryModel.sourceDevice,
        durationSeconds: sleepEntryModel.durationSeconds,
        isCompleted: sleepEntryModel.isCompleted,
      );

      return Right(sleepEntry);
    } catch (e) {
      developer.log('❌ Error getting last night\'s sleep: $e', name: 'SleepRepository');
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> hasSleepDataForToday() async {
    try {
      final hasData = await localDataSource.hasSleepDataForDate(DateTime.now());
      return Right(hasData);
    } catch (e) {
      developer.log('❌ Error checking sleep data for today: $e', name: 'SleepRepository');
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<SleepEntry>>> getSleepHistory() async {
    try {
      // Try to get from server first if connected
      if (await networkInfo.isConnected) {
        try {
          final remoteEntries = await remoteDataSource.getSleepHistory();

          // Convert to domain entities
          final sleepEntries = remoteEntries.map((model) => SleepEntry(
            id: model.id,
            date: model.date,
            startTime: model.startTime,
            endTime: model.endTime,
            sourceDevice: model.sourceDevice,
            durationSeconds: model.durationSeconds,
            isCompleted: model.isCompleted,
          )).toList();

          return Right(sleepEntries);
        } catch (e) {
          developer.log('⚠️ Failed to get remote sleep history, falling back to local: $e', name: 'SleepRepository');
        }
      }

      // Fallback to local data
      final localEntries = await localDataSource.getAllSleepEntries();
      final sleepEntries = localEntries.map((model) => SleepEntry(
        id: model.id,
        date: model.date,
        startTime: model.startTime,
        endTime: model.endTime,
        sourceDevice: model.sourceDevice,
        durationSeconds: model.durationSeconds,
        isCompleted: model.isCompleted,
      )).toList();

      return Right(sleepEntries);
    } catch (e) {
      developer.log('❌ Error getting sleep history: $e', name: 'SleepRepository');
      return Left(CacheFailure());
    }
  }
}
