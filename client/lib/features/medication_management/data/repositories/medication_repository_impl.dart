import 'package:client/core/errors/exceptions.dart';
import 'package:client/core/errors/failures.dart';
import 'package:client/core/network/network_info.dart';
import 'package:client/features/medication_management/data/datasources/medication_local_datasource.dart';
import 'package:client/features/medication_management/data/models/medication_model.dart';
import 'package:client/features/medication_management/domain/entities/medication.dart';
import 'package:client/features/medication_management/domain/entities/medication_schedule.dart';
import 'package:client/features/medication_management/domain/repositories/medication_repository.dart';
import 'package:dartz/dartz.dart';

class MedicationRepositoryImpl implements MedicationRepository {
  final MedicationLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  MedicationRepositoryImpl({
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<MedicationSchedule>>> getMedicationSchedules() async {
    try {
      final schedules = await localDataSource.getMedicationSchedules();
      return Right(schedules);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, MedicationSchedule>> getMedicationScheduleForDate(String date) async {
    try {
      final schedule = await localDataSource.getMedicationScheduleForDate(date);
      return Right(schedule);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> updateMedicationStatus(String medicationId, bool taken) async {
    try {
      final result = await localDataSource.updateMedicationStatus(medicationId, taken);
      return Right(result);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> addMedication(Medication medication, String date, String time) async {
    try {
      final medicationModel = MedicationModel.fromEntity(medication);
      final result = await localDataSource.addMedication(medicationModel, date, time);
      return Right(result);
    } on CacheException {
      return Left(CacheFailure());
    }
  }
}
