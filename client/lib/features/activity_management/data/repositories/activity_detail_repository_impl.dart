import 'package:client/features/activity_management/data/datasources/activity_detail_remote_datasource.dart';
import 'package:client/features/activity_management/domain/entities/activity_detail.dart';
import 'package:client/features/activity_management/domain/repositories/activity_detail_repository.dart';

class ActivityDetailRepositoryImpl implements ActivityDetailRepository {
  final ActivityDetailRemoteDataSource remoteDataSource;

  ActivityDetailRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ActivityDetail> getActivityDetail(String activityId) async {
    return await remoteDataSource.getActivityDetail(activityId);
  }
}
