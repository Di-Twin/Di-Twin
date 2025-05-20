import 'package:client/features/activity_management/domain/entities/activity_detail.dart';
import 'package:client/features/activity_management/domain/repositories/activity_detail_repository.dart';

class GetActivityDetailUseCase {
  final ActivityDetailRepository repository;

  GetActivityDetailUseCase(this.repository);

  Future<ActivityDetail> execute(String activityId) async {
    return await repository.getActivityDetail(activityId);
  }
}
