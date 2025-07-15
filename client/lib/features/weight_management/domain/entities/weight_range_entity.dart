class WeightRangeEntity {
  final double min;
  final double max;

  const WeightRangeEntity({
    required this.min,
    required this.max,
  });

  bool contains(double weight) {
    return weight >= min && weight <= max;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeightRangeEntity &&
        other.min == min &&
        other.max == max;
  }

  @override
  int get hashCode => min.hashCode ^ max.hashCode;

  @override
  String toString() => '${min.toStringAsFixed(1)}-${max.toStringAsFixed(1)}';
}