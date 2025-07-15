import '../entities/weight_progress_entity.dart';
import '../repositories/weight_repository.dart';

class GetWeightProgressUseCase {
  final WeightRepository repository;

  GetWeightProgressUseCase(this.repository);

  Future<WeightProgressEntity> call() async {
    return await repository.getWeightProgress();
  }
}