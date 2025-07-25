class WaterIntake {
  final DateTime date;
  final double totalAmount;
  final double goalAmount;
  final List<WaterIntakeEntry> entries;

  WaterIntake({
    required this.date,
    required this.totalAmount,
    required this.goalAmount,
    required this.entries,
  });

  double get progressPercentage => (totalAmount / goalAmount * 100).clamp(0, 100);

  WaterIntake copyWith({
    DateTime? date,
    double? totalAmount,
    double? goalAmount,
    List<WaterIntakeEntry>? entries,
  }) {
    return WaterIntake(
      date: date ?? this.date,
      totalAmount: totalAmount ?? this.totalAmount,
      goalAmount: goalAmount ?? this.goalAmount,
      entries: entries ?? this.entries,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'totalAmount': totalAmount,
      'goalAmount': goalAmount,
      'entries': entries.map((e) => e.toJson()).toList(),
    };
  }

  factory WaterIntake.fromJson(Map<String, dynamic> json) {
    return WaterIntake(
      date: DateTime.parse(json['date']),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      goalAmount: (json['goalAmount'] ?? 2000).toDouble(),
      entries: (json['entries'] as List<dynamic>?)
          ?.map((e) => WaterIntakeEntry.fromJson(e))
          .toList() ?? [],
    );
  }
}

class WaterIntakeEntry {
  final String? id;
  final double amount;
  final DateTime timestamp;
  final String note;

  WaterIntakeEntry({
    this.id,
    required this.amount,
    required this.timestamp,
    required this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
    };
  }

  factory WaterIntakeEntry.fromJson(Map<String, dynamic> json) {
    return WaterIntakeEntry(
      id: json['id'],
      amount: (json['amount'] ?? 0).toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      note: json['note'] ?? '',
    );
  }
}

class DailyWaterIntake {
  final DateTime date;
  final List<WaterIntakeEntry> intakes;
  final double goalAmount;

  DailyWaterIntake({
    required this.date,
    required this.intakes,
    required this.goalAmount,
  });

  double get totalAmount => intakes.fold(0, (sum, intake) => sum + intake.amount);
  double get progressPercentage => (totalAmount / goalAmount * 100).clamp(0, 100);
}
