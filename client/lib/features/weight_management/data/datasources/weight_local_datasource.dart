import 'package:shared_preferences/shared_preferences.dart';

abstract class WeightLocalDataSource {
  Future<double?> getCurrentWeight();
  Future<void> saveCurrentWeight(double weight);
  Future<void> saveWeightUpdateSchedule();
  Future<bool> shouldShowWeightPopup();
  Future<void> saveTargetWeightRange(double min, double max);
  Future<List<double>?> getTargetWeightRange();
}

class WeightLocalDataSourceImpl implements WeightLocalDataSource {
  final SharedPreferences sharedPreferences;

  WeightLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<double?> getCurrentWeight() async {
    return sharedPreferences.getDouble('current_weight');
  }

  @override
  Future<void> saveCurrentWeight(double weight) async {
    await sharedPreferences.setDouble('current_weight', weight);
  }

  @override
  Future<void> saveWeightUpdateSchedule() async {
    final now = DateTime.now();
    final effectiveUntil = now.add(const Duration(days: 2));
    
    await sharedPreferences.setString('last_weight_update', now.toString());
    await sharedPreferences.setString('weight_effective_until', effectiveUntil.toString());
  }

  @override
  Future<bool> shouldShowWeightPopup() async {
    final lastUpdateString = sharedPreferences.getString('last_weight_update');
    final effectiveUntilString = sharedPreferences.getString('weight_effective_until');

    if (lastUpdateString == null || effectiveUntilString == null) {
      return true;
    }

    final effectiveUntil = DateTime.parse(effectiveUntilString);
    final now = DateTime.now();

    return now.isAfter(effectiveUntil);
  }

  @override
  Future<void> saveTargetWeightRange(double min, double max) async {
    await sharedPreferences.setDouble('target_weight_min', min);
    await sharedPreferences.setDouble('target_weight_max', max);
  }

  @override
  Future<List<double>?> getTargetWeightRange() async {
    final min = sharedPreferences.getDouble('target_weight_min');
    final max = sharedPreferences.getDouble('target_weight_max');
    
    if (min != null && max != null) {
      return [min, max];
    }
    return null;
  }
}