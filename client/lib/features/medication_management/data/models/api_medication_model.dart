import 'package:client/features/medication_management/domain/entities/medication.dart';
import 'package:flutter/material.dart';

/// Model for medication data from the API
class ApiMedicationModel {
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

  ApiMedicationModel({
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

  factory ApiMedicationModel.fromJson(Map<String, dynamic> json) {
    return ApiMedicationModel(
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

  /// Convert to domain entity
  Medication toEntity() {
    return Medication(
      id: id,
      name: medicationName,
      dosage: dose,
      instruction: afterFood ? 'After Food' : 'Before Food',
      icon: Icons.medication,
      taken: false,
    );
  }
}

/// Model for daily medication data from API
class DailyMedicationModel {
  final String id;
  final String medicationId;
  final String medicationName;
  final String time;
  final List<String> timings;
  final bool afterFood;
  final String dose;
  final String status; // "pending", "taken", "missed"
  final String? takenAt;
  final String? skippedReason;

  DailyMedicationModel({
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

  factory DailyMedicationModel.fromJson(Map<String, dynamic> json) {
    return DailyMedicationModel(
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

  /// Convert to domain entity
  Medication toEntity() {
    return Medication(
      id: id,
      name: medicationName,
      dosage: dose,
      instruction: afterFood ? 'After Food' : 'Before Food',
      icon: Icons.medication,
      taken: status == 'taken',
    );
  }
}

/// Model for daily medication summary
class DailyMedicationSummaryModel {
  final int total;
  final int taken;
  final int missed;

  DailyMedicationSummaryModel({
    required this.total,
    required this.taken,
    required this.missed,
  });

  factory DailyMedicationSummaryModel.fromJson(Map<String, dynamic> json) {
    return DailyMedicationSummaryModel(
      total: json['total'] ?? 0,
      taken: json['taken'] ?? 0,
      missed: json['missed'] ?? 0,
    );
  }
}

/// Model for daily medication response
class DailyMedicationResponseModel {
  final List<DailyMedicationModel> medications;
  final DailyMedicationSummaryModel summary;
  final String lastUpdated;

  DailyMedicationResponseModel({
    required this.medications,
    required this.summary,
    required this.lastUpdated,
  });

  factory DailyMedicationResponseModel.fromJson(Map<String, dynamic> json) {
    return DailyMedicationResponseModel(
      medications: (json['medications'] as List?)
          ?.map((med) => DailyMedicationModel.fromJson(med))
          .toList() ?? [],
      summary: DailyMedicationSummaryModel.fromJson(json['summary'] ?? {}),
      lastUpdated: json['lastUpdated'] ?? '',
    );
  }
}

/// Model for medication action response (take/skip)
class MedicationActionResponseModel {
  final DailyMedicationModel medication;
  final DailyMedicationSummaryModel summary;

  MedicationActionResponseModel({
    required this.medication,
    required this.summary,
  });

  factory MedicationActionResponseModel.fromJson(Map<String, dynamic> json) {
    return MedicationActionResponseModel(
      medication: DailyMedicationModel.fromJson(json['medication'] ?? {}),
      summary: DailyMedicationSummaryModel.fromJson(json['summary'] ?? {}),
    );
  }
}
