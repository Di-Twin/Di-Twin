import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/daily_food_model.dart';

abstract class DailyFoodRemoteDataSource {
  Future<DailyFoodModel> getDailyFood(String date);
}

class DailyFoodRemoteDataSourceImpl implements DailyFoodRemoteDataSource {
  final ApiClient apiClient;

  DailyFoodRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<DailyFoodModel> getDailyFood(String date) async {
    try {
      // Use the correct endpoint format
      final response = await apiClient.get('/food/daily/$date');
      
      // Check if the response has the expected structure
      if (response['success'] == true && response['data'] != null) {
        // Parse the data field which contains the actual daily food information
        return DailyFoodModel.fromJson(response['data']);
      } else {
        throw ServerException(
          message: response['message'] ?? 'Failed to fetch daily food data',
          statusCode: response['status'] ?? 400, // Add the required statusCode parameter
        );
      }
    } catch (e) {
      print('Error fetching daily food: $e');
      throw ServerException(
        message: e.toString(),
        statusCode: 500, // Add the required statusCode parameter
      );
    }
  }
}
