import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/daily_food_model.dart';

abstract class DailyFoodRemoteDataSource {
  /// Calls the /food/daily/:date endpoint
  ///
  /// Throws a [ServerException] for all error codes.
  Future<DailyFoodModel> getDailyFood(String date);
}

class DailyFoodRemoteDataSourceImpl implements DailyFoodRemoteDataSource {
  final ApiClient apiClient;

  DailyFoodRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<DailyFoodModel> getDailyFood(String date) async {
    try {
      final response = await apiClient.get('/food/daily/$date');
      
      if (response['success'] == true) {
        return DailyFoodModel.fromJson(response['data']);
      } else {
        throw ServerException(
          message: response['message'] ?? 'Failed to fetch daily food data',
          statusCode: 400,
        );
      }
    } catch (e) {
      throw ServerException(
        message: e.toString(),
        statusCode: 500,
      );
    }
  }
}
