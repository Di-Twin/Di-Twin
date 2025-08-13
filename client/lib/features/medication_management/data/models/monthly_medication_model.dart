class MonthlyMedicationModel {
  final List<MedicationDayModel> days;
  final MedicationSummaryModel summary;
  final String lastUpdated;
  final String healthMetricId;

  MonthlyMedicationModel({
    required this.days,
    required this.summary,
    required this.lastUpdated,
    required this.healthMetricId,
  });

  factory MonthlyMedicationModel.fromJson(Map<String, dynamic> json) {
    return MonthlyMedicationModel(
      days: (json['days'] as List)
          .map((day) => MedicationDayModel.fromJson(day))
          .toList(),
      summary: MedicationSummaryModel.fromJson(json['summary']),
      lastUpdated: json['lastUpdated'] ?? '',
      healthMetricId: json['healthMetricId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'days': days.map((day) => day.toJson()).toList(),
      'summary': summary.toJson(),
      'lastUpdated': lastUpdated,
      'healthMetricId': healthMetricId,
    };
  }
}

class MedicationDayModel {
  final String date;
  final int total;
  final int taken;
  final int missed;
  final int pending;
  final String adherenceRate;
  final List<String> medicationIds;

  MedicationDayModel({
    required this.date,
    required this.total,
    required this.taken,
    required this.missed,
    required this.pending,
    required this.adherenceRate,
    required this.medicationIds,
  });

  factory MedicationDayModel.fromJson(Map<String, dynamic> json) {
    return MedicationDayModel(
      date: json['date'] ?? '',
      total: json['total'] ?? 0,
      taken: json['taken'] ?? 0,
      missed: json['missed'] ?? 0,
      pending: json['pending'] ?? 0,
      adherenceRate: json['adherenceRate'] ?? '0.0',
      medicationIds: List<String>.from(json['medicationIds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'total': total,
      'taken': taken,
      'missed': missed,
      'pending': pending,
      'adherenceRate': adherenceRate,
      'medicationIds': medicationIds,
    };
  }

  // Helper method to determine the primary status of the day
  MedicationDayStatus get primaryStatus {
    if (total == 0) return MedicationDayStatus.empty;
    if (taken == total) return MedicationDayStatus.taken;
    if (missed > 0) return MedicationDayStatus.missed;
    if (pending > 0) return MedicationDayStatus.pending;
    return MedicationDayStatus.partial;
  }
}

class MedicationSummaryModel {
  final int total;
  final int taken;
  final int missed;
  final String adherenceRate;

  MedicationSummaryModel({
    required this.total,
    required this.taken,
    required this.missed,
    required this.adherenceRate,
  });

  factory MedicationSummaryModel.fromJson(Map<String, dynamic> json) {
    return MedicationSummaryModel(
      total: json['total'] ?? 0,
      taken: json['taken'] ?? 0,
      missed: json['missed'] ?? 0,
      adherenceRate: json['adherenceRate'] ?? '0.0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'taken': taken,
      'missed': missed,
      'adherenceRate': adherenceRate,
    };
  }
}

enum MedicationDayStatus {
  empty,
  taken,
  missed,
  pending,
  partial,
}
