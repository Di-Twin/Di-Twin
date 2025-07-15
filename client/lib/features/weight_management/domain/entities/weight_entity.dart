class WeightEntity {
  final double value;
  final DateTime date;
  final double? bmi;

  const WeightEntity({
    required this.value,
    required this.date,
    this.bmi,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeightEntity &&
        other.value == value &&
        other.date == date &&
        other.bmi == bmi;
  }

  @override
  int get hashCode => value.hashCode ^ date.hashCode ^ bmi.hashCode;
}