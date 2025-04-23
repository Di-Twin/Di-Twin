import 'package:client/features/activity_management/domain/entities/activity_detail.dart';

abstract class ActivityDetailRepository {
  Future<ActivityDetail> getActivityDetail(String activityId);
}
