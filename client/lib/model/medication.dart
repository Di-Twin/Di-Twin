class Medication {
  final String id;
  final String userId;
  final String medicationName;
  final bool afterFood;
  final String frequency;
  final List<String> timings;
  final bool reminder;
  final String dose;
  final String startDate;
  final String endDate;
  final String createdAt;
  final String updatedAt;

  Medication({
    required this.id,
    required this.userId,
    required this.medicationName,
    required this.afterFood,
    required this.frequency,
    required this.timings,
    required this.reminder,
    required this.dose,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      medicationName: json['medicationName'] ?? '',
      afterFood: json['afterFood'] ?? false,
      frequency: json['frequency'] ?? '',
      timings: List<String>.from(json['timings'] ?? []),
      reminder: json['reminder'] ?? false,
      dose: json['dose'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicationName': medicationName,
      'afterFood': afterFood,
      'frequency': frequency,
      'timings': timings,
      'reminder': reminder,
      'dose': dose,
      'startDate': startDate,
      'endDate': endDate,
    };
  }

  // Create a new medication object with updated fields
  Medication copyWith({
    String? id,
    String? userId,
    String? medicationName,
    bool? afterFood,
    String? frequency,
    List<String>? timings,
    bool? reminder,
    String? dose,
    String? startDate,
    String? endDate,
    String? createdAt,
    String? updatedAt,
  }) {
    return Medication(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      medicationName: medicationName ?? this.medicationName,
      afterFood: afterFood ?? this.afterFood,
      frequency: frequency ?? this.frequency,
      timings: timings ?? this.timings,
      reminder: reminder ?? this.reminder,
      dose: dose ?? this.dose,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper method to get a display string for timing
  String get timingDisplay {
    if (afterFood) {
      return "After Eating";
    } else {
      return "Before Eating";
    }
  }
}

class DailyMedicationData {
  final List<DailyMedication> medications;
  final MedicationSummary summary;
  final String lastUpdated;

  DailyMedicationData({
    required this.medications,
    required this.summary,
    required this.lastUpdated,
  });

  factory DailyMedicationData.fromJson(Map<String, dynamic> json) {
    return DailyMedicationData(
      medications: (json['medications'] as List)
          .map((med) => DailyMedication.fromJson(med))
          .toList(),
      summary: MedicationSummary.fromJson(json['summary']),
      lastUpdated: json['lastUpdated'] ?? '',
    );
  }
}

class DailyMedication {
  final String id;
  final String medicationId;
  final String medicationName;
  final String time;
  final List<String> timings;
  final bool afterFood;
  final String dose;
  final String status; // "pending", "taken", or "missed"
  final String? takenAt;
  final String? skippedReason;

  DailyMedication({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.time,
    required this.timings,
    required this.afterFood,
    required this.dose,
    required this.status,
    this.takenAt,
    this.skippedReason,
  });

  factory DailyMedication.fromJson(Map<String, dynamic> json) {
    return DailyMedication(
      id: json['id'] ?? '',
      medicationId: json['medicationId'] ?? '',
      medicationName: json['medicationName'] ?? '',
      time: json['time'] ?? '',
      timings: List<String>.from(json['timings'] ?? []),
      afterFood: json['afterFood'] ?? false,
      dose: json['dose'] ?? '',
      status: json['status'] ?? 'pending',
      takenAt: json['takenAt'],
      skippedReason: json['skippedReason'],
    );
  }
}

class MedicationSummary {
  final int total;
  final int taken;
  final int missed;

  MedicationSummary({
    required this.total,
    required this.taken,
    required this.missed,
  });

  factory MedicationSummary.fromJson(Map<String, dynamic> json) {
    return MedicationSummary(
      total: json['total'] ?? 0,
      taken: json['taken'] ?? 0,
      missed: json['missed'] ?? 0,
    );
  }
}
