import '../repositories/weight_repository.dart';

class GetWeightDataUseCase {
  final WeightRepository repository;

  GetWeightDataUseCase(this.repository);

  Future<Map<String, double>> call(String period) async {
    return await repository.getWeightData(period);
  }
}