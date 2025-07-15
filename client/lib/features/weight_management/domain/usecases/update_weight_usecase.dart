import '../repositories/weight_repository.dart';

class UpdateWeightUseCase {
  final WeightRepository repository;

  UpdateWeightUseCase(this.repository);

  Future<void> call(double weight) async {
    await repository.updateCurrentWeight(weight);
    await repository.saveWeightLocally(weight);
    await repository.updateWeightPopupSchedule();
  }
}